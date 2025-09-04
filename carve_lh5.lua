#!/usr/bin/env lua

local METHOD = "-lh5-"
local SEP = package.config:sub(1, 1)

local function basename(p)
	return (p:gsub("[\\/]+$", "")):match("([^\\/]+)$") or p
end

local function dirname(p)
	local d = (p:gsub("[\\/]+$", "")):match("^(.*)[\\/][^\\/]+$") or "."
	if d == "" then d = "." end
	return d
end

local function stem(p)
	local b = basename(p)
	local s = b:match("^(.*)%.") or b
	return s
end

local function join(a, b)
	if a == "" or a == "." then return b end
	if a:sub(-1) == SEP then return a .. b end
	return a .. SEP .. b
end

local function mkdir_p(path)
	if SEP == "\\" then
		os.execute(string.format('mkdir "%s" 2>nul >nul', path))
	else
		os.execute(string.format('mkdir -p "%s" 2>/dev/null', path))
	end
end

local function write_bytes(path, data)
	mkdir_p(dirname(path))
	local f, err = io.open(path, "wb")
	if not f then return nil, err end
	f:write(data)
	f:close()
	return true
end

local function read_bytes(path)
	local f, err = io.open(path, "rb")
	if not f then return nil, err end
	local data = f:read("a")
	f:close()
	return data
end

