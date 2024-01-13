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
- Service Connection using the initial Service Principal or additional created Service Principal
- Agent Pool using the Service Connection created 

## Method