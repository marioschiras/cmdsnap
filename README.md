# cmdsnap

Capture terminal commands for easy sharing. Perfect for documentation, bug reports, and tutorials.

## Installation

### macOS/Linux

**Homebrew:**
```bash
brew install marioschiras/cmdsnap/cmdsnap
cmdsnap-setup
source ~/.zshrc
```

**Manual:**
```bash
git clone https://github.com/marioschiras/cmdsnap.git ~/.cmdsnap
echo 'source ~/.cmdsnap/integrations/zsh.cmdsnap.zsh' >> ~/.zshrc
source ~/.zshrc
```

**Zsh Plugin Managers:**
```bash
# zinit
zinit light marioschiras/cmdsnap

# antigen
antigen bundle marioschiras/cmdsnap

# zplug
zplug "marioschiras/cmdsnap"
```

### Windows (PowerShell)

**One-line install:**
```powershell
irm https://raw.githubusercontent.com/marioschiras/cmdsnap/master/install.ps1 | iex
```

**Manual:**
```powershell
# Create directory and download
mkdir "$env:USERPROFILE\.cmdsnap" -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/marioschiras/cmdsnap/master/integrations/cmdsnap.ps1" -OutFile "$env:USERPROFILE\.cmdsnap\cmdsnap.ps1"

# Add to your PowerShell profile
Add-Content $PROFILE '. "$env:USERPROFILE\.cmdsnap\cmdsnap.ps1"'

# Restart PowerShell or run:
. $PROFILE
```

## Usage

```bash
cmdsnap            # Copy the last command
cmdsnap 3          # Copy the last 3 commands
cmdsnap list       # Show recent commands with numbers
cmdsnap @2         # Copy specific command #2 from list
cmdsnap @1 @4      # Copy multiple specific commands
cmdsnap @2..@5     # Copy commands #2 through #5
```

### Options

| Option | Description |
|--------|-------------|
| `-p, --plain` | Plain text format (no markdown code block) |
| `-l, --list, list` | Show recent commands |
| `-h, --help, help` | Show help |

## Examples

### Copy the last command

```
$ git status
$ cmdsnap
✓ Copied 1 command(s) to clipboard!
```

The clipboard now contains:

~~~
```
git status
```
~~~

### List and select specific commands

```
$ cmdsnap list
Recent commands:

  @1  git status
  @2  npm install
  @3  cat package.json
  @4  ls -la

Use 'cmdsnap @N' to copy a specific command

$ cmdsnap @2 @4
✓ Copied 2 command(s) to clipboard!
```

## How It Works

1. `cmdsnap` retrieves commands from your shell history
2. Formats them as a markdown code block
3. Copies to your clipboard

## Requirements

**macOS/Linux:**
- Zsh shell
- Clipboard tool: `pbcopy` (macOS), `xclip`, `xsel` (Linux), or `clip.exe` (WSL)

**Windows:**
- PowerShell 5.1+ or PowerShell Core

## License

MIT
