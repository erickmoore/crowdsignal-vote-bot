param location string
param name string

var appName = 'me-${location}-${name}'

resource containerApp 'Microsoft.App/managedEnvironments@2024-03-01' = {
  location: location
  name: appName
  kind: 'managedEnvironment'
  properties:{
    workloadProfiles: [
      {
        workloadProfileType: 'Consumption'
        name: 'Consumption'
      }
    ]
  }
}

output containerEnvId string = containerApp.id
