tmux.vim
========

This repository provides a Vim syntax highlighting file for tmux
configurations. The syntax file is generated directly from the tmux source code
using an Awk script. A cron job running on a host managed by the maintainer of
this repository regenerates the syntax file once a day and, if the syntax file
has changed, commits the change then pushes it to GitHub. As such, this
repository should always have a fairly up-to-date syntax file as long as there
has not been any significant refactoring by the tmux maintainers.

![Screenshot of tmux configuration in Vim](screenshot.png)

This project and all accompanying files (unless stated otherwise) are licensed
under the [2-clause BSD license][bsd-2-clause].

  [bsd-2-clause]: http://opensource.org/licenses/BSD-2-Clause

Installation
------------

### Makefile ###

Assuming _make(1)_ is installed and there is an existing Vim directory at
`$HOME/.vim`, running `make install` should be sufficient.

### Plugin Manager ###

This repository should work with most Vim plugin managers that support tracking
Git repositories (e.g. [vim-plug][vim-plug]).

  [vim-plug]: https://github.com/junegunn/vim-plug

Development
-----------

In addition to the Makefile, there are two other components to this repository
used to generate the syntax file. The top portion of the syntax file that
defines syntax-matching regular expressions is found in "./src/header.vim". It
is combined with the output of "./src/dump-keywords.awk", an Awk script that
accepts tmux C source files as arguments then dumps extracted command and
option names. The Makefile and Awk script are POSIX-compliant.

### Makefile Targets ###

- **build:** Download the tmux source code and generate or update the Vim
  syntax file. This is the default target used when none are explicitly given.
- **install:** Install the Vim files in `$HOME/.vim`.
- **sync:** Pull the latest tmux commits, update the Vim syntax file then
  commit the changes. If "PUSH_AFTER_SYNC" is set to "true", the commit will
  automatically be pushed upstream i.e. `make PUSH_AFTER_SYNC=true sync`. The
  default value of "PUSH_AFTER_SYNC" is "false".
