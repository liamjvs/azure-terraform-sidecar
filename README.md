# Azure Terraform Sidecar

![Azure Terraform Sidecar](./docs/images/sidecar.png)

Sidecar is a solution to provide a minimal Terraform environment for future Terraform deployments. Sidecar caters for if you're starting off executing Terraform locally or you're looking to integrate Terraform into your CI/CD environment, Sidecar will provide you with a Terraform environment in Azure. Whether you're deploying your Terraform solution directly to a subscription and need a simple way of deploying a Storage Account to store your Terraform state files or you're looking to deploy a new Azure Landing Zone within a new tenant via your Azure DevOps environment or provide a Bring-Your-Own-Runner functionality to application teams via GitHub, Sidecar will provide you with a Terraform environment in Azure.

- [Azure Terraform Sidecar](#azure-terraform-sidecar)
- [FAQ](#faq)
  - [Isn't this just another accelerator/bootstrap?](#isnt-this-just-another-acceleratorbootstrap)
  - [Why would I use this?](#why-would-i-use-this)



# FAQ

## Isn't this just another accelerator/bootstrap?
Yes-no. It is a bootstrap in the sense that it will get you up and running with a Terraform environment in Azure. However, it is not an accelerator in the sense it is for a specific usecase. It is a series of scripts, pipelines and Terraform code that will deploy a Terraform environment to your requirements.

## Why would I use this?
If you are looking to get up and running with Terraform in Azure, then this is a good place to start. It will provide you with a Terraform environment in Azure that you can use to deploy your Terraform solutions. From here you can then start to build out your Terraform solution using the Storage Account as a backend for your Terraform state files and optionally, using the runner for your CI/CD pipeline.