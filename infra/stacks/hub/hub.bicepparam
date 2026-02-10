using './hubmain.bicep'

param addressPrefix = '10.0.0.0/16'  // Hub VNet address space

param subnets = [
  {
    name: 'GatewaySubnet'
    addressPrefix: '10.0.0.0/27'  // Gateway subnet
  }
  {
    name: 'AzureFirewallSubnet'
    addressPrefix: '10.0.1.0/26'  // Firewall subnet
  }
  {
    name: 'AzureBastionSubnet'
    addressPrefix: '10.0.2.0/26'  // Azure Bastion subnet
  }
  {
    name: 'ManagementSubnet'
    addressPrefix: '10.0.3.0/24'  // Management subnet
  }
]
