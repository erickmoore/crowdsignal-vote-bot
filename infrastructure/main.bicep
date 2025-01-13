targetScope = 'subscription'

param location string = 'eastus'


resource rg 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  location: location
  name: 'rg-${location}-votebots'
}

module containerEnvironment 'modules/containerapp.bicep' = {
  scope: rg
  name: 'votebots'
  params: {
    location: location
    name: 'votebots'
  }
}
