targetScope = 'subscription'

@description('Org/project code')
param prefix string = 'az-pola'

@description('Environment')
@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

@description('Workload identifier')
param workload string = 'hubspoke'

@description('Azure region')
@allowed(['centralus', 'eastus', 'eastus2', 'southcentralus', 'westus2', 'westus3'])
param location string = 'eastus'

@description('Spoke identifier (app, intranet, ai)')
param spokeName string

@description('Spoke VNet address space')
param addressPrefix string

@description('Spoke subnets')
param subnets array

@description('Hub VNet resource ID for peering')
param hubVnetId string

// Build names
var nameBase = '${prefix}-${environment}-${workload}-${location}'
var spokeRgName = '${nameBase}-rg-spoke-${spokeName}'
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

// Naming module
module naming '../../globals/naming.bicep' = {
  name: 'naming-spoke-${spokeName}'
  params: {
    prefix: prefix
    environment: environment
    location: location
  }
}

// Create spoke RG
resource spokeRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: spokeRgName
  location: location
  tags: rgTags
}

// Deploy spoke VNet
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

// Peering: Spoke → Hub
module spokeToHub '../../modules/network/peering.bicep' = {
  name: 'peering-spoke-${spokeName}-to-hub'
  scope: spokeRg
  params: {
    localVnetName: spokeVnet.outputs.vnetName
    remoteVnetId: hubVnetId
    peeringName: 'spoke-${spokeName}-to-hub'
  }
}

// Peering: Hub → Spoke
module hubToSpoke '../../modules/network/peering.bicep' = {
  name: 'peering-hub-to-spoke-${spokeName}'
  scope: resourceGroup(hubRgName)
  params: {
    localVnetName: hubVnetName
    remoteVnetId: spokeVnet.outputs.vnetId
    peeringName: 'hub-to-spoke-${spokeName}'
  }
}

// Outputs
output spokeRgName string = spokeRg.name
output spokeVnetName string = spokeVnet.outputs.vnetName
output spokeVnetId string = spokeVnet.outputs.vnetId
output spokeSubnets array = spokeVnet.outputs.subnets
output spokeToHubPeeringId string = spokeToHub.outputs.peeringId
output hubToSpokePeeringId string = hubToSpoke.outputs.peeringId
