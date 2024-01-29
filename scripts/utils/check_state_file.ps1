param(
    [string]$terraform_working_dir = (Get-Location).Path,
    [string]$terraform_state_file = "terraform.tfbackend",
    [bool]$fail_on_existance = $true
)

Write-Verbose ("Checking for {0} file in {1}" -f $terraform_state_file,$terraform_working_dir) -Verbose
if(Test-Path -Path "$terraform_working_dir/$terraform_state_file" -ErrorAction SilentlyContinue){
    if($fail_on_existance){
        Write-Error "Found $terraform_state_file in $terraform_working_dir. Please remove this file before continuing."
        exit 1
    } else {
        Write-Verbose "Found $terraform_state_file in $terraform_working_dir." -Verbose
    }
} else {
    Write-Verbose "Did not find $terraform_state_file in $terraform_working_dir." -Verbose
}