# Copy-file-contents.yazi

A simple plugin to copy file contents just from Yazi without going into editor.

## Features

- Copy one or more file contents to clipboard.
- Set custom separator for copied contents.
- Set custom clipboard command.

## Preview

## Installation

You can install this plugin by running the following command

```bash
ya pack -a AnirudhG07/plugins-yazi:copy-file-contents
```

You can also manually install it by copying the [`init.lua`](https://github.com/AnirudhG07/plugins-yazi/tree/main/copy-file-contents/init.lua) file to your `~/.config/yazi/plugins` directory.

## Usages

Add the below keybinding to your `~/.config/yazi/keymaps.toml` file.

```toml
[[manager.prepend_keymap]]
on = "<A-y>"
run = ["plugin copy-contents"]
desc = "Copy contents of file"
```

Add the below to your `~/.config/yazi/init.lua` file to set custom options for the plugin.

```lua
require("copy-file-contents"):setup({
	clipboard_cmd = "default",
	append_char = "\n",
	notification = true,
})
```

## Options

1. `clipboard_cmd`: Set the clipboard command to use. Use `"default"` to use the default command based on the OS.

```lua
OS_clipboard_mapping = {
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
```

You can set the `clipboard_cmd` to any of the above commands. The command run to copy the contents will be run as -

```bash
echo file_name | clipboard_cmd
```

2. `append_char`: Set the character to append at the end of each copied file content. Default is `"\n"`.
3. `notification`: Set to `true/false` to enable/disable notification after copying the contents. Default is `true`.
