$ErrorActionPreference = "Stop"

$ContribPath = "./data/contribution"
$SrcFiles = Get-ChildItem -Path "./data/" -Include "*.pak", "*.sig"
$PathFile = "./path.txt"
$VngFiles = @("VNGLogo-WindowsClient.sig", "VNGLogo-WindowsClient.pak")
$CopyFilesList = @("MatureData-WindowsClient.sig", "MatureData-WindowsClient.pak")

function ContributionPrint {
    param([string]$Path)

    if (-Not (Test-Path $Path)) {
        Write-Host "Introduction file not found"
        exit 1
    }

    Get-Content $Path
    Write-Host "Do you wish to continue? (Y/N - Y is default, auto-continue in 5 seconds)"

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    while ($stopwatch.Elapsed.TotalSeconds -lt 5) {
        if ([console]::KeyAvailable) {
            $key = [console]::ReadKey($true).Key
            if ($key -eq "N") {
                Write-Host "Thank you for using the script."
                exit 0
            } elseif ($key -eq "Y") {
                break
            }
        }
        Start-Sleep -Milliseconds 200
    }
    Write-Host "Continuing with default option (Y)."
}

function ValidatePaths {
    param([string[]]$Paths)
    
    foreach ($Path in $Paths) {
        if (-Not (Test-Path $Path)) {
            Write-Host "Data is missing: $Path. Please download the zip again."
            exit 1
        }
    }
}

function GetDestinationPath {
    if (-Not (Test-Path $PathFile)) {
        Write-Host "Path file not found"
        exit 1
    }

    $DestinationPath = (Get-Content $PathFile | Select-Object -First 1).Trim()
    if (-Not (Test-Path $DestinationPath -PathType Container)) {
        Write-Host "Destination path not found: $DestinationPath. Please check the path.txt file."
        exit 1
    }
    return $DestinationPath
}

function CopyFiles {
    param([string]$DestinationPath, [string[]]$Files)
    
    foreach ($File in $Files) {
        $FilePath = Join-Path "./data/" $File
        if (Test-Path $FilePath) {
            try {
                Copy-Item -Force -Path $FilePath -Destination $DestinationPath -ErrorAction Stop
                Write-Host "Copied: $File"
            } catch {
                Write-Host "Failed to copy: $File. Error: $_"
            }
        } else {
            Write-Host "File not found, skipping: $File"
        }
    }
    Write-Host "File copy process completed."
}

function RemoveFiles {
    param([string]$DestinationPath, [string[]]$Files)
    
    foreach ($File in $Files) {
        $FilePath = Join-Path $DestinationPath $File
        if (Test-Path $FilePath) {
            Remove-Item -Force $FilePath
            Write-Host "Removed: $File"
        } else {
            Write-Host "File not found, skipping: $File"
        }
    }
}

function Main {
    ContributionPrint -Path $ContribPath
    ValidatePaths -Paths $SrcFiles
    $DestinationPath = GetDestinationPath
    
    CopyFiles -DestinationPath $DestinationPath -Files $CopyFilesList
    RemoveFiles -DestinationPath $DestinationPath -Files $VngFiles
    
    Write-Host "Script executed successfully. Exiting..."
    exit 0
}

Main
