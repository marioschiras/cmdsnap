# cmdsnap - Copy terminal commands to clipboard
# Source this file in your .zshrc: source /path/to/zsh.cmdsnap.zsh

# Get recent commands from history (excluding cmdsnap)
_cmdsnap_get_history() {
    local max="${1:-10}"
    local -a commands=()
    local history_list=(${(f)"$(fc -l -n -50)"})
    
    for ((i=${#history_list[@]}; i>=1; i--)); do
        local entry="${history_list[$i]}"
        entry="${entry#"${entry%%[![:space:]]*}"}"
        if [[ "$entry" != cmdsnap* ]] && [[ -n "$entry" ]]; then
            commands+=("$entry")
            if [[ ${#commands[@]} -ge $max ]]; then
                break
            fi
        fi
    done
    
    printf '%s\n' "${commands[@]}"
}

# Copy to clipboard helper
_cmdsnap_copy() {
    local content="$1"
    if command -v pbcopy &> /dev/null; then
        printf '%b' "$content" | pbcopy
        return 0
    elif command -v xclip &> /dev/null; then
        printf '%b' "$content" | xclip -selection clipboard
        return 0
    elif command -v xsel &> /dev/null; then
        printf '%b' "$content" | xsel --clipboard --input
        return 0
    elif command -v clip.exe &> /dev/null; then
        printf '%b' "$content" | clip.exe
        return 0
    fi
    return 1
}

# The main cmdsnap function
cmdsnap() {
    local format="markdown"
    local -a selected_indices=()
    local count=0
    local show_list=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--plain)
                format="plain"
                shift
                ;;
            list|-l|--list)
                show_list=true
                shift
                ;;
            help|-h|--help)
                echo "cmdsnap - Copy terminal commands to clipboard"
                echo ""
                echo "Usage:"
                echo "  cmdsnap            Copy the last command"
                echo "  cmdsnap N          Copy the last N commands"
                echo "  cmdsnap @N         Copy specific command #N from list"
                echo "  cmdsnap @1 @3      Copy multiple specific commands"
                echo "  cmdsnap @2..@5     Copy commands #2 through #5"
                echo "  cmdsnap list       Show recent commands with numbers"
                echo ""
                echo "Options:"
                echo "  -p, --plain        Plain text (no code block)"
                echo "  -l, list           Show recent commands"
                echo "  -h, help           Show this help"
                return 0
                ;;
            @[0-9]*..@[0-9]*)
                local range="${1#@}"
                local start="${range%%..@*}"
                local end="${range##*..@}"
                for ((n=start; n<=end; n++)); do
                    selected_indices+=("$n")
                done
                shift
                ;;
            @[0-9]*)
                selected_indices+=("${1#@}")
                shift
                ;;
            [0-9]*)
                count="$1"
                shift
                ;;
            *)
                echo "Unknown option: $1. Use 'cmdsnap help' for usage."
                return 1
                ;;
        esac
    done
    
    # Get history
    local -a history_commands
    history_commands=("${(@f)$(_cmdsnap_get_history 10)}")
    
    if [[ ${#history_commands[@]} -eq 0 ]]; then
        echo "No commands found in history."
        return 1
    fi
    
    # Show list mode
    if [[ "$show_list" == true ]]; then
        echo "Recent commands:"
        echo ""
        local idx=1
        for cmd in "${history_commands[@]}"; do
            printf "  @%d  %s\n" "$idx" "$cmd"
            ((idx++))
        done
        echo ""
        echo "Use 'cmdsnap @N' to copy a specific command"
        return 0
    fi
    
    # Determine which commands to copy
    local -a commands_to_copy=()
    
    if [[ ${#selected_indices[@]} -gt 0 ]]; then
        for idx in "${selected_indices[@]}"; do
            if [[ $idx -ge 1 ]] && [[ $idx -le ${#history_commands[@]} ]]; then
                commands_to_copy+=("${history_commands[$idx]}")
            else
                echo "Invalid index: @$idx (only ${#history_commands[@]} commands available)"
                return 1
            fi
        done
    elif [[ $count -gt 0 ]]; then
        for ((i=1; i<=count && i<=${#history_commands[@]}; i++)); do
            commands_to_copy+=("${history_commands[$i]}")
        done
        # Reverse for chronological order
        local -a reversed=()
        for ((i=${#commands_to_copy[@]}; i>=1; i--)); do
            reversed+=("${commands_to_copy[$i]}")
        done
        commands_to_copy=("${reversed[@]}")
    else
        commands_to_copy+=("${history_commands[1]}")
    fi
    
    # Build result (no re-running, just copy the commands)
    local result=""
    
    if [[ "$format" == "markdown" ]]; then
        result="\`\`\`\n"
        for cmd in "${commands_to_copy[@]}"; do
            result+="${cmd}\n"
        done
        result="${result%\\n}"
        result+="\n\`\`\`"
    else
        for cmd in "${commands_to_copy[@]}"; do
            result+="${cmd}\n"
        done
        result="${result%\\n}"
    fi
    
    # Copy to clipboard
    if _cmdsnap_copy "$result"; then
        echo "✓ Copied ${#commands_to_copy[@]} command(s) to clipboard!"
    else
        echo "No clipboard tool found. Output:"
        printf '%b\n' "$result"
        return 1
    fi
}
