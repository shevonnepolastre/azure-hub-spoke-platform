targetScope = 'resourceGroup'

@description('Name of the VNet containing the subnet')
param vnetName string

@description('Name of the subnet to update')
param subnetName string

@description('NSG resource ID to associate')
param nsgId string

// Reference existing vnet
resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: vnetName
}

// Reference existing subnet to get its addressPrefix
resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = {
  parent: vnet
  name: subnetName
}

// Redeploy subnet with NSG attached
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: existingSubnet.properties.addressPrefix
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

output subnetId string = subnet.id
