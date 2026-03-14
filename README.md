# cmdsnap

Capture terminal commands and their output for easy sharing. Perfect for documentation, bug reports, and tutorials.

## Installation

### Homebrew (macOS/Linux)

```bash
brew install marioschiras/cmdsnap/cmdsnap
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/marioschiras/cmdsnap.git ~/.cmdsnap

# Add to your .zshrc
echo 'source ~/.cmdsnap/integrations/zsh.cmdsnap.zsh' >> ~/.zshrc

# Reload your shell
source ~/.zshrc
```

### Zsh Plugin Managers

**zinit:**
```bash
zinit light marioschiras/cmdsnap
```

**antigen:**
```bash
antigen bundle marioschiras/cmdsnap
```

**zplug:**
```bash
zplug "marioschiras/cmdsnap"
```

## Usage

```bash
cmdsnap            # Capture the last command and its output
cmdsnap 3          # Capture the last 3 commands
cmdsnap list       # Show recent commands with numbers
cmdsnap @2         # Capture specific command #2 from list
cmdsnap @1 @4      # Capture multiple specific commands
```

### Options

| Option | Description |
|--------|-------------|
| `-p, --plain` | Plain text format (no markdown code block) |
| `-l, --list, list` | Show recent commands |
| `-h, --help, help` | Show help |

## Examples

### Capture the last command

```bash
$ ls -la
$ cmdsnap
Capturing 1 command(s)...
---
→ ls -la
total 0
drwxr-xr-x  3 user  staff  96 Jan  1 12:00 .
drwxr-xr-x  5 user  staff 160 Jan  1 12:00 ..

✓ Copied to clipboard!
```

The clipboard now contains:

~~~
```
$ ls -la
total 0
drwxr-xr-x  3 user  staff  96 Jan  1 12:00 .
drwxr-xr-x  5 user  staff 160 Jan  1 12:00 ..
```
~~~

### List and select specific commands

```bash
$ cmdsnap list
Recent commands:

  @1  git status
  @2  npm install
  @3  cat package.json
  @4  ls -la

Use 'cmdsnap @N' to capture a specific command

$ cmdsnap @2 @4    # Captures npm install and ls -la
```

## How It Works

1. `cmdsnap` looks at your shell history
2. Re-runs the selected command(s) to capture fresh output
3. Formats the result as a markdown code block
4. Copies everything to your clipboard

## Requirements

- Zsh shell
- One of: `pbcopy` (macOS), `xclip`, `xsel` (Linux), or `clip.exe` (WSL)

## License

MIT
