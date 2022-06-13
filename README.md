## taboo.vim

Taboo aims to ease the way you set the vim tabline. In addition, Taboo provides fews useful utilities for renaming tabs.

### Installation

Install either with [Vundle](https://github.com/gmarik/vundle), [Pathogen](https://github.com/tpope/vim-pathogen) or [Neobundle](https://github.com/Shougo/neobundle.vim).

**NOTE**: tabs look different in terminal vim than in gui versions. If you wish having terminal style tabs even in gui versions you have to add the following line to your .vimrc file
```vim
set guioptions-=e
```

Taboo is able to remember tab names when you save the current session but you are required to set the following option in your .vimrc file
```vim
set sessionoptions+=tabpages,globals
```

### Commands

- `TabooRename <tabname>` Renames the current tab with the name provided.
- `TabooOpen <tabname>` Opens a new tab and and gives it the name provided.
- `TabooReset` Removes the custom label associated with the current tab.

### Basic options

**g:taboo\_tab\_format**

With this option you can customize the look of tabs. Below all the available items:

- `%f`: the name of the first buffer open in the tab
- `%F`: the name of the buffer open in the current window of the tab
- `%a`: the path relative to `$HOME` of the first buffer open in the tab
- `%A`: the path relative to `$HOME` of the buffer open in the current window of the tab
- `%r`: the path relative to the current working directory
- `%R`: the path relative to the current working directory of the buffer in the current window of the tab
- `%n`: the tab number, but only on the active tab
- `%N`: the tab number on each tab
- `%i`: same as `%n`, but using superscript numbers (eg. `²`)
- `%I`: same as `%N`, but using superscript numbers
- `%w`: the number of windows opened into the tab, but only on the active tab
- `%W`: the number of windows opened into the tab, on each tab
- `%u`: same as `%w`, but using superscript numbers (eg. `³`)
- `%U`: same as `%W`, but using superscript numbers
- `%m`: the modified flag
- `%p`: the tab current working directory
- `%P`: the last component of the tab current working directory
- `%S`: the shortened tab current working directory
- `%x`: close tab button, see `g:taboo_close_tab_label`

Default: `" %f%m "`

**g:taboo\_renamed\_tab\_format**

Same as `g:taboo_tab_format` but for renamed tabs. In addition, you can use the following items:

- `%l`: the custom tab name set with `:TabooRename`

**NOTE:** with renamed tabs the items `%f` and `%a` will be evaluated to an empty string.

Default: `" [%l]%m "`

**g:taboo\_modified\_tab\_flag**

This option controls how the modified flag looks like.

Default: `"*"`

**g:taboo\_tabline**

Turn off this option and Taboo won't generate the tabline. This may be useful if you want to do it yourself with the help of the functions `TabooTabTitle(..)` or `TabooTabName(..)`.

Default: `1`

**g:taboo\_close\_tab\_label**

This option controls how the close button looks like.

Default: `"x"`

### Public interface

Taboo provides a couple of public functions that may be used by third party plugins:

- `TabooTabTitle(tabnumber)` -> `string`

    This function returns the formatted tab title according to the options `g:taboo_tab_format` and `g:taboo_renamed_tab_format` (for renamed tabs).

- `TabooTabName(tabnumber)` -> `string`

    This function returns the name of a renamed tab. If a tab has no name, an empty string is returned.
