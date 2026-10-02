targetScope = 'resourceGroup'
param labId string
param location string = resourceGroup().location
@description('Public GHCR image for this lab, pinned by sha256 digest; AMD64 required.')
param image string
param adminSourceCidr string
var tags = { courseLabId: labId, purpose: 'azure-linux-course' }
resource env 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: 'course-aca-env', location: location, tags: tags
  properties: {
    appLogsConfiguration: { destination: 'azure-monitor' }
    workloadProfiles: [{ name: 'Consumption', workloadProfileType: 'Consumption' }]
  }
}
resource app 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'course-api', location: location, tags: tags
  properties: {
    managedEnvironmentId: env.id
    workloadProfileName: 'Consumption'
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true, targetPort: 8080, transport: 'auto', allowInsecure: false
        ipSecurityRestrictions: [{ name: 'only-admin', action: 'Allow', ipAddressRange: adminSourceCidr }]
      }
    }
    template: {
      containers: [{
        name: 'api', image: image
        resources: { cpu: json('0.25'), memory: '0.5Gi' }
        probes: [{
          type: 'Readiness'
          httpGet: { path: '/health', port: 8080 }
          initialDelaySeconds: 5, periodSeconds: 10
        }]
      }]
      scale: { minReplicas: 0, maxReplicas: 1 }
    }
  }
}
output fqdn string = app.properties.configuration.ingress.fqdn
