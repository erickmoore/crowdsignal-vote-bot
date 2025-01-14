targetScope = 'subscription'

param time string = utcNow()
param name string = 'votebot'
param location string = 'eastus'
param locations array = [
  'eastus'
  'eastus2'
  'westus2'
  'westcentralus'
  'northcentralus'
  'centralus'
  'southcentralus'
]



resource rg 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  location: location
  name: 'rg-${location}-votebots'
}

module acr 'modules/acr.bicep' = {
  scope: rg
  name: 'acr'
  params: {
    name: name
    location: location
  }
}

module containerEnvironment 'modules/containerapp.bicep' = {
  scope: rg
  name: 'containerEnvironment-${time}'
  params: {
    location: location
    name: name
  }
}

module container 'modules/container.bicep' = {
  scope: rg
  name: 'containers-${time}'
  params: {
    containerEnvironmentId: containerEnvironment.outputs.containerEnvId
    location: location
    name: name
    acrFQDN: acr.outputs.acrFQDN
    containerImage: name
  }
}
