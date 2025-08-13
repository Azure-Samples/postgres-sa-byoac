# 2.4 Verify Azure Resource Providers

There are a few Azure Resource Providers that will need to be registered on the Azure Subscription for the solution accelerator to successfully deploy the Azure Machine Learning resources.

The required Azure Resource Providers are:

- `Microsoft.AlertsManagement`
- `Microsoft.ApiManagement`
- `Microsoft.Cdn`
- `Microsoft.MachineLearningServices`
- `Microsoft.PolicyInsights`

Follow these steps to check if the Resource Providers are registered, and if not then you'll register them:

1. Run the following command to check whether the Resource Providers are registered on your Azure Subscription:

    ```azurecli title="" linenums="0"
    az provider list --query "[?namespace == 'Microsoft.ApiManagement' || namespace=='Microsoft.AlertsManagement' || namespace=='Microsoft.Cdn' || namespace == 'Microsoft.MachineLearningServices' || namespace=='Microsoft.PolicyInsights'].{Namespace: namespace, RegistrationState: registrationState}" -o table
    ```

    Alternatively, you could also navigate to the **Subscription** within the **Azure Portal**, then navigate to **Resource providers** under **Settings**. This will also allow you to view the registered Resource Providers for the Subscription, as well as register them.

    The console output will look similar to the following:

    ```text title="" linenums="0"
    Namespace                          RegistrationState    
    ---------------------------------  -------------------  
    Microsoft.MachineLearningServices  NotRegistered
    Microsoft.PolicyInsights           NotRegistered    
    Microsoft.Cdn                      Registered
    Microsoft.ApiManagement            NotRegistered
    Microsoft.AlertsManagement         Registered
    ```

    The console output will show the Resource Provider and the **RegistrationState**. If the **RegistrationState** shows a value of **Registered** then the Resource Provider is registered on the Azure Subscription.

2. To register all the Resource Providers on the Azure Subscription, run the following commands:

    ```azurecli title="" linenums="0"
    az provider register --namespace Microsoft.AlertsManagement    
    az provider register --namespace Microsoft.ApiManagement
    az provider register --namespace Microsoft.Cdn
    az provider register --namespace Microsoft.MachineLearningServices
    az provider register --namespace Microsoft.PolicyInsights
    ```

    If one or more of the Resource Providers are already registered, then only run the command for the Resource Providers that are not registered.
