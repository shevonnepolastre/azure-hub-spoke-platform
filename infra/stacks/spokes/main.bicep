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

@description('NSG rules for the web subnet')
param webNsgRules array = []

@description('NSG rules for the app subnet')
param appNsgRules array = []

@description('NSG rules for the data subnet')
param dataNsgRules array = []

@description('NSG rules for the compute subnet')
param computeNsgRules array = []

@description('NSG rules for ML compute subnet')
param mlopsNsgRules array = []

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

// NSG modules - conditionally deployed based on subnet existence
module webNsg '../../modules/network/nsg.bicep' = if (length(filter(subnets, s => s.name == 'WebSubnet')) > 0) {
  name: 'nsg-web-${spokeName}'
  scope: spokeRg
  params: {
    nsgName: '${naming.outputs.nsgName}-web-${spokeName}'
    location: location
    tags: naming.outputs.commonTags
    securityRules: webNsgRules
  }
}

module appNsg '../../modules/network/nsg.bicep' = if (length(filter(subnets, s => s.name == 'AppSubnet')) > 0) {
  name: 'nsg-app-${spokeName}'
  scope: spokeRg
  params: {
    nsgName: '${naming.outputs.nsgName}-app-${spokeName}'
    location: location
    tags: naming.outputs.commonTags
    securityRules: appNsgRules
  }
}

module dataNsg '../../modules/network/nsg.bicep' = if (length(filter(subnets, s => s.name == 'DataSubnet')) > 0) {
  name: 'nsg-data-${spokeName}'
  scope: spokeRg
  params: {
    nsgName: '${naming.outputs.nsgName}-data-${spokeName}'
    location: location
    tags: naming.outputs.commonTags
    securityRules: dataNsgRules
  }
}

module computeNsg '../../modules/network/nsg.bicep' = if (length(filter(subnets, s => s.name == 'ComputeSubnet')) > 0) {
  name: 'nsg-compute-${spokeName}'
  scope: spokeRg
  params: {
    nsgName: '${naming.outputs.nsgName}-compute-${spokeName}'
    location: location
    tags: naming.outputs.commonTags
    securityRules: computeNsgRules
  }
}

module mlopsNsg '../../modules/network/nsg.bicep' = if (length(filter(subnets, s => s.name == 'MLOpsSubnet')) > 0) {
  name: 'nsg-mlops-${spokeName}'
  scope: spokeRg
  params: {
    nsgName: '${naming.outputs.nsgName}-mlops-${spokeName}'
    location: location
    tags: naming.outputs.commonTags
    securityRules: mlopsNsgRules
  }
}

// NSG association modules - conditionally deployed based on subnet existence
module associateWebNsg '../../modules/network/nsg_associate.bicep' = if (length(filter(subnets, s => s.name == 'WebSubnet')) > 0) {
  name: 'associate-web-nsg-spoke-${spokeName}'
  scope: spokeRg
  params: {
    vnetName: spokeVnet.outputs.vnetName
    subnetName: 'WebSubnet'
    nsgId: webNsg.outputs.nsgId
  }
}

module associateAppNsg '../../modules/network/nsg_associate.bicep' = if (length(filter(subnets, s => s.name == 'AppSubnet')) > 0) {
  name: 'associate-app-nsg-spoke-${spokeName}'
  scope: spokeRg
  params: {
    vnetName: spokeVnet.outputs.vnetName
    subnetName: 'AppSubnet'
    nsgId: appNsg.outputs.nsgId
  }
}

module associateDataNsg '../../modules/network/nsg_associate.bicep' = if (length(filter(subnets, s => s.name == 'DataSubnet')) > 0) {
  name: 'associate-data-nsg-spoke-${spokeName}'
  scope: spokeRg
  params: {
    vnetName: spokeVnet.outputs.vnetName
    subnetName: 'DataSubnet'
    nsgId: dataNsg.outputs.nsgId
  }
}

module associateComputeNsg '../../modules/network/nsg_associate.bicep' = if (length(filter(subnets, s => s.name == 'ComputeSubnet')) > 0) {
  name: 'associate-compute-nsg-spoke-${spokeName}'
  scope: spokeRg
  params: {
    vnetName: spokeVnet.outputs.vnetName
    subnetName: 'ComputeSubnet'
    nsgId: computeNsg.outputs.nsgId
  }
}

module associateMlopsNsg '../../modules/network/nsg_associate.bicep' = if (length(filter(subnets, s => s.name == 'MLOpsSubnet')) > 0) {
  name: 'associate-mlops-nsg-spoke-${spokeName}'
  scope: spokeRg
  params: {
    vnetName: spokeVnet.outputs.vnetName
    subnetName: 'MLOpsSubnet'
    nsgId: mlopsNsg.outputs.nsgId
  }
}

// Outputs
output spokeRgName string = spokeRg.name
output spokeVnetName string = spokeVnet.outputs.vnetName
output spokeVnetId string = spokeVnet.outputs.vnetId
output spokeSubnets array = spokeVnet.outputs.subnets
output spokeToHubPeeringId string = spokeToHub.outputs.peeringId
output hubToSpokePeeringId string = hubToSpoke.outputs.peeringId
output webNsgId string = length(filter(subnets, s => s.name == 'WebSubnet')) > 0 ? webNsg.outputs.nsgId : ''
output appNsgId string = length(filter(subnets, s => s.name == 'AppSubnet')) > 0 ? appNsg.outputs.nsgId : ''
output dataNsgId string = length(filter(subnets, s => s.name == 'DataSubnet')) > 0 ? dataNsg.outputs.nsgId : ''
output computeNsgId string = length(filter(subnets, s => s.name == 'ComputeSubnet')) > 0 ? computeNsg.outputs.nsgId : ''
output mlopsNsgId string = length(filter(subnets, s => s.name == 'MLOpsSubnet')) > 0 ? mlopsNsg.outputs.nsgId : ''
