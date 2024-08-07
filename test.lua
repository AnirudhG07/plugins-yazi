local toml = require("toml")

-- Function to read the contents of the TOML file
local function read_file(file_path)
	local file = io.open(file_path, "r")
	if not file then
		error("Could not open file: " .. file_path)
	end
	local content = file:read("*all")
	file:close()
	return content
end

-- Function to extract unique "run" commands
local function extract_unique_run_commands(config)
	local unique_commands = {}
	local commands_set = {}

	-- Function to recursively search for "run" keys
	local function search_for_run(tbl)
		for key, value in pairs(tbl) do
			if type(value) == "table" then
				search_for_run(value)
			elseif type(value) == "string" and key == "run" then
				if not commands_set[value] then
					commands_set[value] = true
					table.insert(unique_commands, value)
				end
			end
		end
	end

	search_for_run(config)
	return unique_commands
end

-- Path to the TOML file
local config_path = os.getenv("HOME") .. "/.config/yazi/keymap.toml"

-- Read and parse the TOML file
local config_content = read_file(config_path)
local config = toml.decode(config_content)

-- Extract unique "run" commands
local unique_run_commands = extract_unique_run_commands(config)

-- Use `fzf` to select a command
local function select_command(commands)
	local fzf_input = table.concat(commands, "\n")
	local fzf_command = "echo '" .. fzf_input .. "' | fzf"
	local fzf_process = io.popen(fzf_command, "r")
	local selected_command = fzf_process:read("*a")
	print(selected_command)
	fzf_process:close()
	return selected_command:gsub("%s+", "") -- Trim any extra whitespace
end

-- Print the selected command
local selected_command = select_command(unique_run_commands)
print("Selected command: " .. selected_command)

-- Exit the script cleanly
os.exit()
