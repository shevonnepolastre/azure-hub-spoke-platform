/*
  Defines the naming convention for all resources deployed
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

@description('The location code allowed for resources')
@allowed([
  'centralus'
  'eastus'
  'eastus2'
  'southcentralus'
  'westus2'
  'westus3'
])
param locationCode string = 'eastus'

var commonTags = { // Standard tags for all resources
  Project: prefix
  Environment: environment
  Workload: 'hubspoke'
  Owner: 'ShevonnePolastre' // keep ownership stable, not tied to VM admin
  Location: locationCode
  ManagedBy: 'Bicep'
}

// Base name used for most resources
var nameBase = '${prefix}-${environment}-${locationCode}'

// Standard names (no “-name” placeholders, use suffix inputs per-resource)
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

// Helper pattern examples for resources that NEED a suffix/instance
// Use these as conventions when you declare the actual resources:
var patterns = {
  vnet: '${nameBase}-vnet-{nn}'          // nn = 01, 02...
  snet: '${nameBase}-snet-{purpose}-{nn}' // purpose = app, mgmt, priv, etc.
  pip: '${nameBase}-pip-{name}'
  nic: '${nameBase}-nic-{name}'
  vm:  '${nameBase}-vm-{name}'
  fw:  '${nameBase}-fw-{name}'
  st:  '${prefix}${environment}st{nnn}'          // unique string function with resource group ID for storage accounts due to not able to handle dashes 
}

output resourceGroupName string = naming.rg
output networkManagerName string = naming.netmgr
output nsgName string = naming.nsg
output monitoringName string = naming.mon
output logAnalyticsName string = naming.law
output vnetName string = naming.vnet
output vmWindowsName string = naming.vmWindows
output vmLinuxName string = naming.vmLinux
output firewallName string = naming.fw
output subnetName string = naming.subnet
output commonTags object = commonTags
output namingPatterns object = patterns
output locationCode string = locationCode
