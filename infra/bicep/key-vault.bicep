targetScope = 'resourceGroup'
param labId string
param location string = resourceGroup().location
param adminSourceCidr string
resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-${uniqueString(resourceGroup().id,labId)}'
  location: location
  tags: { courseLabId: labId, purpose: 'azure-linux-course' }
  properties: {
    tenantId: tenant().tenantId
    sku: { family: 'A', name: 'standard' }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'None', defaultAction: 'Deny'
      ipRules: [{ value: adminSourceCidr }]
    }
  }
}
output vaultName string = vault.name
output vaultId string = vault.id
