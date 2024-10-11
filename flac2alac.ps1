###############################################################################
# Title: FLAC to ALAC Converter
# Description:
#   This PowerShell script automates the conversion of FLAC files to ALAC format
#   using FFmpeg. The script checks if FFmpeg is installed on the system, and if 
#   not, it prompts the user to install it via `winget`. If installation is 
#   successful, the script processes all FLAC files in the specified input 
#   directory, converting them to ALAC format. The conversion is multithreaded, 
#   utilizing up to 75% of available CPU threads for optimal performance.
#
# Features:
#   - Automatically checks for and installs FFmpeg using `winget` if necessary.
#   - Converts FLAC files to ALAC format using the ALAC codec.
#   - Parallel processing using up to 75% of the available CPU threads.
#   - Creates necessary directory structures for output files.
#   - Displays the conversion status for each file (success or error).
#
# Usage:
#   - Place the script in the same directory as your FLAC files.
#   - The FLAC files should be stored in a directory named `0_flac`.
#   - The script creates an output directory named `1_alac` where converted 
#     ALAC files will be stored.
#   - Run the script from the PowerShell terminal.
#
# Parameters: 
#   - None. The script automatically detects the input and output directories.
#
# Error Handling:
#   - If FFmpeg is not installed and the user declines installation, the script 
#     will exit.
#   - The script checks for errors during the conversion process and logs whether 
#     the conversion was successful or failed.
#
# Multithreading:
#   - The script calculates the available CPU threads and utilizes 75% of them 
#     to run concurrent file conversions for better performance.
#
# Requirements:
#   - PowerShell 5.0 or later
#   - FFmpeg (if not installed, the script can install it using `winget`)
#   - Windows 10 or later (required for `winget`)
#
# Author: blackbunt
# Version: 1.0
# Last Updated: 2024-10-11
###############################################################################

# ASCII Art for flac2alac
Write-Host "
  __ _            ____       _            
 / _| | __ _  ___|___ \ __ _| | __ _  ___ 
