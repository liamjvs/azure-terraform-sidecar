# azu-solu-tf-sidecar

[[_TOC_]]

## Introduction
### Solution Description

[azu-solu-tf-sidecar] is a Day0 deployment for Terraform platforms. Sidecar is to enable to the storage of TFState within the Azure platfrom as well as providing Azure DevOps agents for initial deployments within the Azure Platform

azu-solu-tf-sidecar delivers:

- Azure Resource Group
- Network Security Group
- Private DNS Zone
- Virtual Network
- Subnet
- Azure Storage Account
- Log Analytics Workspace
- Virtual Machine

### Service Limits
Following are the service limits, per subscriptions and product:
+ [Azure limits per subscription](https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits)
+ [azu-comp-tf-resourcegroup](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#resource-group-limits)
+ [Azure networking limits](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#networking-limits)
+ [azu-comp-tf-vmss](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#virtual-machine-scale-sets-limits)
+ [Azure storage limits](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#storage-limits)

## Deployment

### Prerequisites

- Terraform v1.2.0 and later.