local function which(cmd)
	if SEP == "\\" then
		local h = io.popen(('where %s 2>nul'):format(cmd))
		if not h then return nil end
		local out = h:read("*a") or ""
		h:close()
		return (#out > 0) and out:match("([^\r\n]+)") or nil
	else
		local h = io.popen(('command -v %s 2>/dev/null'):format(cmd))
		if not h then return nil end
		local out = h:read("*a") or ""
		h:close()
		return (#out > 0) and out:gsub("%s+$", "") or nil
	end
end

local function exec_capture(cmd)
	local h = io.popen(cmd)
	if not h then return false, "" end
	local out = h:read("*a") or ""
	local ok, why, code = h:close()
	if ok == nil then ok = false end
	if type(ok) ~= "boolean" then ok = (why == "exit" and code == 0) end
	return ok, out
end

local function sanitize_name(name)
	local out = {}
	for i = 1, #name do
		local ch = name:sub(i, i)
		if ch:match("[0-9A-Za-z%._%-%+]") then
			out[#out + 1] = ch
		else
			out[#out + 1] = "_"
		end
	end
	return table.concat(out)
end

local function le32_at(s, pos)
	local b1, b2, b3, b4 = s:byte(pos, pos + 3)
	if not b4 then return nil end
	return b1 + b2 * 256 + b3 * 256 ^ 2 + b4 * 256 ^ 3
end

local function carve_lh5(path)
	local data, err = read_bytes(path)
	if not data then
		io.stderr:write(string.format("[-] Failed to read %s: %s\n", path, err or "unknown"))
		os.exit(1)
	end

	local hits = {}
	local i = 1
	while true do
		local ni = string.find(data, METHOD, i, true)
		if not ni then break end

		local hdr_start = ni - 2
		if hdr_start < 1 then
			i = ni + 1
		else
			if hdr_start + 10 <= #data then
				local hdr_size = data:byte(hdr_start)
				local method = data:sub(hdr_start + 2, hdr_start + 6)
				if method == METHOD then
					local comp_size = le32_at(data, hdr_start + 7)
					if comp_size and comp_size > 0 then
						local hdr_end = hdr_start + 2 + hdr_size
						local comp_start = hdr_end
						local comp_end = comp_start + comp_size

						if comp_start >= 1 and comp_end - 1 <= #data then
							local name = nil
							local name_len_field = hdr_start + 21
							if name_len_field < hdr_end then
								local name_len = data:byte(name_len_field)
								if name_len and name_len > 0 then
									local name_start = name_len_field + 1
									local name_end   = name_start + name_len - 1
									if name_end <= hdr_end then
										name = data:sub(name_start, name_end)
									end
								end
							end

							local chunk = data:sub(hdr_start, comp_end - 1)
							hits[#hits + 1] = { offset = hdr_start - 1, comp_size = comp_size, name = name, chunk = chunk }
							i = comp_end
						else
							i = ni + 1
						end
					else
						i = ni + 1
					end
				else
					i = ni + 1
				end
			else
				i = ni + 1
			end
		end
	end

	local out_dir = stem(path) .. "_lh5_extracts"
	mkdir_p(out_dir)

	local lzh_paths = {}
	for idx, hit in ipairs(hits) do
		local safe_name = nil
		if hit.name and #hit.name > 0 then
			safe_name = sanitize_name(hit.name)
		end
		local base = string.format("%03d", idx)
		local fname = safe_name and (base .. "_" .. safe_name .. ".lzh") or (base .. ".lzh")
		local lzh_path = join(out_dir, fname)
		write_bytes(lzh_path, hit.chunk)
		lzh_paths[#lzh_paths + 1] = lzh_path
		print(string.format("[+] Carved #%d @0x%X, %d bytes -> %s", idx, hit.offset, hit.comp_size, lzh_path))
	end

	if #hits == 0 then
		print("[-] No -lh5- members found.")
	else
		print(string.format("[+] Carved %d member(s) into: %s", #hits, out_dir))
	end

	return out_dir, lzh_paths
end

local function find_7z()
	return which("7z") or which("7za") or which("7zz")
end

local function try_extract_with_7z(lzh_path, dst_dir, seven)
	if not seven then return false end
	mkdir_p(dst_dir)
	local cmd = string.format('"%s" x "%s" -o"%s" -y', seven, lzh_path, dst_dir)
	local ok, out = exec_capture(cmd)
	if ok then
		print(string.format("    [7z] Extracted %s -> %s", basename(lzh_path), dst_dir))
		return true
	else
		print(string.format("    [7z] Failed on %s", basename(lzh_path)))
		return false
	end
end

local function extract_all(lzh_paths, base_out, prefer)
	local unpack_dir = join(base_out, "unpacked")
	mkdir_p(unpack_dir)

	local seven = find_7z()
	local used_any = false

	for _, lzh in ipairs(lzh_paths) do
		local dst = join(unpack_dir, stem(lzh))
		mkdir_p(dst)
		local ok = try_extract_with_7z(lzh, dst, seven)
		if not ok then
			print(string.format("[!] Could not extract %s. Keep the .lzh; install 7-Zip (7z/7za/7zz).", basename(lzh)))
		else
			used_any = true
		end
	end

	if not used_any then
		print("[i] No extractor was used successfully. Carved archives are ready for manual extraction.")
	else
		print(string.format("[+] Extraction attempts complete. See: %s", unpack_dir))
	end
end

local function parse_args(argv)
	local args = { rom = nil, no_extract = false, prefer = "7z" }
	local i = 1
	while i <= #argv do
		local a = argv[i]
		if a == "--no-extract" then
			args.no_extract = true
			i = i + 1
		elseif a == "--prefer" then
			args.prefer = argv[i + 1] or "7z"
			i = i + 2
		elseif a == "-h" or a == "--help" then
			print([[
Usage: lua carve_lh5.lua ROM [--no-extract] [--prefer 7z]

Carves LHA -lh5- members from a ROM blob and optionally extracts them using 7-Zip.

Positional:
  ROM                 Path to binary blob

Options:
  --no-extract        Only carve .lzh members; do not extract
  --prefer 7z         (Lua port supports only 7z)
]])
			os.exit(0)
		else
			if not args.rom then
				args.rom = a
			else
				io.stderr:write("Unexpected argument: " .. a .. "\n")
				os.exit(2)
			end
			i = i + 1
		end
	end
	if not args.rom then
		io.stderr:write("Missing ROM path. Use --help for usage.\n")
		os.exit(2)
	end
	return args
end

local function main()
	local args = parse_args(arg)
	local base_out, lzh_paths = carve_lh5(args.rom)
	if #lzh_paths > 0 and not args.no_extract then
		extract_all(lzh_paths, base_out, args.prefer)
	end
end

if pcall(debug.getlocal, 4, 1) == false then
	main()
end
