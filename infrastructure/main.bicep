targetScope = 'subscription'

param location string = 'eastus'


resource rg 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  location: location
  name: 'rg-${location}-votebots'
}

module acr 'modules/acr.bicep' = {
  scope: rg
  name: 'acr'
  params: {
    name: 'acr'
    location: location
  }
}

module containerEnvironment 'modules/containerapp.bicep' = {
  scope: rg
  name: 'votebots'
  params: {
    location: location
    name: 'votebots'
  }
}

module container 'modules/container.bicep' = {
  scope: rg
  name: 'votebots-container'
  params: {
    containerEnvironmentId: containerEnvironment.outputs.containerEnvId
    location: location
    name: 'votebots'
    acrFQDN: acr.outputs.acrFQDN
    containerImage: 'votebots'
  }
}
