param (
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $false)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $false)]
    [string]$PrivateDnsZoneName,
    [Parameter(Mandatory = $false)]
    [string]$NetworkSecurityGroupName,
    [Parameter(Mandatory = $false)]
    [string]$VirtualNetworkName,
    [Parameter(Mandatory = $false)]
    [string]$VirtualNetworkId,
    [Parameter(Mandatory = $false)]
    [string]$VirtualMachineScaleSetName,
    [Parameter(Mandatory = $false)]
    [string]$PublicIpPrefixName,
    [Parameter(Mandatory = $false)]
    [string]$NatGatewayName
)

Write-Verbose "ResourceGroupName: $ResourceGroupName" -Verbose
Write-Verbose "NetworkSecurityGroupName: $NetworkSecurityGroupName" -Verbose
Write-Verbose "StorageAccountName: $StorageAccountName" -Verbose
Write-Verbose "PrivateDnsZoneName: $PrivateDnsZoneName" -Verbose
Write-Verbose "VirtualNetworkName: $VirtualNetworkName" -Verbose
Write-Verbose "VirtualNetworkId: $VirtualNetworkId" -Verbose
Write-Verbose "VirtualMachineScaleSetName: $VirtualMachineScaleSetName" -Verbose
Write-Verbose "PublicIpPrefixName: $PublicIpPrefixName" -Verbose
Write-Verbose "NatGatewayName: $NatGatewayName" -Verbose

Describe 'Sidecar Set Tests' {

    Context 'Existence' {

        $testCases = @(
            @{
                ResourceGroupName = $ResourceGroupName
                NetworkSecurityGroupName = $NetworkSecurityGroupName
                StorageAccountName = $StorageAccountName
                PrivateDnsZoneName = $PrivateDnsZoneName
                VirtualNetworkName = $VirtualNetworkName
                VirtualNetworkId = $VirtualNetworkId
                VirtualMachineScaleSetName = $VirtualMachineScaleSetName
                PublicIpPrefixName = $PublicIpPrefixName
                NatGatewayName = $NatGatewayName
            }
        )

        It '[<ResourceGroupName>] Should be deployed' -TestCases $testCases {

            param(
                [string] $ResourceGroupName
            )
            $resourceGroup = Get-AzResourceGroup -ResourceGroupName $ResourceGroupName
            $resourceGroup | Should -Not -BeNullOrEmpty
        }

        It '[<NetworkSecurityGroupName>] Should be deployed' -TestCases $testCases {

            param(
                [string] $ResourceGroupName,
                [string] $NetworkSecurityGroupName
            )
            $nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NetworkSecurityGroupName -ErrorAction 'Stop'
            $nsg | Should -Not -BeNullOrEmpty
        }

        It '[<StorageAccountName>] Should be deployed' -TestCases $testCases {

            param(
                [string] $ResourceGroupName,
                [string] $StorageAccountName
            )
            $sto = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction 'Stop'
            $sto.StorageAccountName | Should -Not -BeNullOrEmpty
        }

        It '[<VirtualNetworkName>] Should be deployed' -TestCases $testCases {

            param(
                [string] $VirtualNetworkId,
                [string] $VirtualNetworkName
            )
            $vnet = Get-AzResource -ResourceId $VirtualNetworkId -ErrorAction 'SilentlyContinue'
            $vnet.Name | Should -Be $VirtualNetworkName
        }

        It '[<VirtualMachineScaleSetName>] Should be deployed' -TestCases $testCases {

            param(
                [string] $ResourceGroupName,
                [string] $VirtualMachineScaleSetName
            )
            $vmss = Get-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $VirtualMachineScaleSetName -ErrorAction 'Stop'
            $vmss | Should -Not -BeNullOrEmpty
        }

        It '[<PublicIpPrefixName>] Should be deployed' -TestCases $testCases {

            param(
                [string] $ResourceGroupName,
                [string] $PublicIpPrefixName
            )
            $ipPrefix = Get-AzPublicIpPrefix -ResourceGroupName $ResourceGroupName -Name $PublicIpPrefixName -ErrorAction 'Stop'
            $ipPrefix | Should -Not -BeNullOrEmpty
        }

        It '[<NatGatewayName>] Should be deployed' -TestCases $testCases {

            param(
                [string] $ResourceGroupName,
                [string] $NatGatewayName
            )
            $vmss = Get-AzNatGateway -ResourceGroupName $ResourceGroupName -Name $NatGatewayName -ErrorAction 'Stop'
            $vmss | Should -Not -BeNullOrEmpty
        }
    }
}