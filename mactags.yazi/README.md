# mactags.yazi

Tagging files in yazi like MacOS.
<br>
You can select any number of files and tag them(or any other function) with multiple tags at once.

> [!Note]
> This plugin provides a few extra features to [mactag.yazi](https://github.com/yazi-rs/plugins/tree/main/mactag.yazi) plugin.
> It is not a replacement, but a supplement to it, hence the name - mactag + s(upplement)

## Requirements

- [yazi](https://github.com/sxyazi/yazi) Version >= 0.3.0
- Tag, which you can install using `brew install tag`
- [mactag.yazi](https://github.com/yazi-rs/plugins/tree/main/mactag.yazi)

```bash
tag - A tool for manipulating and querying file tags.
  usage:
    tag -a | --add <tags> <path>...     Add tags to file
    tag -r | --remove <tags> <path>...  Remove tags from file
    tag -s | --set <tags> <path>...     Set tags on file
    tag -m | --match <tags> <path>...   Display files with matching tags
    tag -f | --find <tags> <path>...    Find all files with tags (-A, -e, -R ignored)
    tag -u | --usage <tags> <path>...   Display tags used, with usage counts
    tag -l | --list <path>...           List the tags on file
  <tags> is a comma-separated list of tag names; use * to match/find any tag.
```

## Tag names

MacOS Finder has various tags based on priorities and usages. I have mapped each tag with a single corresponding letter and given them priorities for display. The tags are as follows:

```lua
Tag_mapping = {
  r = { tag = "red", priority = 1 },
  b = { tag = "blue", priority = 2 },
  g = { tag = "green", priority = 3 },
  y = { tag = "yellow", priority = 4 },
  o = { tag = "orange", priority = 5 },
  p = { tag = "purple", priority = 6 },
  a = { tag = "grey", priority = 7 },
  h = { tag = "home", priority = 8 },
  i = { tag = "important", priority = 9 },
  w = { tag = "work", priority = 10 }
}
```

## Installation

You can install it in MacOS using the following command:

```bash
git clone https://github.com/AnirudhG07/mactags.yazi ~/.config/yazi/plugins/mactags.yazi
```

## Usage

### Input

The input format should be as follows:

```
r g i w
# OR
Red green i work
```

Their should be no spelling mistakes in tags. You can use the mapped letter, full name with any casing you want.
<br>This will add all these 4 tags to the file/folder.

For the `find_all` command, the input taken is converted to `green,red,important,work` and then passed to the `tag -f` command. This will only output the files that have all of these tags ATLEAST.

### Keymaps

Add the following line to your `keymap.toml` file-

```toml
[[manager.prepend_keymap]]
on = ["u", "a"]
run = "plugin mactags --args=add"
desc = "Add multiple colored tags"
```

```toml
[[manager.prepend_keymap]]
on = ["u", "r"]
run = "plugin mactags --args=remove"
desc = "removes input tags from all tags"
```

```toml
[[manager.prepend_keymap]]
on = ["u", "d"]
run = "plugin mactags --args=remove_all"
desc = "removed all the tags attached"
```

```toml
[[manager.prepend_keymap]]
on = ["u", "s"]
run = "plugin mactags --args=set"
desc = "remove all previous tags and set new ones"
```

```toml
[[manager.prepend_keymap]]
on = ["u", "f"]
run = "plugin mactags --args=find_all"
desc = "find all files with input set of tags"
```

```toml
[[manager.prepend_keymap]]
on = ["u", "n"]
run = "plugin mactags --args=tag_notify"
desc = "Notify the tags of the current file"
```

## Configurations

The `tag` functionality in MacOS is a powerful tool which allows not only usage of colors, but also using your own tag names.

You can change the `tag` names, their `single character symbols` and their `priority` as you wish. The `priority` is used to show tags in a fixed order for easier understanding. `mactag.yazi` adds on the UI element for it since `mactags.yazi` does not have a UI element.

### Tags Mapping

You can change the `Tag_mapping` table with different names. Here is a sample configuration:

```lua
-- inside /path/to/yazi/plugins/mactags.yazi/init.lua
local Tag_mapping = {
    u = { tag = "urgent", priority = 1 },
    f = { tag = "family", priority = 2 },
    w = { tag = "work", priority = 3 },
    i = { tag = "important", priority = 4 },
    n = { tag = "notes", priority = 5 },
    v = { tag = "videos", priority = 6 },
    e = { tag = "entertainment", priority = 7 },
    h = { tag = "home", priority = 8 },
}
```

You can also change the `Self_enabled` variable to `true`. This will enable to allow you to add more tags without caring about what's inside the Tag_mapping table. Otherwise those tags will be ignored.

```lua
local Self_enabled = false -- false/true
```

If you change the above to `true`, please **NOTE** -

1. You cannot input more tags than the number of entries in the `Tag_mapping` table at a time.
2. The newly added tag will not be automatically added to the `Tag_mapping` table. You will have to manually add it.
