targetScope='subscription'

var mode = 'All'

resource allowed_vnet_peers 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'allowed-vnet-peers'
  properties: {
    description: 'Specifies the allowed peers for Virtual Networks.'
    displayName: 'allowed-vnet-peers'
    metadata: {
      version: '1.0'
      category: 'Network'
    }
    mode: mode
    policyType: 'Custom'
    parameters: {
      effect:{
        type: 'String'
        defaultValue: 'Deny'
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
      }
      allowedVnetPeers: {
        type: 'Array'
        metadata: {
          displayName: 'Virtual network Id'
          description: 'Resource Id of the virtual network. Example: /subscriptions/YourSubscriptionId/resourceGroups/YourResourceGroupName/providers/Microsoft.Network/virtualNetworks/Name'
        }
      }
    }
    policyRule: {
      if: {
        anyOf: [
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Network/virtualNetworks'
              }
              {
                count: {
                  field: 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings[*]'
                  where:{
                    field: 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings[*].remoteVirtualNetwork.id'
                    notin: '[parameters(\'allowedVnetPeers\')]'
                  } 
                }
                greater: 0      
              }              
            ]
          }
          {            
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings'
              }              
              {                  
                  field: 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings/remoteVirtualNetwork.id'
                  notin: '[parameters(\'allowedVnetPeers\')]'
              }
            ]
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}
