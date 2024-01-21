param(
    [bool]$cicd_ado = $true
)

$terraform_output = terraform output -json
$output_object = $terraform_output | ConvertFrom-Json -Depth 100

$tfoutput = $output_object.value

if($tfoutput -eq $null){
    Write-Error "Unable to find outputs in terraform output"
    exit 1
}

foreach($key in $tfoutput.PSObject.Properties.Name){
    $line_item = "{0} = `"{1}`"" -f $key, $tfoutput.$key.value
    if($cicd_ado){
        Write-Host ("##vso[task.setvariable variable=TF_OUTPUT_{0};]{1}" -f ($key.ToUpper()), $tfoutput.$key.value)
    }
    Write-Verbose ("TF_OUTPUT_{0} set to {1}" -f $key.ToUpper(), $tfoutput.$key.value) -Verbose
}