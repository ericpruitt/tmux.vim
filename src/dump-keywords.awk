#!/usr/bin/awk -f
BEGIN {
    tmuxCommands = ""
    tmuxOptions = ""
    inside_cmd_entry = 0
    inside_options_table = 0
    inside_command_alias = 0
    WRAP_AFTER_COLUMN = 79
}

/options_table_entry options_table\[\] = \{$/ {
    inside_options_table = 1
}

inside_options_table && !/NULL/ {
    if (NF && $1 == "};") {
        inside_options_table = 0
    } else if (/\.name/) {
        name = $NF
        gsub(/[^a-z0-9-]/, "", name)
        tmuxOptions = tmuxOptions " " name

        if (name == "command-alias") {
            inside_command_alias = 1
        }
    } else if (inside_command_alias) {
        if (/[}],/) {
            inside_command_alias = 0
        } else if (match($0, /"[a-z0-9-]+=/)) {
            tmuxCommands = tmuxCommands " " substr($0, RSTART + 1, RLENGTH - 2)
        }
    }
}

/^const struct cmd_entry.*\{$/ {
    inside_cmd_entry = 1
}

inside_cmd_entry && !/NULL/ {
    if (NF && $1 == "};") {
        inside_cmd_entry = 0
    } else if (/\.(name|alias)/) {
        gsub(/[^a-z0-9-]/, "", $NF)
        tmuxCommands = tmuxCommands " " $NF
    }
}

END {
    if (!length(tmuxOptions) || !length(tmuxCommands)) {
        print "Unable to extract keywords from tmux source." > "/dev/fd/2"
        exit 1
    }

    i = 0
    while (i++ < 2) {
        if (i == 1) {
            printf "\nsyn keyword tmuxOptions"
            $0 = tmuxOptions
        } else {
            printf "\n\nsyn keyword tmuxCommands"
            $0 = tmuxCommands
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
    }
    printf "\n"
}
