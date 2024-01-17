param(
    [Parameter][bool]$cicd_ado = $false,
    [Parameter][string]$terraform_plan_file = "terraform.tfbackend",
    [string]$output_folder = "" # No trailing slash please :)
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

$terraform_output = terraform output -json
$output_object = $terraform_output | ConvertFrom-Json -Depth 100

$tfstate_file = $output_object.tfstate_file.value

if($tfstate_file -eq $null){
    Write-Error "Unable to find tfstate_file in terraform output"
    exit 1
}

$tfstate_out = @()
foreach($key in $tfstate_file.PSObject.Properties.Name){
    if($key -in $valid_backend_outputs){
        # Terraform likes true and false, PowerShell likes $True and $False. Terraform does not like True or False.
        $value = $tfstate_file.$key.GetType() -eq [System.Boolean] ? $tfstate_file.$key.ToString().ToLower() : $tfstate_file.$key
        $line_item = "{0} = `"{1}`"" -f $key, $value
        $tfstate_out += $line_item
        Write-Verbose $line_item -Verbose
    } else {
        Write-Warning "Unknown backend output: $key" -Verbose
    }
}

$folder = $output_folder -and $output_folder -ne "" ? $output_folder : (Get-Location).Path
Write-Verbose "Writing terraform.tfstate file to $folder" -Verbose
$tfstate_out | Out-File -FilePath "$folder/$terraform_plan_file" -Encoding utf8 -Force