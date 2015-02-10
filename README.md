## taboo.vim

It is fork from [gcmt/taboo.vim](https://github.com/gcmt/taboo.vim), and a custom option for g:taboo\_tab\_format

### Basic options

**g:taboo\_tab\_format**

With this option you can customize the look of tabs. Below all the available items:

- `%f`: the name of the first buffer open in the tab
- `%a`: the path relative to `$HOME` of the first buffer open in the tab
- `%s`: the simple path relatvie to workspace or `$HOME` of the first buffer open in the tab
- `%n`: the tab number, but only on the active tab
- `%N`: the tab number on each tab
- `%w`: the number of windows opened into the tab, but only on the active tab
- `%W`: the number of windows opened into the tab, on each tab
- `%m`: the modified flag

