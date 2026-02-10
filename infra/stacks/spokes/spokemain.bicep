targetScope = 'subscription'

@description('Org/project code')
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

@description('Spoke identifier (public, intranet, ai-test)')
param spokeName string

@description('Spoke VNet address space')
param addressPrefix string

@description('Spoke subnets')
param subnets array

// ----------------------------------------------------
// Resource-group-safe naming (must be known at start)
// ----------------------------------------------------
var nameBase = '${prefix}-${environment}-${location}'
var spokeRgName = '${nameBase}-rg-spoke-${spokeName}'

var rgTags = {
  Project: prefix
  Environment: environment
  Workload: workload
  Owner: 'ShevonnePolastre'
  Location: location
  ManagedBy: 'Bicep'
}

// ----------------------------------------------------
// Naming convention module (used AFTER RG exists)
// ----------------------------------------------------
module naming '../../globals/naming.bicep' = {
  name: 'naming-spoke-${spokeName}'
  params: {
    prefix: prefix
    environment: environment
    locationCode: location
  }
}

// ----------------------------------------------------
// Resources
// ----------------------------------------------------
resource spokeRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: spokeRgName
  location: location
  tags: rgTags
}

module spokeVnet '../../modules/network/vnet.bicep' = {
  name: 'spoke-${spokeName}-vnet'
  scope: spokeRg
  params: {
    vnetName: '${naming.outputs.vnetName}-spoke-${spokeName}'
    location: location
    addressPrefix: addressPrefix
    subnets: subnets
    tags: naming.outputs.commonTags
  }
}

// ----------------------------------------------------
// Outputs
// ----------------------------------------------------
output spokeRgName string = spokeRg.name
output spokeVnetName string = spokeVnet.outputs.vnetName
output spokeVnetId string = spokeVnet.outputs.vnetId
