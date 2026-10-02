targetScope = 'resourceGroup'
param labId string
param location string = resourceGroup().location
var tags = { courseLabId: labId, purpose: 'azure-linux-course' }
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = { name: 'course-vnet' }
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = { name: 'server-subnet', parent: vnet }
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'st${uniqueString(resourceGroup().id, labId)}'
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: { name: 'Standard_LRS' }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    publicNetworkAccess: 'Disabled'
    networkAcls: { defaultAction: 'Deny', bypass: 'None' }
  }
}
resource pe 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'blob-pe', location: location, tags: tags
  properties: {
    subnet: { id: subnet.id }
    privateLinkServiceConnections: [{
      name: 'blob'
      properties: { privateLinkServiceId: storage.id, groupIds: ['blob'] }
    }]
  }
}
resource zone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}', location: 'global', tags: tags
}
resource link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'course-link', parent: zone, location: 'global'
  properties: { virtualNetwork: { id: vnet.id }, registrationEnabled: false }
}
resource group 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  name: 'default', parent: pe
  properties: { privateDnsZoneConfigs: [{ name: 'blob', properties: { privateDnsZoneId: zone.id } }] }
}
output storageName string = storage.name
output storageId string = storage.id
output blobHost string = '${storage.name}.blob.${environment().suffixes.storage}'
