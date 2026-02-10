using './spokemain.bicep'

param spokeName = 'ai-services'
param addressPrefix = '10.3.0.0/16'

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

