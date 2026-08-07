local selected_files = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, u in pairs(tab.selected) do
		paths[#paths + 1] = tostring(u)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.url)
	end
	return paths, tostring(tab.current.cwd)
end)

-- show the path relative to the current directory when possible
local function display_path(path, cwd)
	if cwd and cwd ~= "" and path:sub(1, #cwd) == cwd then
		local rel = path:sub(#cwd + 1):gsub("^[/\\]+", "")
		if rel ~= "" then
			return rel
		end
	end
	return path
end

local function notify(str)
	ya.notify({
		title = "Copy-file-contents",
		content = str,
		timeout = 3,
		level = "info",
	})
end

local state_option = ya.sync(function(state, attr)
	return state[attr]
end)

local function entry(_, job)
	-- Copy the contents of selected files into clipboard
	local files, cwd = selected_files()
	if #files == 0 then
		return
	end

	-- "multi"/"plain" (e.g. `plugin copy-file-contents -- multi`) force the filename
	-- header + content wrapper on/off for this invocation, so two keybindings can be
	-- set up side by side. With no arg, falls back to the show_filename setup() option.
	local mode = job and job.args and job.args[1]
	local show_filename
	if mode == "multi" then
		show_filename = true
	elseif mode == "plain" then
		show_filename = false
	else
		show_filename = state_option("show_filename")
	end

	-- call the attributes from setup
	local notification = state_option("notification")
	local filename_format = state_option("filename_format") or "%s\n"
	local content_wrapper = state_option("content_wrapper")
	if content_wrapper == nil then
		content_wrapper = show_filename and "```" or ""
	end
	local append_char = state_option("append_char")
	if append_char == nil then
		append_char = show_filename and "\n\n" or "\n"
	end

	local text = ""
	for i, file in ipairs(files) do
		local f = io.open(file, "r")
		if f then
			local file_content = f:read("*a")
			-- Remove trailing newline before file appending
			file_content = file_content:gsub("%s+$", "")

			if show_filename then
				text = text .. string.format(filename_format, display_path(file, cwd))
			end
			if content_wrapper ~= "" then
				text = text .. content_wrapper .. "\n" .. file_content .. "\n" .. content_wrapper
			else
				text = text .. file_content
			end

			if i < #files then
				text = text .. append_char
			end
			f:close()
		end
	end

	-- Copy the file contents to clipboard
	ya.clipboard(text)
	-- Notify the user that the file contents have been copied to clipboard
	if notification then
		notify("Copied " .. #files .. " file(s) contents to clipboard")
	end
end

return {
	setup = function(state, options)
		-- Enable notification
		state.notification = options.notification and true
		-- Prepend a filename header before each file's content, used when the plugin is
		-- invoked with no "multi"/"plain" argument (see entry() below)
		state.show_filename = options.show_filename and true
		-- Lua format string for the filename header, "%s" is replaced with the file's path
		state.filename_format = options.filename_format
		-- String placed on its own line before/after each file's content, e.g. "```" or "'''".
		-- Set to "" to force wrapping off regardless of mode. Left unset (nil), it defaults
		-- to "```" in "multi" mode and "" otherwise (see entry() below).
		state.content_wrapper = options.content_wrapper
		-- Append character at the end of each file content. Left unset (nil), it defaults to
		-- a blank line in "multi" mode and a single newline otherwise (see entry() below).
		state.append_char = options.append_char
	end,
	entry = entry,
}
