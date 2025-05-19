# Get profiles dynamically from the profiles directory
$profiles = @{}
$profilesDir = $PSScriptRoot
$profileFolders = Get-ChildItem -Path $profilesDir -Directory

# Create a numbered mapping of profiles
$index = 1
foreach ($folder in $profileFolders) {
    $profiles[$index.ToString()] = $folder.Name
    $index++
}

function Show-Profiles {
    Write-Host "`nAvailable Profiles:"
    Write-Host "----------------"
    foreach ($key in $profiles.Keys) {
        Write-Host "$key - $($profiles[$key])"
    }
    Write-Host "----------------`n"
}

function Apply-Profile {
    param (
        [string]$profileKey
    )

    if (-not $profiles.ContainsKey($profileKey)) {
        Write-Host "Invalid profile selection!"
        return
    }

    $profileName = $profiles[$profileKey]
    $sourcePath = Join-Path $PSScriptRoot "$profileName"
    $destinationPath = "$env:USERPROFILE"

    if (-not (Test-Path $sourcePath)) {
        Write-Host "Profile directory does not exist: $sourcePath"
        return
    }

    try {
        $appliedFiles = 0

        # Apply komorebi.json if it exists in the profile
        $jsonFile = Join-Path $sourcePath "komorebi.json"
        if (Test-Path $jsonFile) {
            Copy-Item -Path $jsonFile -Destination $destinationPath -Force
            Write-Host "Applied komorebi.json to $destinationPath"
            $appliedFiles++
        }

        # Apply all komorebi.bar.* files
        $barFiles = Get-ChildItem -Path $sourcePath -Filter "komorebi.bar.*" -File
        if ($barFiles) {
            foreach ($file in $barFiles) {
                Copy-Item -Path $file.FullName -Destination $destinationPath -Force
                Write-Host "Applied $($file.Name) to $destinationPath"
                $appliedFiles++
            }
        }

        if ($appliedFiles -gt 0) {
            Write-Host "`n$profileName profile successfully applied to computer!"

            # Ask if user wants to restart komorebi
            $restart = Read-Host "`nDo you want to restart komorebi to apply changes? (y/n)"
            if ($restart -eq "y") {
                Write-Host "Restarting komorebi..."
                # Kill komorebi process if running
                Get-Process -Name "komorebi" -ErrorAction SilentlyContinue | Stop-Process
                # Start komorebi
                Start-Process "komorebi" -ArgumentList "start" -NoNewWindow
            }
        } else {
            Write-Host "`nNo files found in the profile to apply!"
        }
    }
    catch {
        Write-Host "Error applying profile: $_"
    }
}

function Main {
    # Check if any profiles exist
    if ($profiles.Count -eq 0) {
        Write-Host "No profiles found in the profiles directory!"
        return
    }

    # Show available profiles
    Show-Profiles

    # Get profile selection
    $profileSelection = Read-Host "Select profile to apply (1-$($profiles.Count))"

    # Apply selected profile
    Apply-Profile -profileKey $profileSelection
}

# Run the main function
Main