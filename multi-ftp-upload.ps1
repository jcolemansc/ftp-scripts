# Load the WinSCP .NET assembly
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

# Set up the session options
$sessionOptions = New-Object WinSCP.SessionOptions
$sessionOptions.Protocol = [WinSCP.Protocol]::Ftp
$sessionOptions.HostName = "ftp.example.com"
$sessionOptions.UserName = "ftpuser"
$sessionOptions.Password = "ftppassword"

$session = New-Object WinSCP.Session
$session.SessionLogPath = "C:\example\session.log"

# Connect to the FTP server
try {
    $session.Open($sessionOptions)
    Write-Host "Connected to FTP server" -ForegroundColor Green
} catch {
    Write-Host "Error connecting to FTP server: $_" -ForegroundColor Red
}

$mainFolder = "D:\Shares\vod1\AdInsert\Production\ads\jc\"
$currentDate = Get-Date
$tenMinutesAgo = $currentDate.AddMinutes(-10)

# Search for files in subfolders under main folder
$files = Get-ChildItem -Path $mainFolder -Recurse -File | Where-Object { $_.LastWriteTime -lt $tenMinutesAgo }

foreach ($file in $files)
{
    if (Test-Path $file.FullName) {
        # Upload the file
        try {
            $session.PutFiles($file.FullName).Check()
            Write-Host "Uploaded file $($file.FullName) to FTP server" -ForegroundColor Green
        } catch {
            Write-Host "Error uploading file $($file.FullName) to FTP server: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "File $($file.FullName) does not exist or is not accessible" -ForegroundColor Red
    }
}

# Disconnect from the FTP server
$session.Dispose()
