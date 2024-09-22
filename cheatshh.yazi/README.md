# cheatshh.yazi

A Yazi plugin for searching commands and copying them to your clipbaord, using [cheatshh](https://github.com/AnirudhG07/cheatshh)

## Dependencies

Please follow the download instruction and dependencies in the below link.

- [cheatshh](https://github.com/AnirudhG07/cheatshh)

This is mainly for Unix(Linux and Macos).

## Installation

Use the below command to install the plugin-

```bash
git clone https://github.com/AnirudhG07/cheatshh.yazi.git ~/.config/yazi/plugins/cheatshh.yazi
```

## Keymapping and Usage

You can copy the below commands to `keymap.toml` to use the plugin-

```toml
[[manager.prepend_keymap]]
on   = [ "c","h" ]
run  = "plugin cheatshh"
desc = "Find command in cheatshh"
```

To choose various options within Yazi.

```toml
[[manager.prepend_keymap]]
on   = [ "c","H" ]
run  = "plugin cheatshh --args=options"
desc = "Find command in cheatshh"
```

**NOTE**
The `options` flag has bugs. It is recommended not to use it. For an empty screen you see by chance, Please press Enter to Continue ahead.

Instead to add,edit,delete commands and groups, either use the regular terminal or manually edit it in `$HOME/.config/cheatshh` direct:ory.

## Bugs

1. The flag command run within yazi do not run properly. They skip the whiptail asking for yes/no.
