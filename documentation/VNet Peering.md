# VNet Peering Implementation

## Research & Planning

Before writing code, I reviewed Microsoft's documentation to understand the recommended approach:
- [VNet Peering Bicep reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/virtualnetworkpeerings?pivots=deployment-language-bicep)
- [Azure Quickstart templates](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.network/existing-vnet-to-vnet-peering/main.bicep)

## Design Decision: When to Create Peerings

I had to decide when in the deployment process to establish peerings. Since peering requires both vnets to exist, I couldn't peer during hub deployment (spokes don't exist yet). 

I have ClaudeAI configured so that it doesn't give me the bicep code, but advises and coaches me in thinking on how to approach it.  It helped me realize that the hub and spokes need to be created before the peering can be made. Therefore, the peering needs to be part of the spoke bicep.  

## Modular Implementation

Following the modular pattern used throughout this project, I created a reusable `peering.bicep` module:

```bicep
// modules/network/peering.bicep
@description('Name of the local VNet (where this peering resource lives)')
param localVnetName string

@description('Resource ID of the remote VNet (what you are peering to)')
param remoteVnetId string

@description('Name for this peering connection')
param peeringName string

// Reference existing local vnet
resource localVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: localVnetName
}

// Create peering as child of local vnet
resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  parent: localVnet
  name: peeringName
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: remoteVnetId
    }
  }
}

output peeringId string = peering.id
output peeringName string = peering.name
```

This module gets called **twice** per spoke - once for each direction.

## Spoke Deployment with Automatic Peering

In `stacks/spokes/main.bicep`, after creating the spoke vnet, I call the peering module twice:

```bicep
// Peering: Spoke → Hub (lives in spoke vnet)
module spokeToHub '../../modules/network/peering.bicep' = {
  name: 'peering-spoke-${spokeName}-to-hub'
  scope: spokeRg  // Deploy to spoke resource group
  params: {
    localVnetName: spokeVnet.outputs.vnetName
    remoteVnetId: hubVnetId
    peeringName: 'spoke-${spokeName}-to-hub'
  }
}

// Peering: Hub → Spoke (lives in hub vnet)
module hubToSpoke '../../modules/network/peering.bicep' = {
  name: 'peering-hub-to-spoke-${spokeName}'
  scope: resourceGroup(hubRgName)  // Deploy to hub resource group
  params: {
    localVnetName: hubVnetName
    remoteVnetId: spokeVnet.outputs.vnetId
    peeringName: 'hub-to-spoke-${spokeName}'
  }
}
```

## Getting the Hub VNet ID

Each spoke needs the hub's vnet resource ID to establish peering. I retrieved this using PowerShell:

```powershell
# First, find the hub vnet details
Get-AzVirtualNetwork | Where-Object {$_.Name -like "*hub*"}

# Then get the full resource ID
$hubVnetId = (Get-AzVirtualNetwork `
  -Name az-pola-dev-hubspoke-eastus-vnet-hub `
  -ResourceGroupName az-pola-dev-hubspoke-eastus-rg-hub).Id

# Output: /subscriptions/.../virtualNetworks/az-pola-dev-hubspoke-eastus-vnet-hub
```

I added this ID to each spoke's parameter file:

```bicep
// spoke1.bicepparam
using './main.bicep'

param spokeName = 'app'
param hubVnetId = '/subscriptions/83b96920-b3ed-4bd2-83cd-6984eca563a4/resourceGroups/az-pola-dev-hubspoke-eastus-rg-hub/providers/Microsoft.Network/virtualNetworks/az-pola-dev-hubspoke-eastus-vnet-hub'
param addressPrefix = '10.1.0.0/16'
// ... subnets ...
```

## Validation

Before deploying, I validated the template using the Bicep linter:

```bash
bicep build main.bicep
```

There were errors as anyone would expect.  I went and resolved each of the errors that the linter found.  After the 5th or 6th attempt, all errors had been resolved. 

## Deployment & Verification

After deploying each spoke, I verified peering status in the Azure Portal.  I was beyond happy when I saw that the peerings had been created. 

## Lessons Learned

**Working with Claude:** I used Claude AI as a technical advisor throughout this project, with specific instructions to guide me rather than provide complete solutions. When I asked about peering implementation, Claude helped me think through the deployment sequence and dependencies without just handing me the code. This forced me to understand *why* peerings needed to be created during spoke deployment rather than just copying a solution.  There is nothing wrong with using AI. Even senior-level people use it, so do not think that you can't use it.  You just have to use it in a way that will help you learn; not just giving you the answer. 

**Scope matters:** Initially, I tried to create both peerings in the spoke's resource group. This failed because the hub→spoke peering needs to be a child of the hub vnet. Understanding the `scope` parameter and how modules can deploy to different resource groups was key.

**Bidirectional is manual:** Azure doesn't automatically create the return peering. Both directions must be explicitly defined. I chose to create both peerings from the spoke deployment so there's no separate peering step to forget.

## Cost

Being that I am using my own tenant, I made sure that the creationg of peerings would not come with a substanial cost. Fortunately, it doesn't. It seems to be very minimal.  