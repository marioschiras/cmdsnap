# cmdsnap - Capture commands and their output for easy sharing
# Source this file in your .zshrc: source /path/to/zsh.cmdsnap.zsh

CMDSNAP_DIR="${CMDSNAP_DIR:-$HOME/.cmdsnap}"
CMDSNAP_LAST_OUTPUT_FILE="$CMDSNAP_DIR/last_output"

mkdir -p "$CMDSNAP_DIR"

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
                echo "cmdsnap - Capture and copy terminal commands with output"
                echo ""
                echo "Usage:"
                echo "  cmdsnap            Capture the last command"
                echo "  cmdsnap N          Capture the last N commands"
                echo "  cmdsnap @N         Capture specific command #N from list"
                echo "  cmdsnap @1 @3      Capture multiple specific commands"
                echo "  cmdsnap list       Show recent commands with numbers"
                echo ""
                echo "Options:"
                echo "  -p, --plain        Plain text format (no code block)"
                echo "  -l, list           Show recent commands"
                echo "  -h, help           Show this help"
                echo ""
                echo "Examples:"
                echo "  cmdsnap            Copy last command"
                echo "  cmdsnap 3          Copy last 3 commands"
                echo "  cmdsnap list       See available commands"
                echo "  cmdsnap @2         Copy command #2 from list"
                echo "  cmdsnap @1 @4      Copy commands #1 and #4"
                return 0
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
        echo "Use 'cmdsnap @N' to capture a specific command"
        return 0
    fi
    
    # Determine which commands to capture
    local -a commands_to_run=()
    
    if [[ ${#selected_indices[@]} -gt 0 ]]; then
        # Specific commands selected with @N
        for idx in "${selected_indices[@]}"; do
            if [[ $idx -ge 1 ]] && [[ $idx -le ${#history_commands[@]} ]]; then
                commands_to_run+=("${history_commands[$idx]}")
            else
                echo "Invalid index: @$idx (only ${#history_commands[@]} commands available)"
                return 1
            fi
        done
    elif [[ $count -gt 0 ]]; then
        # Last N commands
        for ((i=1; i<=count && i<=${#history_commands[@]}; i++)); do
            commands_to_run+=("${history_commands[$i]}")
        done
        # Reverse for chronological order
        local -a reversed=()
        for ((i=${#commands_to_run[@]}; i>=1; i--)); do
            reversed+=("${commands_to_run[$i]}")
        done
        commands_to_run=("${reversed[@]}")
    else
        # Default: last command
        commands_to_run+=("${history_commands[1]}")
    fi
    
    # Run and capture
    local result=""
    echo "Capturing ${#commands_to_run[@]} command(s)..."
    echo "---"
    
    if [[ "$format" == "markdown" ]]; then
        result="\`\`\`\n"
    fi
    
    local first=true
    for cmd in "${commands_to_run[@]}"; do
        if [[ "$first" != true ]]; then
            result+="\n"
        fi
        first=false
        
        echo "→ $cmd"
        local output
        output=$(eval "$cmd" 2>&1)
        echo "$output"
        echo ""
        
        result+="\$ ${cmd}\n"
        if [[ -n "$output" ]]; then
            result+="${output}\n"
        fi
    done
    
    if [[ "$format" == "markdown" ]]; then
        result="${result%\\n}"
        result+="\`\`\`"
    else
        result="${result%\\n}"
    fi
    
    # Copy
    if _cmdsnap_copy "$result"; then
        echo "✓ Copied to clipboard!"
    else
        echo "No clipboard tool found. Output:"
        printf '%b\n' "$result"
        return 1
    fi
}
