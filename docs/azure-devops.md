# Azure DevOps

## Requirements
- Azure Subscription to host
- Service Principal to deploy the sidecar

## Service Principal Requirements
The Service Principal executing the deployment will require the following:
- Microsoft Graph
  - __Application.ReadWrite.OwnedBy__ The initial Service Principal requires the ability to create other Service Principals (please see point X.X as to why)
- Azure DevOps
  - __'Agent Pool Creator' or greater__ The initial Service Principal will need to create an Agent Pool in Azure DevOps
  - __'Service Connection Creator' or greater__  Either the initial Service Principal or the optionally created Service Principal will be created as a Service Connection within Azure DevOps

## Artifacts Created
- (Optional) Service Principal to scale-up/down the Virtual Machine Scale Set
  - Optional as you can use the initial Service Connection to scale-up/down the Virtual Machine Scale Set. However, if you want to use a separate Service Principal for this with least privilege, then the script will create a Service Principal with the required permissions to scale-up/down the Virtual Machine Scale Set.
- Service Connection using the initial Service Principal or additional created Service Principal
- Agent Pool using the Service Connection created 

## Method

### Validate
#### Check Azure DevOps
The first job performs a few checks ensuring that the Service Connection has the correct level of permissions to perform the required tasks. The checks are:
- Checking that the Service Connection has access to the Azure DevOps Project
- Checking that the Service Connection has access to create Agent Pools (Creator role or greater)
- Checking that the Service Connection has access to create Service Connections (Creator role or greater)

#### Terraform Plan
The second job will perform a Terraform plan against the Terraform code. This will provide a list of resources that will be created, updated or deleted.

### Deploy
#### Terraform Apply
The third job will download the artifacts from the previous plan stage and then perform a Terraform apply against this. This will create the resources in Azure.

#### Creation of the Terraform Backend File
Terraform will output the backend state resources within the Azure DevOps job. This stage will execute `terraform output` to fetch the values, create a `.tfbackend` file, migrate the state to the backend (removing the local state file) and then re-run `terraform init` to ensure the backend is configured correctly. The state file will now be stored in the Storage Account created during the Terraform apply stage and no longer locally.

#### Creation of Azure DevOps Artifacts
The final stage will create the Service Connection and Agent Pool within Azure DevOps. The Service Connection will use the initial Service Principal or the optionally created Service Principal. The Agent Pool will use the Service Connection created.

## FAQ
### The Service Connection does not have access to the Azure DevOps Project
Add the Service Principal to the Azure DevOps Organisation as you would a user.

### The Service Connection does not have access to create Agent Pools
Ensure that the Service Connection has the 'Agent Pool Creator' role or greater. Navigate to the Agnet Pools under the project you want to create the Agent Pool under. Top right, click on the three dots and select 'Security'. Add the Service Principal to the Agent Pool with the 'Agent Pool Creator' role or greater. The Service Principal will not appear unless it has been added to the Azure DevOps Organisation (please see above).

### The Service Connection does not have access to create Service Connections
Ensure that the Service Connection has the 'Service Connection Creator' role or greater. Navigate to the Service Connections under the project you want to create the Service Connection under. Top right, click on the three dots and select 'Security'. Add the Service Principal to the Service Connection with the 'Service Connection Creator' role or greater. The Service Principal will not appear unless it has been added to the Azure DevOps Organisation (please see above).