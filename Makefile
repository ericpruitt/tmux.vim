# Author: Eric Pruitt (https://www.codevat.com)
# License: 2-Clause BSD (http://opensource.org/licenses/BSD-2-Clause)
.POSIX:
.SILENT:

# This can be set to "true" or "false" to control whether or not commits are
# automatically pushed to a remote repository after updating the syntax file
# with the "sync" recipe.
PUSH_AFTER_SYNC = false

# When note remote tracking branch is defined, this repository is used as the
# default.
DEFAULT_REMOTE = git@github.com:ericpruitt/tmux.vim.git

TMUX_GIT_DIR = tmux/.git
TMUX_SYNTAX_FILE = vim/syntax/tmux.vim
TMUX_URL = https://github.com/tmux/tmux.git
TMUX_VERSION=$$(cd $(TMUX_GIT_DIR) && \
	git log -1 --format="$$(git describe --abbrev=0 --tags) (git-%h)" \
)

all: build

install:
	set -x && cp -i -R vim/*/ ~/.vim/

$(TMUX_GIT_DIR):
	git clone $(TMUX_URL) $(@D)

$(TMUX_SYNTAX_FILE): $(TMUX_GIT_DIR) src/template.vim src/c-to-syntax.awk
	sed "s/TMUX_VERSION/$(TMUX_VERSION)/" src/template.vim > $@.tmp
	awk -f src/c-to-syntax.awk tmux/*.c >> $@.tmp
	if test ! -e $@ || diff -u $@ $@.tmp | \
	  sed -n '/^@@/,$${/Version:/!{/^+/p}}' | grep -q "^"; then \
		mv $@.tmp $@; \
		echo "Created syntax file for tmux v$(TMUX_VERSION):"; \
		exec ls -l -h $@; \
	fi; \
	rm -f $@.tmp; \
	echo "No change in options between commits; syntax file unchanged."

build: $(TMUX_GIT_DIR)
	TMUX_VERSION=$(TMUX_VERSION); \
	export TMUX_VERSION; \
	grep -e "$$TMUX_VERSION" -F -q $(TMUX_SYNTAX_FILE) 2>/dev/null || \
		touch src/*; \
	$(MAKE) $(TMUX_SYNTAX_FILE)

sync: $(TMUX_GIT_DIR)
	if [ -n "$$(git diff --name-only --cached)" ]; then \
		echo "Found staged changes; refusing to update." >&2; \
		exit 1; \
	fi
	if ! git diff --quiet $(TMUX_SYNTAX_FILE); then \
		echo "$(TMUX_SYNTAX_FILE) modified; refusing to update." >&2; \
		exit 1; \
	fi
	(cd tmux && git pull --quiet)
	git stash --quiet
	$(MAKE)
	if ! git diff --quiet $(TMUX_SYNTAX_FILE); then \
		git add $(TMUX_SYNTAX_FILE); \
		git commit -m "Syntax file refresh for v$(TMUX_VERSION)"; \
		if git rev-parse --abbrev-ref \
		  --symbolic-full-name "@{u}" > /dev/null 2>&1; then \
			git push; \
		else \
			git remote add github $(DEFAULT_REMOTE); \
			git push -u github master; \
		fi; \
	fi
	git stash pop --quiet || true
