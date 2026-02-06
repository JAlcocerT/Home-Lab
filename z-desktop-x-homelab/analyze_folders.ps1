<#
.SYNOPSIS
    Analyzes disk usage for the top-level folders in the user directory.

.DESCRIPTION
    This script scans the directory C:\Users\j--e-, calculates the total size of each top-level folder
    (including all subdirectories and files), and outputs the top 50 largest folders to 'top_folders.txt'.

.HOW_TO_RUN
    1. Open PowerShell (search for 'PowerShell' in the Start menu).
    2. Navigate to this directory:
       cd "C:\Users\j--e-\Desktop\Home-Lab\z-desktop-x-homelab"
    3. (Optional) Run as Administrator for more accurate results if restricted folders are encountered.
    4. Run the script:
       .\analyze_folders.ps1
    5. Check 'top_folders.txt' in this directory for results.
#>

$targetPath = "C:\Users\"
Write-Host "Scanning $targetPath... This may take a moment." -ForegroundColor Cyan

$results = Get-ChildItem -Path $targetPath -Directory -Force | ForEach-Object {
    $currentFolder = $_.FullName
    Write-Host "Analyzing: $currentFolder" -ForegroundColor DarkGray
    try {
        $files = Get-ChildItem -Path $currentFolder -Recurse -File -ErrorAction SilentlyContinue
        $size = ($files | Measure-Object -Property Length -Sum).Sum
        if ($null -eq $size) { $size = 0 }
        [PSCustomObject]@{
            FolderName = $currentFolder
            SizeGB = [Math]::Round($size / 1GB, 4)
            SizeBytes = $size
        }
    } catch {
        # Handle access denied or other errors by reporting 0 size
        [PSCustomObject]@{
            FolderName = $currentFolder
            SizeGB = 0
            SizeBytes = 0
        }
    }
}

$topResults = $results | Sort-Object SizeBytes -Descending | Select-Object -First 50

# Output to console
$topResults | Format-Table -AutoSize

# Save to file
$topResults | Format-Table -AutoSize | Out-File -FilePath "top_folders.txt"

Write-Host "`nAnalysis complete! Results saved to: top_folders.txt" -ForegroundColor Green
