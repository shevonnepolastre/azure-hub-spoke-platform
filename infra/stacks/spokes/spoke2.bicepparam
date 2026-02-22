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
