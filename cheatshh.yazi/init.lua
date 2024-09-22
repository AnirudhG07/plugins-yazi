local state = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

local function fail(s, ...)
	ya.notify({ title = "Cheatshh", content = string.format(s, ...), timeout = 5, level = "error" })
end

local function get_selected_option()
    local command = [[
    bash -c '
    OPTIONS=("1" "Add command" "2" "Add group" "3" "Edit Command" "4" "Edit group" "5" "Delete Command" "6" "Delete group")
    CHOICE=$(whiptail --title "Menu" --menu "Choose an option" 15 60 6 \
    "1" "Add command" \
    "2" "Add group" \
    "3" "Edit Command" \
    "4" "Edit group" \
    "5" "Delete Command" \
    "6" "Delete group" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        echo $CHOICE
    else
        echo "Cancelled"
        exit 1
    fi
    '
    ]]  -- Command to run your Bash script embedded as a string
    local handle = io.popen(command, 'r')  -- Open the process for reading
    if handle then
        local output = handle:read("*a")  -- Read the entire output of the command
        handle:close()  -- Close the process
        return output  -- Return the captured output
    else
		fail("Failed to run cheatshh options")
        return nil
    end
end

local function commad_runner(cmd_args)
	local cwd = state()
	local shell_value = os.getenv("SHELL"):match(".*/(.*)")
	local child, err = Command(shell_value)
		:args({ "-c", cmd_args })
		:cwd(cwd)
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		return fail("Spawn `cheatshh` failed with error code %s. Do you have `tag` installed?", err), child
	end

	local output, err = child:wait_with_output()
	if not output then
		return fail("Cannot read `cheatshh` output, error code %s", err), output
	elseif not output.status.success and output.status.code ~= 130 then
		return fail("`cheatshh` exited with error code %s", output.status.code), output
    else
        return true, output
    end
end

local function entry(_, args)
	local _permit = ya.hide()
	local cmd_args = ""

	local option_to_cmd_args = {
		[1] = "cheatshh -a",
		[2] = "cheatshh -g",
		[3] = "cheatshh -ec",
		[4] = "cheatshh -eg",
		[5] = "cheatshh -dc",
		[6] = "cheatshh -dg",
	}

	if args[1] == nil then
		cmd_args = [[cheatshh]]
	elseif args[1] == "options" then
		local selected_option, err = get_selected_option()
		cmd_args = option_to_cmd_args[selected_option] or nil

		if not cmd_args then
			return
		end
	end
	local success, output = commad_runner(cmd_args)
	if not success then
		return
	end
end

return { entry = entry }
