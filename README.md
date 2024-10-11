# FLAC to ALAC Converter

This PowerShell script automates the conversion of FLAC files to ALAC (Apple Lossless Audio Codec) format using FFmpeg. It supports multithreading and utilizes up to 75% of available CPU threads for optimal performance. The script also checks if FFmpeg is installed, and if not, prompts the user to install it using `winget`.

## Features

- **FFmpeg Auto-Installation**: If FFmpeg is not installed on the system, the script will prompt the user to install it using `winget`.
- **Parallel Processing**: Converts FLAC files in parallel using up to 75% of the system’s available CPU threads.
- **Directory Structure Preservation**: Converts FLAC files from the input directory and saves the ALAC files in a specified output directory while preserving the folder structure.
- **Error Handling**: The script logs success or failure for each file, providing clear feedback on the conversion process.

## Requirements

- **PowerShell**: Version 5.0 or later.
- **FFmpeg**: If not installed, the script can install it via `winget`.
- **Windows 10**: Required for `winget` support.
- **winget**: (If needed for FFmpeg installation) Pre-installed on Windows 10/11 or can be installed manually.

## Installation

### Prerequisites

1. Ensure **PowerShell 5.0** or later is installed on your system.
2. If FFmpeg is not installed, the script will prompt you to install it using `winget`.

### Input and Output Directory Structure

- **Input**: The script expects the FLAC files to be in a directory named `0_flac`.
- **Output**: The script will create a directory named `1_alac` where the converted ALAC files will be saved.

### Steps

1. Download or clone this repository.
2. Place your FLAC files inside the `0_flac` directory.
3. Run the script in **PowerShell**.

## Usage

1. Open **PowerShell** in the folder where the script is located.
2. Run the script using:

   ```powershell
   ./flac2alac.ps1
   ```

3. If FFmpeg is not installed, the script will prompt you to install it via `winget`. Follow the instructions to proceed.

4. The script will begin converting all FLAC files in the `0_flac` directory to ALAC format and save them in the `1_alac` directory.

## Example

If you have the following directory structure:

```makefile
C:\Users\YourName\Music\flac2alac\
    ├── 0_flac\
    │   ├── Album1\
    │   │   ├── Track1.flac
    │   │   ├── Track2.flac
    │   ├── Album2\
    │   │   ├── Track1.flac
    │   │   ├── Track2.flac
```

After running the script, the output directory (`1_alac`) will have the converted files:

```makefile
C:\Users\YourName\Music\flac2alac\
    ├── 1_alac\
    │   ├── Album1\
    │   │   ├── Track1.m4a
    │   │   ├── Track2.m4a
    │   ├── Album2\
    │   │   ├── Track1.m4a
    │   │   ├── Track2.m4a
```

## Multithreading

The script automatically calculates 75% of your system's available CPU threads and uses them to run conversions in parallel for maximum efficiency.

## Error Handling

- If FFmpeg is not installed and the user declines installation, the script will terminate.
- If an error occurs during the conversion of a file, the script will log it as "error" and continue processing other files.

## Limitations

- The script is designed to run on Windows 10 or later due to the use of `winget` for FFmpeg installation.
- It is expected that `winget` is installed and available on the system. If `winget` is missing, the script cannot automatically install FFmpeg.

## Contributing

Feel free to fork the repository and submit pull requests for any features, bug fixes, or improvements you would like to contribute.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Author

This script was developed by **blackbunt** with help from **github copilot**.
