# Azure Terraform Sidecar
![Azure Terraform Sidecar](./docs/images/sidecar.png)

## Description

Sidecar is a solution to provide a minimal Terraform environment for future Terraform deployments.

Sidecar caters for if you're starting off executing Terraform locally or you're looking to integrate Terraform into your CI/CD environment, Sidecar will provide you with a Terraform environment in Azure.
Whether you are deploying your Terraform solution directly to a subscription and need a simple way to deploy a Storage Account to store your Terraform state files, 
or you are looking to deploy a new Azure Landing Zone within a new tenant through your Azure DevOps environment 
or provide a Bring-Your-Own-Runner (BYOR) functionality to application teams, Sidecar will provide you with a Terraform environment in Azure.

## Features
- Sufficient resources to support Terraform stateful deployments within Azure DevOps or locally
- Scripted deployment of pre-requisites for an Azure DevOps deployment
- Ability to customise the Terraform environment to suit your requirements
- Choice of the identity used to perform the Terraform deployment
- Scripts and pipelines to interface with Azure DevOps, Azure and Entra ID

## How do you want to start?

This supports either local or Azure DevOps deployments.

### Local Deployment
Out-of-the-box, when deploying locally by executing `./powershell/run-locally.ps1`, the solution will deploy a Storage Account for Terraform state files. The Storage Account will be used as the backend for the Terraform state files.

Further customisation can be made to the solution to suit your requirements.

### Azure DevOps

__TL;DR:__
- Add this repo to your Azure DevOps environment
- Execute locally the `./powershell/init_ado.ps1` script; this will prompt you to set up your Azure DevOps environment
- Add the `./azure-pipelines/init-pipeline.yml` and `./azure-pipelines/post-pipeline.yml` to your Azure DevOps project
- Execute the `./azure-pipelines/init-pipeline.yml` pipeline
- After pipeline execution, approve the Pull Request, and now execute the `./azure-pipelines/post-pipeline.yml` pipeline

```hcl
resource_group_name = "sidecar-rg"
location = "uksouth"
deployment_choice = "System Managed Identity"
authentication_method = "System Managed Identity"
```
_Example terraform.tfvars_

There are few options available when deploying this solution.

- You can either deploy the solution to be a private deployment with the Agent Pool the only resource with access to the Terraform state files or let it remain publically accessible.
- You can deploy the solution for the Terraform state files to be accessed by Users, Service Principals, System Assigned Managed Identities or User Assigned Managed Identities.

Please review the Terraform variables for more information.

#### Requirements
- Azure Subscription to host the Azure Resources required for the Terraform environment
- Azure DevOps Project under an Azure DevOps Organisation

#### Permissions
- Azure DevOps
  - Add Azure DevOps Users to the Azure DevOps Project
  - Add Azure DevOps Users as Creator or greater to the Agent Pool and Service Connection
- Azure
  - Contributor to deploy the resources to the Azure Subscription
  - User Access Administrator or greater to assign roles to the subscription

#### Getting Started

##### `init_ado.ps1`
The `init_ado.ps1` script will prompt you to set up your Azure DevOps environment. It will create a Service Principal, a Service Connection and set up the repository access.

You don't trust the script or some other reason, you want to do it manually. Here's how you can do it.

##### Pre-Requirements Steps
Create a Service Principal within the same tenant as the Azure DevOps Organisation (see x.x). The Service Principal will require the following permissions:
- __Microsoft Graph__ permissions of Application.ReadWrite.OwnedBy. The initial Service Principal requires the ability to create other Service Principals (please see point X.X as to why)
- In __Azure DevOps__
  - Added as a User to the Azure DevOps Organisation
  - Added as a Reader to the Azure DevOps Project
  - __'Agent Pool Creator' or greater__ The initial Service Principal will need to create an Agent Pool in Azure DevOps.
  - __'Service Connection Creator' or greater__  The created Service Principal will be created as a Service Connection within Azure DevOps.

##### Method

###### Add the Repository to Azure DevOps
Assuming you have the Service Principal and Service Connection created, you can now add the repository to your Azure DevOps environment.
Clone the repository to your local machine and push it to your Azure DevOps environment.

###### Create the Pipeline
Add the `init-pipeline.yml` and `post-pipeline.yml` to your Azure DevOps project. The `init-pipeline.yml` will create the resources required for the Terraform environment. The `post-pipeline.yml` will create the Service Connection and Agent Pool.

###### `init-pipeline.yml`
The `init-pipeline.yml` needs to be executed first. This pipeline will execute the Terraform deployment from a Microsoft-hosted agent. 
The pipeline executes the deployment with the Terraform variable `init` set to `true` that ensures the resources deployed via the process are publically facing for the Microsoft-hosted agent to access.

After the deployment has succeeded, the pipeline will:
- Create a Terraform Backend Configuration file
- Migrate the Terraform state file to the Storage Account that was deployed
- Commit the Terraform Backend Configuration file to the repository and submit a Pull Request
- Register the Agent Pool created in the deployment

###### `post-pipeline.yml`
The Pull Request created by the `init-pipeline.yml` will need to be approved. After the Pull Request has been approved, the `post-pipeline.yml` can be executed.
This pipeline will ensure that the deployed Agent Pool has access to the Terraform state files on the Storage Account and optionally make the deployment a private deployment ensuring that only the deployed Virtual Machine Scale Set has access to the resources.

Going forward, the Terraform deployment can be modified to suit your requirements with `post-pipeline.yml` being executed.

Alternatively, the Agent Pool and the backend Storage Account can now be utilised for other Terraform deployments as you see fit.

## FAQ

### Isn't this just another accelerator/bootstrap?
Yes-no. Yes, it is a bootstrap in the sense that it will get you up and running with a Terraform environment in Azure. No, it is not an accelerator in the sense it is for a specific usecase. 
It is a series of scripts, pipelines and Terraform code that will deploy a Terraform environment to your requirements.
There's a lot of flexibility in how you can use this solution/scripts/components in the form it's in or rework it to suit your needs.

### Why would I use this?
If you are looking to get up and running with Terraform in Azure, then this is a good place to start.
It will provide you with a Terraform environment in Azure that you can use to deploy your Terraform solutions.
From here you can then start to build out your Terraform solution using the Storage Account as a backend for your Terraform state files and optionally, using the runner for your CI/CD pipeline.

### Why have you created this?
I have been on countless engagements where individuals are using Terraform however, due to time constraints, they have not been able to perform their Terraform deployments in the best manner they'd like.
This solution is a way to provide a simple, off-the-shelf way to create a Terraform environment in Azure that can be used to deploy Terraform solutions in a more structured manner, using the toolset that is available to them.

### Azure DevOps

#### The Service Connection does not have access to the Azure DevOps Project
Add the Service Principal to the Azure DevOps Organisation as you would a user.

#### The Service Connection does not have access to create Agent Pools
Ensure that the Service Connection has the 'Agent Pool Creator' role or greater.
Navigate to the Agnet Pools under the project you want to create the Agent Pool under.
Top right, click on the three dots and select 'Security'.
Add the Service Principal to the Agent Pool with the 'Agent Pool Creator' role or greater.
The Service Principal will not appear unless it has been added to the Azure DevOps Organisation (please see above).

#### The Service Connection does not have access to create Service Connections
Ensure that the Service Connection has the 'Service Connection Creator' role or greater.
Navigate to the Service Connections under the project you want to create the Service Connection under.
Top right, click on the three dots and select 'Security'.
Add the Service Principal to the Service Connection with the 'Service Connection Creator' role or greater. The Service Principal will not appear unless it has been added to the Azure DevOps Organisation (please see above).