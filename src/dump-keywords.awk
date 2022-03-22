#!/usr/bin/awk -f
# This script extracts tmux options, commands and enums from the tmux source
# code and emits VimL syntax keyword definitions. The usual invocation is
# something like "awk -f dump-keywords.awk tmux/*.c". All of the logic is
# file-agnostic, instead relying on the presence of certain patterns in the
# code, so files being renamed and code being moved around should generally
# have no impact on this script.

# Add a keyword to the specified group in an idempotent manner.
#
# Arguments:
# - group
# - keyword
#
function add_keyword(group, keyword)
{
    if (!(group in keywords) || !match(keywords[group], " " keyword "($| )")) {
        keywords[group] = keywords[group] " " keyword
    }
}

/options_table_entry options_table\[\] = \{$/,/\};/ {
    if (/OPTIONS_TABLE[^"]*_HOOK\("/ && match($0, /"[^"]+"/)) {
        name = substr($0, RSTART + 1, RLENGTH - 2)
        add_keyword("tmuxOptions", name)
    } else if (/\.name/ && match($0, /"[^"]+"/)) {
        name = substr($0, RSTART + 1, RLENGTH - 2)
        add_keyword("tmuxOptions", name)
    }
}

/\.name[ \t]*=[ \t]*"command-alias"/,/\},/ {
    # Aliases are defined in the form of "$ALIAS=$EXPANSION", so alias names
    # are extracted by yanking everything between the first '"' and "=" on each
    # line. This assumes the tmux developers will always write each alias
    # definition on a separate line.
    if (match($0, /"[a-z0-9-]+=/)) {
        name = substr($0, RSTART + 1, RLENGTH - 2)
        add_keyword("tmuxCommands", name)
    }
}

/^const struct cmd_entry.*\{$/,/\};/ {
    if (/\.(name|alias)/ && match($0, /"[^"]+"/)) {
        name_or_alias = substr($0, RSTART + 1, RLENGTH - 2)
        add_keyword("tmuxCommands", name_or_alias)
    }
}

/^static const char \*options_table_.*_list\[\]/,/\};/ {
    # The "match" function does not accept an offset, so every string is
    # extracted by deleting the text up to the end of the match then searching
    # for a string again in the amputated line.
    while (match($0, /"[^"]+"/)) {
        name = substr($0, RSTART + 1, RLENGTH - 2)
        $0 = substr($0, RSTART + RLENGTH + 1)

        # Some options accept specific numbers which will already be matched by
        # the tmuxNumber pattern.
        if (name !~ /^[0-9]+$/) {
            add_keyword("tmuxEnums", name)
        }
    }
}

END {
    MAX_LINE_LENGTH = 79

    # Array iteration order is not portably deterministic, so iterate over keys
    # in the order defined in "group_names."
    group_names = "tmuxOptions tmuxCommands tmuxEnums"
    group_count = split(group_names, groups)

    for (i = 1; i <= group_count; i++) {
        group = groups[i]

        if (!(group in keywords)) {
            print "no keywords for " group " found" > "/dev/fd/2"
            close("/dev/fd/2")
            exit 1
        }

        $0 = keywords[group]

        # Add entries for American spelling of "color." The terms are processed
        # backwards since adding the new terms will change the value of NF.
        for (k = NF; k > 0; k--) {
            if ((name = $k) ~ /colour/) {
                gsub(/colour/, "color", name)
                $0 = $0 " " name
            }
        }

        # Sort keywords so re-ordering in the source code does not cause the
        # syntax files to change.
        for (j = 1; j <= NF; j++) {
            for (k = 1; k <= NF; k++) {
                if ($j < $k) {
                    temp = $j
                    $j = $k
                    $k = temp
                }
            }
        }

        printf "\nsyn keyword %s", group

        # Dump all of the keywords ensuring the lines are no longer than
        # MAX_LINE_LENGTH.
        width_left = 0
        for (k = 1; k <= NF; k++) {
            word = $k
            wordlen = length(word) + 1
            if (wordlen < width_left) {
                printf " %s", word
                width_left -= wordlen
            } else {
                printf "\n\\ %s", word
                width_left = MAX_LINE_LENGTH - 3 - wordlen
            }
        }

        printf "\n"
    }
}
