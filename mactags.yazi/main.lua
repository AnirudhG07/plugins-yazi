local Tag_mapping = {
	r = { tag = "red", priority = 1 },
	b = { tag = "blue", priority = 2 },
	g = { tag = "green", priority = 3 },
	y = { tag = "yellow", priority = 4 },
	o = { tag = "orange", priority = 5 },
	p = { tag = "purple", priority = 6 },
	a = { tag = "grey", priority = 7 },
	h = { tag = "home", priority = 8 },
	i = { tag = "important", priority = 9 },
	w = { tag = "work", priority = 10 },
}

local Self_enabled = false

local function table_length(tbl)
	local count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end
	return count
end

local Max_tags = table_length(Tag_mapping)
local Shell_value = os.getenv("SHELL"):match(".*/(.*)")

local state = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

local function notify(str)
	ya.notify({
		title = "Mactags",
		content = str,
		timeout = 3,
		level = "info",
	})
end

local function fail(s, ...)
	ya.notify({ title = "Mactags", content = string.format(s, ...), timeout = 5, level = "error" })
end

local function commad_runner(cmd_args)
	local cwd = state()
	local child, err = Command(Shell_value)
		:args({ "-c", cmd_args })
		:cwd(cwd)
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		return fail("Spawn `mactag` failed with error code %s. Do you have `tag` installed?", err), child
	end

	local output, err = child:wait_with_output()
	if not output then
		return fail("Cannot read `mactag` output, error code %s", err), output
	elseif not output.status.success and output.status.code ~= 130 then
		return fail("`mactag` exited with error code %s", output.status.code), output
	else
		return true, output
	end
end

local assign_col = function(input_col)
	-- input of this function is format {"g", "work", "i"}
	-- Function to map input_col to full name tags
	-- Self_enabled is for letting the user assign the self made tags
	local function map_cols(input_colors)
		local mapped_cols = {}
		for _, color in ipairs(input_colors) do
			local lower_color = color:lower()
			local col = Tag_mapping[lower_color].tag
			if Self_enabled then
				col = Tag_mapping[lower_color].tag or lower_color
			end
			if col then
				table.insert(mapped_cols, col)
			else
				notify("assign fail, invalid tag: " .. color)
				return nil
			end
		end
		return mapped_cols
	end

	local mapped_cols = map_cols(input_col)

	if not mapped_cols then
		return nil
	end

	local unique_cols = {}
	local unique_cols_set = {}

	for _, col in ipairs(mapped_cols) do
		if not unique_cols_set[col] then
			table.insert(unique_cols, col)
			unique_cols_set[col] = true
		end
	end

	-- Convert the mapped cols to a space-separated string
	local col_string = table.concat(mapped_cols, " ")
	-- Check if the col_string is too long
	local i = 0
	for col in col_string:gmatch("%S+") do
		i = i + 1
		if i > Max_tags then -- since max 10 tags are possible
			notify("Assign fail, col too long. Assigning all the tags.")
			return "red green blue yellow orange purple grey home important work"
		end
	end
	return col_string
end

local function get_tags()
	local title = "set tag color(s) as - 'r g i w'"
	local col_set, event = ya.input({
		realtime = false,
		title = title,
		position = { "top-center", y = 3, w = 62 },
	})
	if event == 1 and col_set ~= "" then
		-- Split the input string into a table of cols
		local cols = {}
		for col in col_set:gmatch("%S+") do
			table.insert(cols, col)
		end
		-- Checking input for errors
		local assigned_cols = assign_col(cols)
		-- assigned_cols is a string "red green blue"
		if assigned_cols == nil then
			return get_tags()
		else
			return assigned_cols
		end
	elseif event == 1 and col_set == "" then
		local generate_col = "none"
		notify("You have not assigned any tag.")
		return generate_col
	else
		return nil
	end
end

