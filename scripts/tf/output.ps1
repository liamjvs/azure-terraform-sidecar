param(
    [bool]$cicd_ado = $true,
    [bool]$error_on_no_output = $true
)

$terraform_output = terraform output -json
$output_object = $terraform_output | ConvertFrom-Json -Depth 100

if($null -eq $output_object){
    if($error_on_no_output){
        Write-Error "Unable to find outputs in terraform output"
        exit 1
    } else {
        Write-Warning "Unable to find outputs in terraform output"
        exit 0
    }
}

if(!$cicd_ado){
    $Global:tf_output = @()
}

foreach($key in $output_object.PSObject.Properties.Name){
    $line_item = "{0} = `"{1}`"" -f $key, $output_object.$key.value
    Write-Verbose $line_item
    if($cicd_ado){
        Write-Host ("##vso[task.setvariable variable=TF_OUTPUT_{0};]{1}" -f ($key.ToUpper()), $output_object.$key.value)
    } else {
        $Global:tf_output += @{
            $key = $output_object.$key.value
        }
    }
    Write-Verbose ("TF_OUTPUT_{0} set to {1}" -f $key.ToUpper(), $output_object.$key.value) -Verbose
}