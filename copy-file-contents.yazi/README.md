# Copy-file-contents.yazi

A simple plugin to copy file contents just from Yazi without going into editor.

## Features

- Copy one or more file contents to clipboard.
- Set custom separator for copied contents.
- Optionally prepend each file's path as a header, with a configurable format and content wrapper/delimiter.
- It utilises yazi's `ya.clipboard()` to copy contents to clipboard, taking care of binary files too.

## Preview

[copy-file-contents.yazi_preview.webm](https://github.com/user-attachments/assets/b7050697-1766-410a-ae5e-8519a62e650b)

## Installation

You can install this plugin by running the following command

```bash
ya pkg add AnirudhG07/plugins-yazi:copy-file-contents
```

You can also manually install it by copying the [`main.lua`](https://github.com/AnirudhG07/plugins-yazi/tree/main/copy-file-contents/main.lua) file to your `~/.config/yazi/plugins` directory.

## Usages

Add keybindings to your `~/.config/yazi/keymaps.toml` file. You can set up two side by side: a plain one, and a `"multi"` one that prepends each file's path and wraps its content in a fence:

```toml
[[mgr.prepend_keymap]]
on = "<A-1>"
run = ["plugin copy-file-contents -- plain"]
desc = "Copy contents of file(s)"

[[mgr.prepend_keymap]]
on = "<A-2>"
run = ["plugin copy-file-contents -- multi"]
desc = "Copy contents of file(s) with filename + code fence"
```

`-- multi` forces the filename header and content wrapper **on** for that keybinding, regardless of the `show_filename`/`content_wrapper` setup options below. `-- plain` forces them **off**. With no argument at all, the plugin falls back to whatever `show_filename` is set to in `setup()` (`false` by default).

Add the below to your `~/.config/yazi/init.lua` file to set custom options for the plugin.

```lua
require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
	show_filename = false,
	filename_format = "%s\n",
	content_wrapper = "```",
})
```

## Options

1. `append_char`: Set the character to append at the end of each copied file content. Defaults to a blank line (`"\n\n"`) in `multi` mode (so file blocks stay visually separated), or `"\n"` otherwise.
2. `notification`: Set to `true/false` to enable/disable notification after copying the contents. Default is `true`.
3. `show_filename`: Set to `true` to prepend a filename header before each file's content when the plugin is invoked with no `multi`/`plain` argument. Default is `false`.
4. `filename_format`: A Lua format string for the filename header, where `%s` is replaced with the file's path (shown relative to the current directory when possible). Default is `"%s\n"`.
5. `content_wrapper`: A string placed on its own line immediately before and after each file's content (e.g. `` "```" `` or `"'''"`). Set to `""` to force wrapping off in every mode. Left unset, it defaults to `` "```" `` in `multi` mode and `""` otherwise.

Selecting multiple files (or hovering one with nothing selected) and running the plugin copies **all** of them at once, concatenated together. With the defaults above, the `multi` keybinding copying `README.md` and `dir/file.txt` produces:

````
README.md
```
...contents...
```

dir/file.txt
```
...contents...
```
````
