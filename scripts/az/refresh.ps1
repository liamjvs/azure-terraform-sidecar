Write-Verbose "Executing 'az account get-access-token'" -Verbose
$null = az account get-access-token
Write-Verbose "Refresing Azure CLI token" -Verbose