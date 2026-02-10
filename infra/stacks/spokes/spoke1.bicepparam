using './spokemain.bicep'

param spokeName = 'public'
param addressPrefix = '10.1.0.0/16'

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
