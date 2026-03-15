using './main.bicep'

param spokeName = 'intranet'
param addressPrefix = '10.2.0.0/16'
param hubVnetId = '/subscriptions/83b96920-b3ed-4bd2-83cd-6984eca563a4/resourceGroups/az-pola-dev-hubspoke-eastus-rg-hub/providers/Microsoft.Network/virtualNetworks/az-pola-dev-hubspoke-eastus-vnet-hub'

param subnets = [
  {
    name: 'AppSubnet'
    addressPrefix: '10.2.0.0/24'
  }
  {
    name: 'PrivateEndpointsSubnet'
    addressPrefix: '10.2.1.0/27'
  }
]

param appNsgRules = [
  {
    name: 'Allow-App-To-PrivateEndpoints-443'
    priority: 200
    access: 'Allow'
    direction: 'Outbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '10.2.1.0/27'
  }
  {
    name: 'Allow-App-To-AI-MLOps-443'
    priority: 250
    access: 'Allow'
    direction: 'Outbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '10.3.3.0/24'
  }
  {
    name: 'Deny-Inbound-From-Internet'
    priority: 100
    access: 'Deny'
    direction: 'Inbound'
    protocol: '*'
    sourcePortRange: '*'
    destinationPortRange: '*'
    sourceAddressPrefix: 'Internet'
    destinationAddressPrefix: '*'
  }
]

param webNsgRules = []  // Empty - no web subnet in spoke2

