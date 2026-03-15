Here's the rewrite in your voice:

```markdown
# VNet Peering Implementation

## Research & Planning

Before writing any code I went through Microsoft's documentation to understand the 
recommended approach:
- [VNet Peering Bicep reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/virtualnetworkpeerings?pivots=deployment-language-bicep)
- [Azure Quickstart templates](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.network/existing-vnet-to-vnet-peering/main.bicep)

## When to Create the Peerings

This took some thinking. Peering requires both VNets to exist first, so I couldn't 
do it during hub deployment — the spokes don't exist yet at that point. I worked 
through this with Claude AI, which I have configured to coach me through problems 
rather than just hand me the answer. That conversation helped me realize the peering 
had to live inside the spoke deployment, not the hub.

I want to be clear about using AI — there's nothing wrong with it. Senior engineers 
use it too. The key is using it in a way that makes you actually learn, not just 
copying whatever it gives you.

## How It's Built

I followed the same modular pattern used throughout this project and created a 
reusable `peering.bicep` module:

```bicep
// modules/network/peering.bicep
@description('Name of the local VNet (where this peering resource lives)')
param localVnetName string

@description('Resource ID of the remote VNet (what you are peering to)')
param remoteVnetId string

@description('Name for this peering connection')
param peeringName string

resource localVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: localVnetName
}

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

This module gets called **twice** per spoke — once for each direction.

In `stacks/spokes/main.bicep`, after the spoke VNet is created, I call the peering 
module twice:

```bicep
// Peering: Spoke → Hub (lives in spoke vnet)
module spokeToHub '../../modules/network/peering.bicep' = {
  name: 'peering-spoke-${spokeName}-to-hub'
  scope: spokeRg
  params: {
    localVnetName: spokeVnet.outputs.vnetName
    remoteVnetId: hubVnetId
    peeringName: 'spoke-${spokeName}-to-hub'
  }
}

// Peering: Hub → Spoke (lives in hub vnet)
module hubToSpoke '../../modules/network/peering.bicep' = {
  name: 'peering-hub-to-spoke-${spokeName}'
  scope: resourceGroup(hubRgName)  // deploys to hub resource group
  params: {
    localVnetName: hubVnetName
    remoteVnetId: spokeVnet.outputs.vnetId
    peeringName: 'hub-to-spoke-${spokeName}'
  }
}
```

## Getting the Hub VNet ID

Each spoke needs the hub VNet resource ID to establish peering. I pulled it using 
PowerShell:

```powershell
$hubVnetId = (Get-AzVirtualNetwork `
  -Name az-pola-dev-hubspoke-eastus-vnet-hub `
  -ResourceGroupName az-pola-dev-hubspoke-eastus-rg-hub).Id
```

Then added it to each spoke's parameter file:

```bicep
param hubVnetId = '/subscriptions/83b96920-b3ed-4bd2-83cd-6984eca563a4/resourceGroups/az-pola-dev-hubspoke-eastus-rg-hub/providers/Microsoft.Network/virtualNetworks/az-pola-dev-hubspoke-eastus-vnet-hub'
```

## Deployment

Before deploying I ran the Bicep linter to catch errors:

```bash
bicep build main.bicep
```

There were errors — that's expected. I worked through them one by one. After about 
five or six attempts everything was clean and the deployment went through. Seeing 
the peerings show up in the portal as Connected and Fully Synchronized was a good 
moment.

## What I Learned

**Scope matters more than you'd think.** I initially tried to create both peerings 
in the spoke's resource group. That failed because the hub→spoke peering has to be 
a child of the hub VNet. Once I understood that modules can deploy to different 
resource groups using the `scope` parameter, it clicked.

**Azure doesn't create the return peering automatically.** Both directions have to 
be explicitly defined. I put both inside the spoke deployment so there's no separate 
step to forget.

**Deployment sequence is a real constraint.** You can't peer what doesn't exist yet. 
Thinking through the dependency order before writing code saved a lot of back and 
forth.

## Cost

I'm running this in my own tenant so I wanted to make sure peering wouldn't rack up 
a big bill. It's very minimal — not something to worry about in a lab environment.
