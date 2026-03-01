# cmdsnap - Capture commands and their output for easy sharing
# Source this file in your .zshrc: source /path/to/zsh.cmdsnap.zsh

CMDSNAP_DIR="${CMDSNAP_DIR:-$HOME/.cmdsnap}"
CMDSNAP_LAST_OUTPUT_FILE="$CMDSNAP_DIR/last_output"

mkdir -p "$CMDSNAP_DIR"

# The main cmdsnap function
cmdsnap() {
    local format="markdown"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--plain)
                format="plain"
                shift
                ;;
            -h|--help)
                echo "cmdsnap - Capture and copy terminal commands with output"
                echo ""
                echo "Usage: Run any command, then type 'cmdsnap'"
                echo ""
                echo "Example:"
                echo "  ls -la"
                echo "  cmdsnap    # re-runs ls -la, captures output, copies to clipboard"
                echo ""
                echo "Options:"
                echo "  -p, --plain    Use plain text format (no code block)"
                echo "  -h, --help     Show this help message"
                return 0
                ;;
            *)
                echo "Unknown option: $1"
                return 1
                ;;
        esac
    done
    
    # Get the last command from history (excluding cmdsnap itself)
    local cmd=""
    local history_list=(${(f)"$(fc -l -n -50)"})
    
    for ((i=${#history_list[@]}; i>=1; i--)); do
        local entry="${history_list[$i]}"
        # Trim leading whitespace
        entry="${entry#"${entry%%[![:space:]]*}"}"
        if [[ "$entry" != cmdsnap* ]] && [[ -n "$entry" ]]; then
            cmd="$entry"
            break
        fi
    done
    
    if [[ -z "$cmd" ]]; then
        echo "No command found in history."
        return 1
    fi
    
    # Re-run the command to capture output
    echo "Capturing: $cmd"
    echo "---"
    local output
    output=$(eval "$cmd" 2>&1)
    local exit_code=$?
    echo "$output"
    
    # Save output
    echo "$output" > "$CMDSNAP_LAST_OUTPUT_FILE"
    
    # Format the result
    local result=""
    
    case "$format" in
        markdown)
            result="\`\`\`\n\$ ${cmd}\n"
            if [[ -n "$output" ]]; then
                result+="${output}\n"
            fi
            result+="\`\`\`"
            ;;
        plain)
            result="\$ ${cmd}"
            if [[ -n "$output" ]]; then
                result+="\n${output}"
            fi
            ;;
    esac
    
    # Copy to clipboard
    if command -v pbcopy &> /dev/null; then
        printf '%b' "$result" | pbcopy
        echo ""
        echo "✓ Copied to clipboard!"
    elif command -v xclip &> /dev/null; then
        printf '%b' "$result" | xclip -selection clipboard
        echo ""
        echo "✓ Copied to clipboard!"
    elif command -v xsel &> /dev/null; then
        printf '%b' "$result" | xsel --clipboard --input
        echo ""
        echo "✓ Copied to clipboard!"
    elif command -v clip.exe &> /dev/null; then
        printf '%b' "$result" | clip.exe
        echo ""
        echo "✓ Copied to clipboard!"
    else
        echo ""
        echo "No clipboard tool found. Output:"
        printf '%b\n' "$result"
        return 1
    fi
}
