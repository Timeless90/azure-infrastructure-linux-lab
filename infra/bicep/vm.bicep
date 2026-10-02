param name string
param location string
param tags object
param subnetId string
param privateIp string
param vmSize string
param adminUsername string
@secure()
param sshPublicKey string
param imageVersion string
resource pip 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: '${name}-pip'
  location: location
  tags: tags
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Static', publicIPAddressVersion: 'IPv4' }
}
resource nic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: '${name}-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [{
      name: 'ipconfig1'
      properties: {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: privateIp
        subnet: { id: subnetId }
        publicIPAddress: { id: pip.id }
      }
    }]
  }
}
resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: '${name}-vm'
  location: location
  tags: tags
  identity: { type: 'SystemAssigned' }
  properties: {
    hardwareProfile: { vmSize: vmSize }
    storageProfile: {
      imageReference: { publisher: 'Canonical', offer: 'ubuntu-24_04-lts', sku: 'server', version: imageVersion }
      osDisk: { createOption: 'FromImage', managedDisk: { storageAccountType: 'Standard_LRS' }, deleteOption: 'Delete' }
    }
    osProfile: {
      computerName: '${name}-vm'
      adminUsername: adminUsername
      customData: base64(loadTextContent('../cloud-init/base.yaml'))
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: { publicKeys: [{ path: '/home/${adminUsername}/.ssh/authorized_keys', keyData: sshPublicKey }] }
      }
    }
    networkProfile: { networkInterfaces: [{ id: nic.id, properties: { primary: true, deleteOption: 'Delete' } }] }
    diagnosticsProfile: { bootDiagnostics: { enabled: true } }
  }
}
output publicIp string = pip.properties.ipAddress
output nicId string = nic.id
output vmId string = vm.id
output principalId string = vm.identity.principalId
