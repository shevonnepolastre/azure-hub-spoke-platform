## Hub-and-Spoke Network Infrastructure

I built this Azure hub-and-spoke network as a portfolio project to demonstrate hands-on 
infrastructure skills. After managing Azure projects for years as a program manager, I 
wanted to prove I could design and implement the architecture—not just coordinate the 
teams building it.

---

## What This Is

A production-style network topology with one central hub and three isolated workload 
environments—the kind of setup you'd expect at a mid-to-large organization running Azure.

![Azure Hub and Spoke Architecture](./documentation/diagrams/hub-spoke-architecture.png)

---

## Real-Life Scenario

### The Company
A mid-sized professional services firm with approximately 1,000 employees undergoing 
rapid digital transformation. The organization runs three critical IT workloads that 
must coexist securely in Azure.

### The Challenge
The company's IT landscape includes:

- **Customer-facing web application**  
  A client portal used by 5,000+ external customers to access project updates, 
  documents, and billing. This workload must be internet-accessible, highly available, 
  and performant.

- **Internal employee intranet**  
  SharePoint sites, HR systems, file shares, and business applications used daily by 
  all 1,000 employees. This environment must never be directly exposed to the internet 
  but requires secure connectivity to on-premises systems via VPN.

- **AI experimentation environment**  
  A new initiative where the data science team builds machine learning models using 
  sensitive client data. This workload requires expensive GPU compute and strict 
  isolation to prevent accidental data exposure or runaway costs.

### Why They Needed Hub-and-Spoke

The company initially considered three options:

- **One large VNet**  
  A security risk—if the web application were compromised, attackers could potentially 
  access internal HR systems or AI training data.

- **Three isolated VNets with no connectivity**  
  Prevents centralized monitoring, logging, and VPN access while tripling the cost of 
  shared services.

- **Hub-and-spoke topology**  
  Provides workload isolation while centralizing security and shared services.

### The Solution

A hub-and-spoke architecture delivers:

- **Strong security boundaries**  
  AI workloads are fully isolated from the public-facing web application. A breach in 
  one spoke cannot pivot to another.

- **Cost efficiency**  
  A single Azure Bastion, VPN Gateway, and Azure Firewall serve all workloads instead 
  of duplicating resources per environment.

- **Centralized monitoring**  
  The network team can observe traffic patterns across all spokes from a single Log 
  Analytics workspace hosted in the hub.

- **Flexible access control**  
  The web team has Contributor access to spoke1, IT owns spoke2, the data science team 
  controls spoke3, and the network team maintains the hub foundation.

- **Traffic inspection**  
  All inter-spoke and outbound traffic is routed through the hub, where Azure Firewall 
  inspects and logs activity.

- **Compliance and policy enforcement**  
  Policies are analyzed and implemented to meet the security and governance requirements 
  of each workload.

### Real-World Context

This design mirrors patterns I observed while managing Azure projects in real enterprise 
environments.

## Modules and Stacks

After researching Bicep best practices and following Microsoft Learn sessions, I 
structured this project around reusable modules and deployment stacks. This pattern 
cleanly separates infrastructure components (modules) from deployment orchestration 
(stacks).

Modules act as the building blocks, with each one representing a single infrastructure 
component such as a virtual network or a peering connection. For example, the vnet.bicep 
module accepts parameters for the name, address space, and subnets, and then provisions 
a VNet resource. These modules are generic and reusable across multiple deployments.

Stacks handle orchestration by combining modules with environment-specific configuration. 
The hub stack includes a main.bicep orchestrator that imports the naming convention 
module, defines the hub's four subnets and CIDR ranges in a parameter file, and then 
invokes the vnet.bicep module using those values. The same pattern is applied to each 
of the three spoke stacks: the same vnet.bicep module, but with different parameters.

This separation allows me to reuse vnet.bicep four times (one hub and three spokes) 
without duplicating code, while each stack's parameter file clearly highlights what 
makes that environment unique.

## Incrementally Building

I'm building this incrementally so each component can be tested in isolation. Here's 
where things stand:

1. ✅ Naming Convention module
2. ✅ VNet bicep module
3. ✅ Stacks for the hub and three spokes:
   - Main bicep that connects the naming convention with the module bicep
   - Bicep parameter files per spoke
4. ✅ VNet peering — bidirectional between hub and all three spokes, confirmed 
   Connected and Fully Synchronized in the portal
5. ✅ Network Security Groups:
   - NSG module (`nsg.bicep`) with configurable rules passed in via parameter files
   - NSG association module (`nsg_associate.bicep`) that attaches NSGs to subnets
   - Conditional deployment logic so NSGs are only created for subnets that actually 
     exist in each spoke — no orphaned resources
   - Least-privilege rule sets per subnet tier across all three spokes
6. 🔲 CI/CD pipelines via GitHub Actions
7. 🔲 Intune Autopilot integration

Note: This is a live README that I update with every progression.

## NSG Design

Each spoke has a different subnet structure, so the NSG design needed to be flexible. 
Rather than hardcoding which NSGs to create per spoke, the template checks whether a 
subnet exists in the parameter file before creating or attaching its NSG. This keeps 
the template reusable — adding a new spoke only requires a new parameter file.

### Public Spoke — internet-facing workloads
| Subnet | Traffic Rules |
|--------|--------------|
| WebSubnet | Allows HTTP/HTTPS inbound from internet; outbound to AppSubnet on 443 |
| AppSubnet | Allows inbound from WebSubnet on 443; outbound to DataSubnet on 1433; blocks SSH and RDP from internet |
| DataSubnet | Allows inbound from AppSubnet on 1433 only; denies everything else |

### Intranet Spoke — internal employee systems
| Subnet | Traffic Rules |
|--------|--------------|
| AppSubnet | Blocks all inbound from internet; allows outbound to private endpoints and AI-Services MLOps subnet |

### AI-Services Spoke — ML and data science workloads
| Subnet | Traffic Rules |
|--------|--------------|
| AppSubnet | Allows inbound from intranet AppSubnet on 443 |
| ComputeSubnet | Allows inbound from MLOps; outbound to AIData and AIServices |
| DataSubnet | Allows inbound from AICompute on 1433 |
| MLOpsSubnet | Allows outbound to AICompute, AIData, and AIServices |

One thing worth calling out — there are no explicit return traffic rules in any of the 
rule sets. That's intentional. Azure NSGs are stateful, so return traffic for established 
connections is handled automatically.

For full details on the NSG implementation see [NSG.md](./documentation/NSG.md).