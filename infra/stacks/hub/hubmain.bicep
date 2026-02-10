targetScope = 'subscription'

@description('Environment')
@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

@description('Azure region')
param location string = 'eastus'

@description('Hub VNet address space')
param addressPrefix string

@description('Hub subnets')
param subnets array

// Import naming conventions
module naming '../../globals/naming.bicep' = {
  name: 'naming-hub'
  params: {
    prefix: 'az-pola'
    environment: environment
    locationCode: location
  }
}

// Build hub-specific names
var hubRgName = '${naming.outputs.resourceGroupName}-hub'
var hubVnetName = '${naming.outputs.vnetName}-hub'

// Create hub resource group
resource hubRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: hubRgName
  location: location
  tags: naming.outputs.commonTags
}

// Deploy hub VNet
module hubVnet '../../modules/network/vnet.bicep' = {
  name: 'hub-vnet-deployment'
  scope: hubRg
  params: {
    vnetName: hubVnetName
    location: location
    addressPrefix: addressPrefix
    subnets: subnets
    tags: naming.outputs.commonTags
  }
}

// Outputs
output hubVnetId string = hubVnet.outputs.vnetId
output hubVnetName string = hubVnet.outputs.vnetName
output hubRgName string = hubRg.name
output location string = location
