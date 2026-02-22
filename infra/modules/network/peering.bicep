@description('Name of the local VNet (where this peering resource lives)')
param localVnetName string

@description('Resource ID of the remote VNet (what you are peering to)')
param remoteVnetId string

@description('Name for this peering connection')
param peeringName string

@description('Allow forwarded traffic from remote VNet')
param allowForwardedTraffic bool = false

@description('Allow gateway transit')
param allowGatewayTransit bool = false

@description('Use remote gateways')
param useRemoteGateways bool = false

// Reference the existing local VNet
resource localVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: localVnetName
}

// Create peering as child of local VNet
resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  parent: localVnet
  name: peeringName
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: remoteVnetId
    }
  }
}

output peeringId string = peering.id
output peeringName string = peering.name
