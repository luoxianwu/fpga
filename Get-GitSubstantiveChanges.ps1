# Get a list of all currently modified files reported by git status
# --porcelain provides a stable, machine-readable format
# Substring(3) removes the status code (e.g., " M ") from the start of each line
$modifiedFiles = (git status --porcelain) | ForEach-Object { $_.Substring(3) }

# Initialize an empty array to store files with substantive changes
$substantiveChangeFiles = @()

foreach ($file in $modifiedFiles) {
    # Perform a diff for the current file, ignoring all whitespace differences.
    # --quiet suppresses the diff output itself.
    # --exit-code makes git diff return 0 if no differences (after ignoring whitespace),
    #   and 1 if substantive differences were found.
    # 2>$null redirects stderr (where warnings about line endings go) to null, suppressing them.
    git diff --quiet --ignore-all-space "$file" 2>$null

    # Check the exit code of the 'git diff' command.
    # If $LASTEXITCODE is 1, it means 'git diff' found substantive changes
    # that were NOT just whitespace/line endings.
    if ($LASTEXITCODE -eq 1) {
        # Add the file name to our array
        $substantiveChangeFiles += $file
    }
}

Write-Host "Files with actual content changes (excluding ALL whitespace differences):"
Write-Host "---------------------------------------------------------------------------------"

# Check if the array of substantive change files has any elements
if ($substantiveChangeFiles.Count -gt 0) {
    # Print each file name from the collected array.
    # PowerShell will automatically print each element on a new line when piping to Write-Host,
    # or you can just let it print the array directly for a similar effect.
    $substantiveChangeFiles | ForEach-Object { Write-Host $_ }
} else {
    # If the array is empty, print the message indicating no substantive changes
    Write-Host "No files found with substantive changes (all changes were only whitespace/line endings)."
}

Write-Host "`nScript finished."

# --- New Function to Prompt and Add to Git ---
function PromptAndAddSubstantiveFiles {
    param(
        [Parameter(Mandatory=$true)]
        [array]$FilesToAdd
    )

    if ($FilesToAdd.Count -eq 0) {
        Write-Host "No files with substantive changes to add to Git." -ForegroundColor Cyan
        return
    }

    Write-Host "`nDo you want to add the following files to Git staging?" -ForegroundColor Yellow
    Write-Host "-------------------------------------------------------"
    $FilesToAdd | ForEach-Object { Write-Host "  - $_" }
    Write-Host "-------------------------------------------------------"

    $response = Read-Host "Type 'yes' to add all listed files, or anything else to skip."

    if ($response -eq 'yes' -or $response -eq 'Yes' -or $response -eq 'YES') {
        Write-Host "`nAdding files to Git staging..." -ForegroundColor Green
        foreach ($file in $FilesToAdd) {
            git add "$file"
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  Successfully added '$file'." -ForegroundColor DarkGreen
            } else {
                Write-Host "  Failed to add '$file'." -ForegroundColor Red
            }
        }
        Write-Host "All substantive files processed." -ForegroundColor Green
    } else {
        Write-Host "Skipping adding files to Git staging." -ForegroundColor Yellow
    }
}

# Call the new function at the end of the script
PromptAndAddSubstantiveFiles -FilesToAdd $substantiveChangeFiles
