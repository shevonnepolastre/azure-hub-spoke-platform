@description('VNet name')
param vnetName string

@description('Azure region')
param location string

@description('VNet address space')
param addressPrefix string

@description('Subnets array')
param subnets array

@description('Resource tags')
param tags object

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        defaultOutboundAccess: false
      }
    }]
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output subnets array = [for (subnet, i) in subnets: {
  name: vnet.properties.subnets[i].name
  id: vnet.properties.subnets[i].id
}]
