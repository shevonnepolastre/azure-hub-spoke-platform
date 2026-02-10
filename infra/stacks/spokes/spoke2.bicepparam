using './spokemain.bicep'

param spokeName = 'intranet'
param addressPrefix = '10.2.0.0/16'

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
