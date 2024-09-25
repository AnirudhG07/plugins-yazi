local selected_files = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, u in pairs(tab.selected) do
		paths[#paths + 1] = tostring(u)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.url)
	end
	return paths
end)
local function notify(str)
	ya.notify({
		title = "Copy-file-contents",
		content = str,
		timeout = 3,
		level = "info",
	})
end

-- Mapping for OS and its corresponding content copy command
local OS_clipboard_mapping = {
	["linux"] = "xclip -selection clipboard",
	["macos"] = "pbcopy",
	["windows"] = "clip",
	["ios"] = "pbcopy",
	["freebsd"] = "xclip -selection clipboard",
	["dragonfly"] = "xclip -selection clipboard",
	["netbsd"] = "xclip -selection clipboard",
	["openbsd"] = "xclip -selection clipboard",
	["solaris"] = "xclip -selection clipboard",
	["android"] = "termux-clipboard-set",
}

local state_option = ya.sync(function(state, attr)
	return state[attr]
end)

local function entry()
	-- Copy the contents of selected files into clipboard
	local files = selected_files()
	if #files == 0 then
		return
	end
	-- call the attributes from setup
	local append_char, notification, clipboard_cmd =
		state_option("append_char"), state_option("notification"), state_option("clipboard_cmd")
	local text = ""
	for _, file in ipairs(files) do
		local f = io.open(file, "r")
		if f then
			local file_content = f:read("*a")
			text = text .. file_content .. append_char
			f:close()
		end
	end

	-- Remove the last appended character
	if #append_char > 0 then
		text = text:sub(1, -#append_char)
	end

	local cmd_args = "echo " .. ya.quote(text) .. " | " .. clipboard_cmd
	local shell_value = os.getenv("SHELL"):match(".*/(.*)")

	-- Spawn the command to copy the file contents to clipboard
	local output, err = Command(shell_value):args({ "-c", cmd_args }):spawn():wait()

	if not output then
		return ya.err("Cannot spawn clipboard command, error code " .. tostring(err))
	end

	-- Notify the user that the file contents have been copied to clipboard
	if notification then
		notify("Copied file contents to clipboard")
	end
end

return {
	setup = function(state, options)
		-- Append character at the end of each file content
		state.append_char = options.append_char or "\n"
		-- Enable notification
		state.notification = options.notification and true
		-- Set the clipboard command based on the OS
		state.clipboard_cmd = options.clipboard_cmd or OS_clipboard_mapping[ya.target_os()]
		if state.clipboard_cmd:lower() == "default" or state.clipboard_cmd == nil or state.clipboard_cmd == "" then
			state.clipboard_cmd = OS_clipboard_mapping[ya.target_os()]
		end
	end,
	entry = entry,
}
