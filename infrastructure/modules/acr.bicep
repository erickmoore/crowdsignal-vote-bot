param name string
param location string

var id = uniqueString(subscription().subscriptionId, name)

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  location: location
  name: toLower('${name}${id}')
  properties: {
    adminUserEnabled: true
  }
  sku: {
    name: 'Standard'
  }
}

output acrId string = acr.id
output acrFQDN string = acr.properties.loginServer
