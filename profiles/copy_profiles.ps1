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

function _Show-Profiles {
    Write-Host "`nAvailable Profiles:"
    Write-Host "----------------"
    foreach ($key in $profiles.Keys) {
        Write-Host "$key - $($profiles[$key])"
    }
    Write-Host "----------------`n"
}

function _Copy-ToProfile {
    param (
        [string]$sourcePath,
        [string]$profileKey
    )

    if (-not $profiles.ContainsKey($profileKey)) {
        Write-Host "Invalid profile selection!"
        return
    }

    $profileName = $profiles[$profileKey]
    $destinationPath = Join-Path $PSScriptRoot "$profileName"

    # Create the destination directory if it doesn't exist
    if (-not (Test-Path $destinationPath)) {
        New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
    }

    try {
        # Get files from source path
        $jsonFile = Join-Path $sourcePath "komorebi.json"
        $barFiles = Get-ChildItem -Path $sourcePath -Filter "komorebi.bar.*" -File

        $copiedFiles = 0

        # Copy komorebi.json if it exists
        if (Test-Path $jsonFile) {
            Copy-Item -Path $jsonFile -Destination $destinationPath -Force
            Write-Host "Copied komorebi.json"
            $copiedFiles++
        }

        # Copy all komorebi.bar.* files
        if ($barFiles) {
            foreach ($file in $barFiles) {
                Copy-Item -Path $file.FullName -Destination $destinationPath -Force
                Write-Host "Copied $($file.Name)"
                $copiedFiles++
            }
        }

        if ($copiedFiles -gt 0) {
            Write-Host "`nFiles successfully copied to $profileName profile!"
        } else {
            Write-Host "`nNo matching files found in source directory to copy!"
        }
    }
    catch {
        Write-Host "Error copying files: $_"
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

    # Use a fixed source path (user's AppData folder)
    $sourcePath = "$env:USERPROFILE"

    if (-not (Test-Path $sourcePath)) {
        Write-Host "Source path does not exist: $sourcePath"
        return
    }

    # Get profile selection
    $profileSelection = Read-Host "Which profile will this be for? [1-$($profiles.Count)]"

    # Copy files to selected profile (Pass in source path and selected profile args)
    _Copy-ToProfile -sourcePath $sourcePath -profileKey $profileSelection
}

# Run the main function
Main
