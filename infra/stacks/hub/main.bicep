targetScope = 'subscription'

@description('Org/project code used in names')
param prefix string = 'az-pola'

@description('Environment')
@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

@description('Azure region')
@allowed(['centralus','eastus','eastus2','southcentralus','westus2','westus3'])
param location string = 'eastus'

@description('Hub VNet address space')
param addressPrefix string

@description('Hub subnets')
param subnets array

module naming '../../globals/naming.bicep' = {
  name: 'naming-hub'
  params: {
    prefix: prefix
    environment: environment
    location: location
  }
}

var hubRgName = '${naming.outputs.resourceGroupName}-hub'
var hubVnetName = '${naming.outputs.vnetName}-hub'

resource hubRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: hubRgName
  location: location
  tags: naming.outputs.commonTags
}

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

output hubVnetId string = hubVnet.outputs.vnetId
output hubVnetName string = hubVnet.outputs.vnetName
output hubRgName string = hubRg.name
output location string = location
