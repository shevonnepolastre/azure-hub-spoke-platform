@description('SSH public key for authentication')
param sshPublicKey string

@description('Admin username for the VM')
param adminUsername string

@description('Ubuntu version for the VM')
@allowed([
  'Ubuntu-2204'
  'Ubuntu-2004'
])
param ubuntuVersion string = 'Ubuntu-2204'

@description('Size of the virtual machine')
param vmSize string = 'Standard_D2s_v3'

@description('Subnet resource ID for NIC attachment')
param subnetId string

@description('Location for the VM')
param location string = resourceGroup().location

@description('Security type of the virtual machine')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'Standard'

@description('Name of the virtual machine')
param vmName string = 'myvm'

@description('VM tags')
param tags object = {}

var ubuntuImage = ubuntuVersion == 'Ubuntu-2204'
  ? {
      publisher: 'Canonical'
      offer: '0001-com-ubuntu-server-jammy'
      sku: '22_04-lts-gen2'
      version: 'latest'
    }
  : {
      publisher: 'Canonical'
      offer: '0001-com-ubuntu-server-focal'
      sku: '20_04-lts-gen2'
      version: 'latest'
    }

resource nic 'Microsoft.Network/networkInterfaces@2024-03-01' = {
  name: '${vmName}-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: ubuntuImage
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    securityProfile: securityType == 'TrustedLaunch'
      ? {
          securityType: 'TrustedLaunch'
          uefiSettings: {
            secureBootEnabled: true
            vTpmEnabled: true
          }
        }
      : null
  }
}

output vmId string = vm.id
output vmName string = vm.name
output nicId string = nic.id
output privateIpAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
output adminUsername string = adminUsername
output ubuntuVersion string = ubuntuVersion
output vmSize string = vmSize
output subnetId string = subnetId
output vmTags object = vm.tags
output securityType string = securityType