| |_| |/ _' |/ __| __) / _' | |/ _' |/ __|
|  _| | (_| | (__ / __/ (_| | | (_| | (__ 
|_| |_|\__,_|\___|_____\__,_|_|\__,_|\___|

            Version 1.0
            by blackbunt
" -ForegroundColor Cyan

###############################################################################
# Function: Write-Status
# Description: Outputs the conversion status (either success or error) with 
#              colored text. 
# Parameters:
#   - $status: The status of the conversion, either "success" or "error".
#   - $message: The message to display, typically the file name and status.
###############################################################################
function Write-Status {
    param (
        [string]$status,
        [string]$message
    )

    switch ($status) {
        "success" { Write-Host "$message ok" -ForegroundColor Green } # Successfully converted
        "error" { Write-Host "$message error" -ForegroundColor Red }  # Conversion failed
    }
}

###############################################################################
# Function: Ensure-FFmpegInstalled
# Description: Checks if FFmpeg is installed on the system. If not, prompts the
#              user to install it via `winget`. Exits the script if FFmpeg is
#              not installed and the user does not choose to install it.
# Error Handling:
#   - Exits the script if FFmpeg cannot be installed or the user declines.
###############################################################################
function Ensure-FFmpegInstalled {
    # Check if FFmpeg is installed
    if (!(Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
        Write-Host "FFmpeg is not installed." -ForegroundColor Red
        $response = Read-Host "Would you like to install ffmpeg using winget? (y/n)"
        
        # If the user chooses to install FFmpeg
        if ($response -eq "y") {
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                Write-Host "Installing FFmpeg with winget..." -ForegroundColor Yellow
                winget install -e --id Gyan.FFmpeg
                
                # Verify installation
                if (!(Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
                    Write-Host "FFmpeg could not be installed. Please check the installation manually." -ForegroundColor Red
                    exit 1
                } else {
                    Write-Host "FFmpeg was successfully installed." -ForegroundColor Green
                }
            } else {
                # Winget is not installed
                Write-Host "winget is not installed. Please install FFmpeg manually." -ForegroundColor Red
                exit 1
            }
        } else {
            # Exit if the user chooses not to install FFmpeg
            Write-Host "FFmpeg must be installed to proceed. Exiting the script." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "FFmpeg is already installed." -ForegroundColor Green
    }
}

###############################################################################
# Calculate 75% of the available CPU threads for parallel processing.
# This determines the maximum number of jobs that can run concurrently.
###############################################################################
$logicalProcessors = (Get-CimInstance -ClassName Win32_Processor).NumberOfLogicalProcessors
$maxJobs = [math]::Floor($logicalProcessors * 0.75)

Write-Host "Max parallel jobs based on 75% of available CPU threads: $maxJobs" -ForegroundColor Yellow

###############################################################################
# Define input and output directories
# - $scriptDir: The directory where the script is located.
# - $inputDir: The input directory containing FLAC files.
# - $outputDir: The output directory where ALAC files will be saved.
###############################################################################
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$inputDir = Join-Path $scriptDir "0_flac"
$outputDir = Join-Path $scriptDir "1_alac"

# Check if the input directory exists
if (!(Test-Path -Path $inputDir)) {
    Write-Host "Error: The input directory does not exist: $inputDir" -ForegroundColor Red
    exit 1
}

# Get all FLAC files in the input directory and its subdirectories
$flacFiles = Get-ChildItem -Path $inputDir -Recurse -Filter *.flac
$totalFiles = $flacFiles.Count

# If no FLAC files are found, exit the script
if ($totalFiles -eq 0) {
    Write-Host "No FLAC files were found in the input directory." -ForegroundColor Yellow
    exit 0
}

# Ensure FFmpeg is installed before proceeding with file conversions
Ensure-FFmpegInstalled

# FFMPEG path (assuming ffmpeg is in the PATH)
$ffmpeg = "ffmpeg"

# Variable to store all background jobs for parallel processing
$jobs = @()

###############################################################################
# Main conversion loop: Convert each FLAC file to ALAC in parallel.
# Uses multithreading to convert up to the maxJobs concurrently.
###############################################################################
$fileIndex = 1
foreach ($file in $flacFiles) {
    $inputFile = $file.FullName

    # Create the relative path from the input directory for output
    $relativePath = $file.FullName.Substring($inputDir.Length + 1)

    # Set the output subdirectory path correctly
    $outputSubDir = Join-Path $outputDir $file.DirectoryName.Substring($inputDir.Length)

    # Create the output subdirectory if it doesn't exist
    if (!(Test-Path -Path $outputSubDir)) {
        New-Item -ItemType Directory -Path $outputSubDir -ErrorAction Stop
    }

    # Set the file path for the input and output files
    $outputFile = Join-Path $outputSubDir ($file.BaseName + ".m4a")

    # Start the conversion job as a background process
    $job = Start-Job -ScriptBlock {
        param ($inputFile, $outputFile, $ffmpeg, $relativePath, $fileIndex, $totalFiles)

        try {
            # FFmpeg command with the -y option to overwrite files
            $ffmpegOutput = & $ffmpeg -y -i $inputFile -vn -c:a alac $outputFile 2>&1
            if ($LASTEXITCODE -eq 0) {
                return @{status="success"; message="[$fileIndex/$totalFiles] $relativePath"}
            } else {
                return @{status="error"; message="[$fileIndex/$totalFiles] $relativePath"}
            }
        } catch {
            return @{status="error"; message="[$fileIndex/$totalFiles] $relativePath"}
        }
    } -ArgumentList $inputFile, $outputFile, $ffmpeg, $relativePath, $fileIndex, $totalFiles

    $jobs += $job

    # If the maximum number of jobs is reached, wait for one to complete
    while ($jobs.Count -ge $maxJobs) {
        $completedJobs = $jobs | Wait-Job -Any | ForEach-Object {
            $result = Receive-Job $_
            Write-Status -status $result.status -message $result.message
            Remove-Job $_
        }
        # Update jobs list to only include running jobs
        $jobs = $jobs | Where-Object { $_.State -eq 'Running' }
    }

    $fileIndex++
}

###############################################################################
# Wait for all remaining jobs to complete
###############################################################################
$jobs | ForEach-Object {
    $completedJob = $_ | Wait-Job | ForEach-Object {
        $result = Receive-Job $_
        Write-Status -status $result.status -message $result.message
        Remove-Job $_
    }
}

Write-Host "`nAll files have been processed." -ForegroundColor Green
