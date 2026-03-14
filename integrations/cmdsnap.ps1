# cmdsnap - Copy terminal commands to clipboard (PowerShell version)
# To install: Add this to your PowerShell profile or dot-source it

function Get-CmdSnapHistory {
    param([int]$Max = 10)
    
    $history = Get-History | Where-Object { $_.CommandLine -notmatch '^cmdsnap' } | 
               Select-Object -Last 50 | 
               Sort-Object -Property Id -Descending |
               Select-Object -First $Max
    
    return $history
}

function cmdsnap {
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )
    
    $format = "markdown"
    $selectedIndices = @()
    $count = 0
    $showList = $false
    
    foreach ($arg in $Args) {
        switch -Regex ($arg) {
            '^(-p|--plain)$' {
                $format = "plain"
            }
            '^(list|-l|--list)$' {
                $showList = $true
            }
            '^(help|-h|--help)$' {
                Write-Host "cmdsnap - Copy terminal commands to clipboard"
                Write-Host ""
                Write-Host "Usage:"
                Write-Host "  cmdsnap            Copy the last command"
                Write-Host "  cmdsnap N          Copy the last N commands"
                Write-Host "  cmdsnap @N         Copy specific command #N from list"
                Write-Host "  cmdsnap @1 @3      Copy multiple specific commands"
                Write-Host "  cmdsnap list       Show recent commands with numbers"
                Write-Host ""
                Write-Host "Options:"
                Write-Host "  -p, --plain        Plain text (no code block)"
                Write-Host "  -l, list           Show recent commands"
                Write-Host "  -h, help           Show this help"
                return
            }
            '^@(\d+)\.\.@(\d+)$' {
                $start = [int]$Matches[1]
                $end = [int]$Matches[2]
                for ($n = $start; $n -le $end; $n++) {
                    $selectedIndices += $n
                }
            }
            '^@(\d+)$' {
                $selectedIndices += [int]$Matches[1]
            }
            '^\d+$' {
                $count = [int]$arg
            }
            default {
                if ($arg) {
                    Write-Host "Unknown option: $arg. Use 'cmdsnap help' for usage."
                    return
                }
            }
        }
    }
    
    # Get history
    $historyCommands = @(Get-CmdSnapHistory -Max 10)
    
    if ($historyCommands.Count -eq 0) {
        Write-Host "No commands found in history."
        return
    }
    
    # Show list mode
    if ($showList) {
        Write-Host "Recent commands:"
        Write-Host ""
        for ($i = 0; $i -lt $historyCommands.Count; $i++) {
            $idx = $i + 1
            $cmd = $historyCommands[$i].CommandLine
            Write-Host ("  @{0}  {1}" -f $idx, $cmd)
        }
        Write-Host ""
        Write-Host "Use 'cmdsnap @N' to copy a specific command"
        return
    }
    
    # Determine which commands to copy
    $commandsToCopy = @()
    
    if ($selectedIndices.Count -gt 0) {
        foreach ($idx in $selectedIndices) {
            if ($idx -ge 1 -and $idx -le $historyCommands.Count) {
                $commandsToCopy += $historyCommands[$idx - 1].CommandLine
            } else {
                Write-Host "Invalid index: @$idx (only $($historyCommands.Count) commands available)"
                return
            }
        }
    } elseif ($count -gt 0) {
        $take = [Math]::Min($count, $historyCommands.Count)
        for ($i = $take - 1; $i -ge 0; $i--) {
            $commandsToCopy += $historyCommands[$i].CommandLine
        }
    } else {
        $commandsToCopy += $historyCommands[0].CommandLine
    }
    
    # Build result
    if ($format -eq "markdown") {
        $result = "``````n" + ($commandsToCopy -join "`n") + "`n``````"
    } else {
        $result = $commandsToCopy -join "`n"
    }
    
    # Copy to clipboard
    try {
        Set-Clipboard -Value $result
        Write-Host ("✓ Copied {0} command(s) to clipboard!" -f $commandsToCopy.Count)
    } catch {
        Write-Host "Failed to copy to clipboard. Output:"
        Write-Host $result
    }
}

# Export the function
Export-ModuleMember -Function cmdsnap -ErrorAction SilentlyContinue
