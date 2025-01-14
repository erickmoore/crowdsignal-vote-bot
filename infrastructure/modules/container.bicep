param location string
param name string
param acrFQDN string
param containerImage string
param containerEnvironmentId string

var appName = 'me-${location}-${name}'
var acrName = split(acrFQDN, '.')[0]

resource container 'Microsoft.App/containerApps@2024-03-01' = {
  location: location
  name: appName
  properties: {
    managedEnvironmentId: containerEnvironmentId
    configuration: {
      ingress: {
        external: false
      }
      registries: [
        {
          server: acrFQDN
          username: acrName
        }
      ]
    }
    template: {
      containers: [
        {
          image: '${acrFQDN}/${containerImage}:latest'
          name: 'votebots'
          resources: {
            cpu: 1
            memory: '4Gi'
          }
        }
      ]
    }
  }
}
