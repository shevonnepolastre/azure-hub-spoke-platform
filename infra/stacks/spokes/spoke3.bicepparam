using './main.bicep'

param spokeName = 'ai-services'
param addressPrefix = '10.3.0.0/16'
param hubVnetId = '/subscriptions/83b96920-b3ed-4bd2-83cd-6984eca563a4/resourceGroups/az-pola-dev-hubspoke-eastus-rg-hub/providers/Microsoft.Network/virtualNetworks/az-pola-dev-hubspoke-eastus-vnet-hub'

param subnets = [
  {
    name: 'AIComputeSubnet'
    addressPrefix: '10.3.0.0/24'
  }
  {
    name: 'AIDataSubnet'
    addressPrefix: '10.3.1.0/24'
  }
  {
    name: 'AIServicesSubnet'
    addressPrefix: '10.3.2.0/24'
  }
  {
    name: 'MLOpsSubnet'
    addressPrefix: '10.3.3.0/24'
  }
]

param webNsgRules = []

param appNsgRules = [
  {
    name: 'Allow-Spoke2-App-To-MLOps-443'
    priority: 150
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '10.2.0.0/24'
    destinationAddressPrefix: '*'
  }
]

param mlopsNsgRules = [
  {
    name: 'Allow-MLOps-To-AICompute'
    priority: 100
    access: 'Allow'
    direction: 'Outbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '10.3.0.0/24'
  }
  {
    name: 'Allow-MLOps-To-AIData'
    priority: 200
    access: 'Allow'
    direction: 'Outbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '1433'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '10.3.1.0/24'
  }
  {
    name: 'Allow-MLOps-To-AIServices'
    priority: 300
    access: 'Allow'
    direction: 'Outbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '10.3.2.0/24'
  }
]

param dataNsgRules = [
  {
    name: 'Allow-AICompute-To-AIData'
    priority: 100
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '1433'
    sourceAddressPrefix: '10.3.0.0/24'
    destinationAddressPrefix: '*'
  }
]

param computeNsgRules = [
  {
    name: 'Allow-MLOps-To-AICompute'
    priority: 100
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '10.3.3.0/24'
    destinationAddressPrefix: '*'
  }
  {
    name: 'Allow-AICompute-To-AIData'
    priority: 200
    access: 'Allow'
    direction: 'Outbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '1433'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '10.3.1.0/24'
  }
  {
    name: 'Allow-AICompute-To-AIServices'
    priority: 300
    access: 'Allow'
    direction: 'Outbound'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '10.3.2.0/24'
  }
]
