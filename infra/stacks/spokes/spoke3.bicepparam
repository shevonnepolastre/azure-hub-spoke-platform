using './main.bicep'

param spokeName = 'ai-services'
param addressPrefix = '10.3.0.0/16'
param hubVnetId = '/subscriptions/83b96920-b3ed-4bd2-83cd-6984eca563a4/resourceGroups/az-pola-dev-hubspoke-eastus-rg-hub/providers/Microsoft.Network/virtualNetworks/az-pola-dev-hubspoke-eastus-vnet-hub'

param subnets = [
    {
        name: 'AIComputeSubnet' // AI VMs
        addressPrefix: '10.3.0.0/24'
    }     
    {
        name: 'AIDataSubnet' // AI Data
        addressPrefix: '10.3.1.0/24'
    }
    { 
        name: 'AIServicesSubnet' // Azure OpenAI, Cognitive Services private endpoints
        addressPrefix: '10.3.2.0/24'
    }
    { 
        name: 'MLOpsSubnet' // MLOps tools, model registry, experiment tracking
        addressPrefix: '10.3.3.0/24'
    }
 ]

