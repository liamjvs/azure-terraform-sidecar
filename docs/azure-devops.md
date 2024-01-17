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

## FAQ
### The Service Connection does not have access to the Azure DevOps Project
Add the Service Principal to the Azure DevOps Organisation as you would a user.

### The Service Connection does not have access to create Agent Pools
Ensure that the Service Connection has the 'Agent Pool Creator' role or greater. Navigate to the Agnet Pools under the project you want to create the Agent Pool under. Top right, click on the three dots and select 'Security'. Add the Service Principal to the Agent Pool with the 'Agent Pool Creator' role or greater. The Service Principal will not appear unless it has been added to the Azure DevOps Organisation (please see above).

### The Service Connection does not have access to create Service Connections
Ensure that the Service Connection has the 'Service Connection Creator' role or greater. Navigate to the Service Connections under the project you want to create the Service Connection under. Top right, click on the three dots and select 'Security'. Add the Service Principal to the Service Connection with the 'Service Connection Creator' role or greater. The Service Principal will not appear unless it has been added to the Azure DevOps Organisation (please see above).