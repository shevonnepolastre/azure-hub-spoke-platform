targetScope = 'subscription'

@description('SSH public key for the test VM')
param sshPublicKey string

@description('Target resource group for the VM')
param targetRgName string = 'az-pola-dev-hubspoke-eastus-rg-spoke-public'

@description('Target VNet name')
param targetVnetName string = 'az-pola-dev-eastus-vnet-spoke-public'

@description('Target subnet name')
param targetSubnetName string = 'WebSubnet'

resource targetRg 'Microsoft.Resources/resourceGroups@2024-03-01' existing = {
  name: targetRgName
}

resource targetVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  scope: targetRg
  name: targetVnetName
}

resource targetSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = {
  parent: targetVnet
  name: targetSubnetName
}

module testVm './vm.bicep' = {
  name: 'test-vm-deployment'
  scope: targetRg
  params: {
    vmName: 'spoke1-test-vm'
    adminUsername: 'azureuser'
    sshPublicKey: sshPublicKey
    subnetId: targetSubnet.id
    location: targetRg.location
    tags: {
      Project: 'az-pola'
      Environment: 'dev'
      Workload: 'hubspoke'
      Purpose: 'test-vm'
      ManagedBy: 'Bicep'
    }
  }
}

output vmId string = testVm.outputs.vmId
output nicId string = testVm.outputs.nicId
