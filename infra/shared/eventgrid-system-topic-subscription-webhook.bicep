param systemTopicName string
param subscriptionName string
@secure()
param endpointUrl string
param includedEventTypes array

resource systemTopic 'Microsoft.EventGrid/systemTopics@2021-06-01-preview' existing = {
  name: systemTopicName
}

resource eventGridSubscription 'Microsoft.EventGrid/eventSubscriptions@2024-06-01-preview' = {
  name: subscriptionName
  scope: systemTopic
  properties: {
    destination: {
      endpointType: 'WebHook'
      properties: {
        endpointUrl: endpointUrl
      }
    }
    filter: {
      includedEventTypes: includedEventTypes
    }
    eventDeliverySchema: 'EventGridSchema'
  }
}
