#!/usr/bin/awk -f

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

BEGIN {
    WRAP_AFTER_COLUMN = 79
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
    while (match($0, /"[^"]+"/)) {
        name = substr($0, RSTART + 1, RLENGTH - 2)
        $0 = substr($0, RSTART + RLENGTH + 1)

        if (name !~ /^[0-9]+$/) {
            add_keyword("tmuxEnums", name)
        }
    }
}

END {
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

        width_left = 0
        for (k = 1; k <= NF; k++) {
            word = $k
            wordlen = length(word) + 1
            if (wordlen < width_left) {
                printf " %s", word
                width_left -= wordlen
            } else {
                printf "\n\\ %s", word
                width_left = WRAP_AFTER_COLUMN - 3 - wordlen
            }
        }

        printf "\n"
    }
}
