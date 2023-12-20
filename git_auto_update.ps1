# PowerShell Script for Git Operations with Logging and Error Handling

# Define the directory containing the git repository
$RepoDir = "<path>"
$MaxRetries = 3
$LogFile = "<path>"

# Function to log messages
function Log-Message {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogFile -Append
    Write-Host $Message
}

# Function to perform a Git operation with retries and logging
function Perform-GitOperation {
    param (
        [string]$GitCommand,
        [int]$RetryCount
    )

    $currentAttempt = 1
    while ($currentAttempt -le $RetryCount) {
        try {
            $operationMessage = "Attempt $currentAttempt $GitCommand"
            Log-Message $operationMessage

            $output = Invoke-Expression "git $GitCommand" 2>&1
            Log-Message $output
            return
        }
        catch {
            Log-Message "Error: $_"
            if ($currentAttempt -eq $RetryCount) {
                Log-Message "Failed after $RetryCount attempts."
                return
            }
            $currentAttempt++
            Start-Sleep -Seconds 5
        }
    }
}

# Navigate to the repository directory
Set-Location -Path $RepoDir

# Perform git pull first
Perform-GitOperation "pull" $MaxRetries

# Add all changes to the staging area
Perform-GitOperation "add -A" $MaxRetries

# Commit the changes with a message
Perform-GitOperation "commit -m 'New Notes'" $MaxRetries

# Perform git push
Perform-GitOperation "push" $MaxRetries
