#!/usr/bin/awk -f
BEGIN {
    tmuxCommands = ""
    tmuxOptions = ""
    inside_cmd_entry = 0
    inside_options_table = 0
    WRAP_AFTER_COLUMN = 79
}

/options_table_entry options_table\[\] = \{$/ {
    inside_options_table = 1
}

inside_options_table && !/NULL/ {
    if (NF && $1 == "};") {
        inside_options_table = 0
    } else if (/\.name/) {
        gsub(/[^a-z0-9-]/, "", $NF)
        tmuxOptions = tmuxOptions " " $NF
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
        for (k = head = 1; k < NF; k = ((k + 1) == NF ? head++ : k + 1)) {
            if ($k > $(k + 1)) {
                temp = $k
                $k = $(k + 1)
                $(k + 1) = temp
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
