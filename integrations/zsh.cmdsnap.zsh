# cmdsnap - Capture commands and their output for easy sharing
# Source this file in your .zshrc: source /path/to/zsh.cmdsnap.zsh

CMDSNAP_DIR="${CMDSNAP_DIR:-$HOME/.cmdsnap}"
CMDSNAP_LAST_OUTPUT_FILE="$CMDSNAP_DIR/last_output"

mkdir -p "$CMDSNAP_DIR"

# The main cmdsnap function
cmdsnap() {
    local format="markdown"
    local count=1
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--plain)
                format="plain"
                shift
                ;;
            -n|--number)
                count="$2"
                shift 2
                ;;
            -h|--help)
                echo "cmdsnap - Capture and copy terminal commands with output"
                echo ""
                echo "Usage: cmdsnap [COUNT] [OPTIONS]"
                echo ""
                echo "Examples:"
                echo "  cmdsnap        # capture last command"
                echo "  cmdsnap 3      # capture last 3 commands"
                echo "  cmdsnap -n 5   # capture last 5 commands"
                echo ""
                echo "Options:"
                echo "  -n, --number N   Capture last N commands"
                echo "  -p, --plain      Use plain text format (no code block)"
                echo "  -h, --help       Show this help message"
                return 0
                ;;
            [0-9]*)
                count="$1"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                return 1
                ;;
        esac
    done
    
    # Get commands from history (excluding cmdsnap itself)
    local -a commands=()
    local history_list=(${(f)"$(fc -l -n -50)"})
    
    for ((i=${#history_list[@]}; i>=1; i--)); do
        local entry="${history_list[$i]}"
        # Trim leading whitespace
        entry="${entry#"${entry%%[![:space:]]*}"}"
        if [[ "$entry" != cmdsnap* ]] && [[ -n "$entry" ]]; then
            commands+=("$entry")
            if [[ ${#commands[@]} -ge $count ]]; then
                break
            fi
        fi
    done
    
    if [[ ${#commands[@]} -eq 0 ]]; then
        echo "No commands found in history."
        return 1
    fi
    
    # Reverse to get chronological order (oldest first)
    local -a ordered_commands=()
    for ((i=${#commands[@]}; i>=1; i--)); do
        ordered_commands+=("${commands[$i]}")
    done
    
    # Build the result
    local result=""
    local first=true
    
    echo "Capturing ${#ordered_commands[@]} command(s)..."
    echo "---"
    
    for cmd in "${ordered_commands[@]}"; do
        echo "→ $cmd"
        local output
        output=$(eval "$cmd" 2>&1)
        echo "$output"
        echo ""
        
        case "$format" in
            markdown)
                if [[ "$first" == true ]]; then
                    result="\`\`\`\n"
                    first=false
                fi
                result+="\$ ${cmd}\n"
                if [[ -n "$output" ]]; then
                    result+="${output}\n"
                fi
                result+="\n"
                ;;
            plain)
                result+="\$ ${cmd}\n"
                if [[ -n "$output" ]]; then
                    result+="${output}\n"
                fi
                result+="\n"
                ;;
        esac
    done
    
    # Close code block and trim trailing newlines
    if [[ "$format" == "markdown" ]]; then
        result="${result%\\n}"
        result="${result%\\n}"
        result+="\n\`\`\`"
    else
        result="${result%\\n}"
        result="${result%\\n}"
    fi
    
    # Copy to clipboard
    if command -v pbcopy &> /dev/null; then
        printf '%b' "$result" | pbcopy
        echo "✓ Copied to clipboard!"
    elif command -v xclip &> /dev/null; then
        printf '%b' "$result" | xclip -selection clipboard
        echo "✓ Copied to clipboard!"
    elif command -v xsel &> /dev/null; then
        printf '%b' "$result" | xsel --clipboard --input
        echo "✓ Copied to clipboard!"
    elif command -v clip.exe &> /dev/null; then
        printf '%b' "$result" | clip.exe
        echo "✓ Copied to clipboard!"
    else
        echo "No clipboard tool found. Output:"
        printf '%b\n' "$result"
        return 1
    fi
}
