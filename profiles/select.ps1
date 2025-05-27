# Get the current script path
$currentScriptPath = $MyInvocation.MyCommand.Path
$currentScriptName = Split-Path $currentScriptPath -Leaf

# Get all PS1 files in the current directory except this script
$scriptDir = Split-Path $currentScriptPath -Parent
$psScripts = Get-ChildItem -Path $scriptDir -Filter "*.ps1" | Where-Object { $_.Name -ne $currentScriptName }

# Create a numbered mapping of scripts
$scripts = @{}
$index = 1
foreach ($script in $psScripts) {
    $scripts[$index.ToString()] = $script.Name
    $index++
}

function _Show-Scripts {
    Write-Host "`nAvailable Scripts:"
    Write-Host "----------------"
    foreach ($key in $scripts.Keys) {
        Write-Host "$key - $($scripts[$key])"
    }
    Write-Host "----------------`n"
}

function Main {
    # Check if any scripts exist
    if ($scripts.Count -eq 0) {
        Write-Host "No PowerShell scripts found in this directory!"
        return
    }

    # Show available scripts
    _Show-Scripts

    # Get script selection
    $scriptSelection = Read-Host "Select a script to run (1-$($scripts.Count))"

    # Validate selection
    if (-not $scripts.ContainsKey($scriptSelection)) {
        Write-Host "Invalid selection!"
        return
    }

    # Get the selected script
    $selectedScriptName = $scripts[$scriptSelection]
    $selectedScriptPath = Join-Path $scriptDir $selectedScriptName

    # Run the selected script
    Write-Host "`nRunning $selectedScriptName...`n"
    try {
        & $selectedScriptPath
    }
    catch {
        Write-Host "Error running script: $_"
    }
}

# Run the main function
Main