local add_remove = function(args, generated_tags, file_path)
	if generated_tags == "none" then
		return
	end
	local flag = ""
	if args == "add" then
		flag = "--add"
	elseif args == "remove" then
		flag = "--remove"
	elseif args == "remove_all" then
		generated_tags = "red green blue yellow orange purple grey home important work"
		flag = "--remove"
	elseif args == "set" then
		flag = "--set"
	end

	-- Run the command separately for each tag
	for tag in generated_tags:gmatch("%S+") do
		local cmd_args = "tag " .. flag .. " " .. tag .. " " .. file_path
		local success, output = commad_runner(cmd_args)
		if not success then
			return false
		end
	end
	notify("Successfully performed " .. args .. " tag operation.")
end

local function preview(args, generated_tags, file_path)
	local _permit = ya.hide()
	if generated_tags == "none" then
		return
	end
	local cmd_args = ""
	local preview_cmd = " | fzf --preview '[[ -d {} ]] && eza --tree --color=always {} || bat -n --color=always {}'"

	if args == "find_all" then
		local new_tags = generated_tags:gsub(" ", ",")
		cmd_args = "tag -f " .. new_tags .. preview_cmd
	end

	local success, output = commad_runner(cmd_args)
	if not success then
		return false
	end

	local target = output.stdout:gsub("\n$", "")

	local function getfilepath(inputstr, url)
		if url == nil then
			url = "%s"
		end
		local urlStart, urlEnd = string.find(inputstr, url)
		if urlStart then
			return string.sub(inputstr, 1, urlStart - 1)
		end
		return inputstr
	end

	local file_url = getfilepath(target, ":")

	if file_url ~= "" then
		ya.manager_emit(file_url:match("[/\\]$") and "cd" or "reveal", { file_url })
	end
end

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

local function reorder_string(input)
	-- so that output tags are in similar order
	local priority = {}
	for abbr, data in pairs(Tag_mapping) do
		priority[abbr] = data.priority
	end
	local chars = {}
	for i = 1, #input do
		table.insert(chars, input:sub(i, i))
	end

	table.sort(chars, function(a, b)
		return (priority[a] or 11) < (priority[b] or 11)
	end)

	return table.concat(chars)
end

local function process_tags(output)
	local tagset = output:match("%s+(.*)"):gsub(",%s*", ",")
	local tag_table = {}

	local function get_tag_char(tag)
		for char, data in pairs(Tag_mapping) do
			if data.color:lower() == tag:lower() or char:lower() == tag:lower() then
				return char
			end
		end
		return nil
	end

	for tag in tagset:gmatch("([^,]+)") do
		local tag_char = get_tag_char(tag)
		if tag_char then
			table.insert(tag_table, tag_char)
		end
	end
	return tag_table
end

local function tag_notify()
	local files = selected_files()
	-- assert, #files == 1, since it is hovered
	local cmd_args = "tag -l " .. files[1]

	local success, output = commad_runner(cmd_args)
	if not success then
		return false
	end

	local target = output.stdout:gsub("\n$", "")
	local tag_table = process_tags(target)
	local tags = reorder_string(table.concat(tag_table, ""))
	notify("Tags: " .. tags)
end

return {

	entry = function(_, args)
		local action = args[1]
		if not action then
			return
		end

		local files = selected_files()
		if #files == 0 then
			return ya.notify({ title = "Mactags", content = "No file selected", level = "warn", timeout = 3 })
		end

		local col = ""
		if action == "add" or action == "remove" or action == "set" or action == "find_all" then
			local colors = get_tags()
			if colors == nil then
				return
			end
			for _, file_path in ipairs(files) do
				if action == "find_all" then
					preview(action, colors, file_path)
				else
					add_remove(action, colors, file_path)
				end
			end
		elseif action == "remove_all" then
			for _, file_path in ipairs(files) do
				add_remove(action, col, file_path)
			end
		elseif action == "tag_notify" then
			tag_notify()
		end
	end,
}
