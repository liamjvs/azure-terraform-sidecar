# Azure Terraform Sidecar
![Azure Terraform Sidecar](./docs/images/sidecar.png)

## Description

Sidecar is a solution to provide a minimal Terraform environment for future Terraform deployments. 

Sidecar caters for if you're starting off executing Terraform locally or you're looking to integrate Terraform into your CI/CD environment, Sidecar will provide you with a Terraform environment in Azure. 
Whether you're deploying your Terraform solution directly to a subscription and need a simple way of deploying a Storage Account to store your Terraform state files or you're looking to deploy a new Azure Landing Zone within a new tenant via your Azure DevOps environment or provide a Bring-Your-Own-Runner (BYOR) functionality to application teams via GitHub, Sidecar will provide you with a Terraform environment in Azure.

## Features
- Sufficient resources to support Terraform stateful deployments within Azure DevOps or locally
- Scripted deployment of pre-requisites for an Azure DevOps deployment
- Ability to customise the Terraform environment to suit your requirements
- Choice of the identity used to perform the Terraform deployment
- Scripts and pipelines to interface with Azure DevOps, Azure and Entra ID

## Getting Started

### Locally
Out-of-the-box, when deploying locally by executing `./powershell/run-locally.ps1`, the solution will deploy a Storage Account for Terraform state files. The Storage Account will be used as the backend for the Terraform state files.

### Azure DevOps
Please refer to the [Azure DevOps](./docs/azure-devops.md) documentation for more information on how to deploy the solution to Azure DevOps.

For those who are time pressured:
- Add this repo to your Azure DevOps environment
- Execute the `./powershell/init_ado.ps1` script; this will prompt you to set up your Azure DevOps environment
- Add the `./azure-pipelines/init-pipeline.yml` and `./azure-pipelines/post-pipeline.yml` to your Azure DevOps project
- Execute the `./azure-pipelines/init-pipeline.yml` pipeline
- After pipeline execution, approve the Pull Request, and now execute the `./azure-pipelines/post-pipeline.yml` pipeline

## FAQ

## Isn't this just another accelerator/bootstrap?
Yes-no. Yes, it is a bootstrap in the sense that it will get you up and running with a Terraform environment in Azure. No, it is not an accelerator in the sense it is for a specific usecase. It is a series of scripts, pipelines and Terraform code that will deploy a Terraform environment to your requirements. There's a lot of flexibility in how you can use this solution/scripts/components in the form it's in or rework it to suit your needs.

## Why would I use this?
If you are looking to get up and running with Terraform in Azure, then this is a good place to start. It will provide you with a Terraform environment in Azure that you can use to deploy your Terraform solutions. From here you can then start to build out your Terraform solution using the Storage Account as a backend for your Terraform state files and optionally, using the runner for your CI/CD pipeline.

## Why have you created this?
I have been on countless engagements where individuals are using Terraform however, due to time constraints, they have not been able to perform their Terraform deployments in the best manner they'd like. This solution is a way to provide a simple, off-the-shelf way to create a Terraform environment in Azure that can be used to deploy Terraform solutions in a more structured manner, using the toolset that is available to them.