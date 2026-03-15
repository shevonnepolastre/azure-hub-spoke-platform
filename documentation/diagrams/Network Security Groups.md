Got it — your voice is direct, practical, and conversational. You write for someone who's actually doing the work, you flag where official docs differ from what actually works, and you skip the fluff. Here's the README rewritten in your voice:

```markdown
# NSG Design and Subnet Association

## What This Is
This covers the NSG setup for the hub-spoke network project. Each spoke has different 
subnets depending on its workload, so the template needed to be smart enough to only 
create and attach NSGs for subnets that actually exist in that spoke.

## Background
This is part of a hub-spoke network deployed for a 1,000-employee professional services 
firm across three spokes:
- **public** — web and app workloads facing the internet
- **intranet** — internal business apps
- **ai-services** — ML and AI compute

## What Changed

### New Files
| File | What it does |
|------|-------------|
| `modules/network/nsg.bicep` | Creates an NSG with whatever rules you pass in |
| `modules/network/nsg_associate.bicep` | Attaches an NSG to an existing subnet |

### Updated Files
| File | What changed |
|------|-------------|
| `spokes/main.bicep` | Added conditional NSG creation and association |
| `spokes/spoke1.bicepparam` | Added web, app, and data NSG rules |
| `spokes/spoke2.bicepparam` | Added app NSG rules |
| `spokes/spoke3.bicepparam` | Added compute, mlops, data, and app NSG rules |

## NSG Rules by Spoke

### Public (spoke1)
| Subnet | What it does |
|--------|-------------|
| WebSubnet | Allows HTTP/HTTPS inbound from internet; outbound to AppSubnet on 443 |
| AppSubnet | Allows inbound from WebSubnet on 443; outbound to DataSubnet on 1433; blocks SSH and RDP from internet |
| DataSubnet | Allows inbound from AppSubnet on 1433 only; denies everything else |

### Intranet (spoke2)
| Subnet | What it does |
|--------|-------------|
| AppSubnet | Blocks all inbound from internet; allows outbound to private endpoints and ai-services MLOps subnet |

### AI-Services (spoke3)
| Subnet | What it does |
|--------|-------------|
| AppSubnet | Allows inbound from intranet AppSubnet on 443 |
| ComputeSubnet | Allows inbound from MLOps; outbound to AIData and AIServices |
| DataSubnet | Allows inbound from AICompute on 1433 |
| MLOpsSubnet | Allows outbound to AICompute, AIData, and AIServices |

## Design Decisions

### Conditional Deployment
Each spoke has different subnets, so I couldn't just create all five NSGs every time — 
that would leave orphaned resources attached to nothing. Instead the template checks 
whether the subnet actually exists in the parameter file before creating the NSG or 
attaching it:

```bicep
module webNsg '../../modules/network/nsg.bicep' = if (length(filter(subnets, s => s.name == 'WebSubnet')) > 0) {
  ...
}
```

This keeps the template data-driven — the parameter file controls what gets deployed, 
not hardcoded spoke names. Adding a new spoke means writing a new param file, not 
touching the template.

### Why filter() and not contains()
I looked at `contains()` first but it won't work here because the subnets array contains 
objects, not plain strings:

```bicep
{ name: 'WebSubnet', addressPrefix: '10.1.0.0/24' }
```

`contains()` matches on the whole element, so it can't match against just the `name` 
property. `filter()` with a lambda lets you check a specific property across every 
item in the array.

### How NSG Association Actually Works
Azure doesn't have a standalone "attach NSG to subnet" operation. The 
`nsg_associate.bicep` module gets around this by reading the subnet's existing 
`addressPrefix` and redeploying the subnet resource with the NSG ID added. It 
preserves everything already on the subnet and just adds the association.

### Return Traffic Rules
You'll notice there are no explicit return traffic rules in any of the NSG rule sets. 
That's intentional — Azure NSGs are stateful, so return traffic for established 
connections is allowed automatically.

## How to Deploy

Run this for each spoke:

```powershell
New-AzSubscriptionDeployment `
  -Location eastus `
  -TemplateFile ./spokes/main.bicep `
  -TemplateParameterFile ./spokes/spoke1.bicepparam
```

Swap in `spoke2.bicepparam` and `spoke3.bicepparam` for the other two.

## Future Improvements
- Add NSG flow logs to Log Analytics so you can actually see what traffic is hitting 
the rules
- Add AzureBastion inbound rules for management subnets
- Look at Azure Policy to enforce NSG association across all subnets automatically
```