# Get profiles dynamically from the profiles directory
$profiles = @{}
$profilesDir = Join-Path $PSScriptRoot "profiles"
$profileFolders = Get-ChildItem -Path $profilesDir -Directory

# Create a numbered mapping of profiles
$index = 1
foreach ($folder in $profileFolders) {
    $profiles[$index.ToString()] = $folder.Name
    $index++
}

function _Show-Profiles {
    Write-Host "`nAvailable Profiles:"
    Write-Host "----------------"
    foreach ($key in $profiles.Keys) {
        Write-Host "$key - $($profiles[$key])"
    }
    Write-Host "----------------`n"
}

function _Apply-Profile {
    param (
        [string]$profileKey
    )

    if (-not $profiles.ContainsKey($profileKey)) {
        Write-Host "Invalid profile selection!"
        return
    }

    $profileName = $profiles[$profileKey]
    $sourcePath = Join-Path $profilesDir "$profileName"
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

        # Apply whkdrc file
        $whkdrcFile = Join-Path $profilesDir "whkdrc"
        if (Test-Path $whkdrcFile) {
            $whkdrcDestPath = "$env:USERPROFILE\.config"
            Copy-Item -Path $whkdrcFile -Destination "$env:USERPROFILE\.config"
            Write-Host "Applied whkdrc file to $whkdrcDestPath"
        }

        if ($appliedFiles -gt 0) {
            Write-Host "`n$profileName profile successfully applied to computer!"
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
    _Show-Profiles

    # Get profile selection
    $profileSelection = Read-Host "Which profile do you to apply to this computer? [1-$($profiles.Count)]"

    # Apply selected profile
    _Apply-Profile -profileKey $profileSelection
}

# Run the main function
Main