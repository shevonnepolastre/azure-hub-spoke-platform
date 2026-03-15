/*
  Defines naming conventions and standard tags for resources deployed
  within the hub-and-spoke architecture.
*/

targetScope = 'subscription'

@description('Org/project code used in names (lowercase for global resources)')
param prefix string = 'az-pola'

@description('The environment being deployed to')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

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

var commonTags = {
  Project: prefix
  Environment: environment 
  Owner: 'ShevonnePolastre'
  Location: location
  ManagedBy: 'Bicep'
}

var nameBase = '${prefix}-${environment}-${location}'

var naming = {
  rg: '${nameBase}-rg'
  netmgr: '${nameBase}-netmgr'
  nsg: '${nameBase}-nsg'
  mon: '${nameBase}-mon'
  law: '${nameBase}-law'
  vnet: '${nameBase}-vnet'
  vmWindows: '${nameBase}-vm-win'
  vmLinux: '${nameBase}-vm-lin'
  fw: '${nameBase}-fw'
  subnet: '${nameBase}-snet'
}

var patterns = {
  vnet: '${nameBase}-vnet-{nn}'
  snet: '${nameBase}-snet-{purpose}-{nn}'
  pip: '${nameBase}-pip-{name}'
  nic: '${nameBase}-nic-{name}'
  vm:  '${nameBase}-vm-{name}'
  fw:  '${nameBase}-fw-{name}'
  st:  '${prefix}${environment}st{nnn}' // storage accounts: lowercase, no dashes; add unique suffix when deployed
}

output resourceGroupName string = naming.rg
output vnetName string = naming.vnet
output firewallName string = naming.fw
output logAnalyticsName string = naming.law
output commonTags object = commonTags
output namingPatterns object = patterns
output location string = location
output environment string = environment
output prefix string = prefix
output nsgName string = naming.nsg

