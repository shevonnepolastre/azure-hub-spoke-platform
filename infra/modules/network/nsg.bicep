/*
  nsg.bicep

  Creates a Network Security Group and optional custom security rules.
  Attach the NSG to a subnet from the VNet/subnet deployment layer.
*/

@description('Name of the Network Security Group')
param nsgName string

@description('Azure region for the NSG')
param location string

@description('Tags to apply to the NSG')
param tags object = {}

@description('Custom NSG security rules')
param securityRules array = []

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: nsgName
  location: location
  tags: tags
}

resource rules 'Microsoft.Network/networkSecurityGroups/securityRules@2024-05-01' = [for rule in securityRules: {
  parent: nsg
  name: rule.name
  properties: {
    priority: rule.priority
    access: rule.access
    direction: rule.direction
    protocol: rule.protocol
    sourcePortRange: rule.sourcePortRange
    destinationPortRange: rule.destinationPortRange
    sourceAddressPrefix: rule.sourceAddressPrefix
    destinationAddressPrefix: rule.destinationAddressPrefix
  }
}]

output nsgId string = nsg.id
output nsgName string = nsg.name
