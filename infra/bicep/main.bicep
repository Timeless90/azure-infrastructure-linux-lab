targetScope = 'resourceGroup'
param labId string
param location string = resourceGroup().location
param adminUsername string
@secure()
param sshPublicKey string
param adminSourceCidr string
param imageVersion string
param vmSize string = 'Standard_B1s'
param vnetCidr string = '10.10.0.0/16'
param clientSubnetCidr string = '10.10.1.0/24'
param serverSubnetCidr string = '10.10.2.0/24'
param clientIp string = '10.10.1.4'
param serverIp string = '10.10.2.4'
var tags = { courseLabId: labId, purpose: 'azure-linux-course' }
var sshRule = {
  name: 'admin-ssh'
  properties: {
    priority: 100, direction: 'Inbound', access: 'Allow', protocol: 'Tcp'
    sourceAddressPrefix: adminSourceCidr, sourcePortRange: '*'
    destinationAddressPrefix: '*', destinationPortRange: '22'
  }
}
var denyRule = {
  name: 'deny-other-inbound'
  properties: {
    priority: 4096, direction: 'Inbound', access: 'Deny', protocol: '*'
    sourceAddressPrefix: '*', sourcePortRange: '*'
    destinationAddressPrefix: '*', destinationPortRange: '*'
  }
}
resource clientNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'client-nsg', location: location, tags: tags
  properties: { securityRules: [sshRule, denyRule] }
}
resource serverNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'server-nsg', location: location, tags: tags
  properties: {
    securityRules: [sshRule, {
      name: 'client-web'
      properties: {
        priority: 200, direction: 'Inbound', access: 'Allow', protocol: 'Tcp'
        sourceAddressPrefix: '${clientIp}/32', sourcePortRange: '*'
        destinationAddressPrefix: '${serverIp}/32', destinationPortRange: '8080'
      }
    }, denyRule]
  }
}
resource routes 'Microsoft.Network/routeTables@2024-05-01' = {
  name: 'client-routes', location: location, tags: tags
  properties: { disableBgpRoutePropagation: false, routes: [] }
}
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'course-vnet', location: location, tags: tags
  properties: {
    addressSpace: { addressPrefixes: [vnetCidr] }
    subnets: [
      {
        name: 'client-subnet'
        properties: {
          addressPrefix: clientSubnetCidr
          defaultOutboundAccess: false
          networkSecurityGroup: { id: clientNsg.id }
          routeTable: { id: routes.id }
        }
      }
      {
        name: 'server-subnet'
        properties: {
          addressPrefix: serverSubnetCidr
          defaultOutboundAccess: false
          networkSecurityGroup: { id: serverNsg.id }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}
module client 'vm.bicep' = {
  name: 'client'
  params: {
    name: 'client', location: location, tags: tags
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'client-subnet')
    privateIp: clientIp, vmSize: vmSize, adminUsername: adminUsername
    sshPublicKey: sshPublicKey, imageVersion: imageVersion
  }
}
module server 'vm.bicep' = {
  name: 'server'
  params: {
    name: 'server', location: location, tags: tags
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'server-subnet')
    privateIp: serverIp, vmSize: vmSize, adminUsername: adminUsername
    sshPublicKey: sshPublicKey, imageVersion: imageVersion
  }
}
output clientPublicIp string = client.outputs.publicIp
output serverPublicIp string = server.outputs.publicIp
output clientPrivateIp string = clientIp
output serverPrivateIp string = serverIp
output serverPrincipalId string = server.outputs.principalId
output vnetId string = vnet.id
