using './main.bicep'

param spokeName = 'public'

param addressPrefix = '10.1.0.0/16'

param hubVnetId = '/subscriptions/83b96920-b3ed-4bd2-83cd-6984eca563a4/resourceGroups/az-pola-dev-hubspoke-eastus-rg-hub/providers/Microsoft.Network/virtualNetworks/az-pola-dev-hubspoke-eastus-vnet-hub'


param subnets = [
  {
    name: 'WebSubnet'
    addressPrefix: '10.1.0.0/24'
  }
  {
    name: 'AppSubnet'
    addressPrefix: '10.1.1.0/24'
  }
  {
    name: 'DataSubnet'
    addressPrefix: '10.1.2.0/24'
  }
  {
    name: 'PrivateEndpointsSubnet'
    addressPrefix: '10.1.3.0/27'
  }
]


param webNsgRules = [
  {
    name: 'Allow-HTTP-From-Internet'
    priority: 100
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: 'Internet'
    destinationAddressPrefix: '*'
  }

  {
    name: 'Allow-HTTPS-From-Internet'
    priority: 110
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: 'Internet'
    destinationAddressPrefix: '*'
  }

  {
    name: 'Allow-Web-To-App'
    priority: 200
    access: 'Allow'
    direction: 'Outbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '10.1.1.0/24'
  }
]


param appNsgRules = [
  {
    name: 'Allow-Web-To-App-Inbound'
    priority: 100
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '10.1.0.0/24'
    destinationAddressPrefix: '*'
  }

  {
    name: 'Allow-App-To-Data'
    priority: 200
    access: 'Allow'
    direction: 'Outbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '1433'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '10.1.2.0/24'
  }

  {
    name: 'Deny-SSH-From-Internet'
    priority: 300
    access: 'Deny'
    direction: 'Inbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '22'
    sourceAddressPrefix: 'Internet'
    destinationAddressPrefix: '*'
  }

  {
    name: 'Deny-RDP-From-Internet'
    priority: 400
    access: 'Deny'
    direction: 'Inbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '3389'
    sourceAddressPrefix: 'Internet'
    destinationAddressPrefix: '*'
  }

  {
    name: 'Allow-App-To-PrivateEndpoints'
    priority: 500
    access: 'Allow'
    direction: 'Outbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '10.1.3.0/27'
  }
]

param dataNsgRules = [
  {
    name: 'Allow-App-To-Data-Inbound'
    priority: 100
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '1433'
    sourceAddressPrefix: '10.1.1.0/24'  
    destinationAddressPrefix: '*'
  }
  {
    name: 'Deny-All-Inbound'
    priority: 4096
    access: 'Deny'
    direction: 'Inbound'
    protocol: '*'
    sourcePortRange: '*'
    destinationPortRange: '*'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
  }
]
