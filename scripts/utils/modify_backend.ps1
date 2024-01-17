param{
    [bool]$enable = $false,
    [bool]$disable = $false,
    [string]$backend_file = "backend.tf"
}

if($enable -and $disable){
    Write-Error "Cannot enable and disable at the same time"
    exit 1
}

if($enable){
    Write-Verbose "Enabling Terraform backend" -Verbose
    Write-Verbose "Setting $($backend_file)disabled to $($backend_file)" -Verbose
    $file = Get-Content "$($backend_file)disabled"
    if($file){
        # Rename the file
        Rename-Item "$($backend_file)disabled" $backend_file
    } else {
        Write-Error "Unable to read $backend_file"
        exit 1
    }
} elseif($disable){
    Write-Verbose "Disabling Terraform backend" -Verbose
    Write-Verbose "Setting $($backend_file) to $($backend_file)disabled" -Verbose
    $file = Get-Content "$($backend_file)"
    if($file){
        # Rename the file
        Rename-Item $backend_file "$($backend_file)disabled"
    } else {
        Write-Error "Unable to read $backend_file"
        exit 1
    }
} else {
    Write-Error "No action specified"
    exit 1
}