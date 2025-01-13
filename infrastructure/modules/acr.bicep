param location string
param name string

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  location: location
  name: 'acr${name}'
  sku: {
    name: 'Standard'
  }
}

output acrId string = acr.id
output acrFQDN string = acr.properties.loginServer
