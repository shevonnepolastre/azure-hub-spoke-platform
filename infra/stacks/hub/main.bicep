targetScope = 'subscription'

@description('Org/project code used in names')
param prefix string = 'az-pola'

@description('Environment')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

@description('Workload identifier')
param workload string = 'hubspoke'

@description('Azure region')
@allowed([
  'centralus'
  'eastus'
  'eastus2'
  'southcentralus'
  'westus2'
  'westus3'
])
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

var nameBase = '${prefix}-${environment}-${workload}-${location}'
var hubRgName = '${nameBase}-rg-hub'
var hubVnetName = '${nameBase}-vnet-hub'

var rgTags = {
  Project: prefix
  Environment: environment
  Workload: workload
  Owner: 'ShevonnePolastre'
  Location: location
  ManagedBy: 'Bicep'
}

resource hubRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: hubRgName
  location: location
  tags: rgTags
}

module hubVnet '../../modules/network/vnet.bicep' = {
  name: 'hub-vnet-deployment'
  scope: hubRg
  params: {
    vnetName: hubVnetName
    location: location
    addressPrefix: addressPrefix
    subnets: subnets
    tags: rgTags
  }
}

output hubVnetId string = hubVnet.outputs.vnetId
output hubVnetName string = hubVnet.outputs.vnetName
output hubRgName string = hubRg.name
output location string = location
output addressPrefix string = addressPrefix
output subnets array = hubVnet.outputs.subnets
output tags object = rgTags
