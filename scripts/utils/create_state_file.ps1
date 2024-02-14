param(
    [bool]$cicd_ado = $false,
    [string]$terraform_plan_file = "terraform.tfbackend",
    [string]$output_folder = "", # No trailing slash please :)
    [string]$key = "terraform.tfstate"
)

$valid_backend_outputs = @(
    "resource_group_name",
    "storage_account_name",
    "container_name",
    "key",
    "use_msi",
    "tenant_id",
    "subscription_id",
    "use_oidc",
    "use_azuread_auth",
    "access_key",
    "sas_token"
)

if($cicd_ado) {
    $terraform_output = gci env:* | where-object {$_.Name -like "TF_OUTPUT_*"}
    $tfstate_out = @()
} else {
    $tfstate_out = $tf_output
}

if($cicd_ado){
    foreach($output in $terraform_output){
        $sanitized_key = $output.Name.Replace("TF_OUTPUT_", "").ToLower()
        if($sanitized_key -in $valid_backend_outputs){
            # Terraform likes true and false, PowerShell likes $True and $False. Terraform does not like True or False.
            $value = $output.Value -eq "True" ? "true" : $output.Value -contains "False" ? "false" : $output.Value
            $line_item = "{0} = `"{1}`"" -f $sanitized_key, $value
            $tfstate_out += $line_item
            Write-Verbose $line_item -Verbose
        } else {
            Write-Warning "Skipping output: $sanitized_key" -Verbose
        }
    }
}

if($tfstate_out | Where-Object {$_ -notlike "*$key*"}){
    $tfstate_out += "{0} = `"{1}`"" -f "key", $key
    Write-Verbose "key = `"$key`"" -Verbose
}

$folder = $output_folder -and $output_folder -ne "" ? $output_folder : (Get-Location).Path
Write-Verbose "Writing $key file to $folder" -Verbose
$tfstate_out | Out-File -FilePath "$folder/$terraform_plan_file" -Encoding ascii -Force