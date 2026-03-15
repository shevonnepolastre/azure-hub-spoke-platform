# Hub-and-Spoke Network Infrastructure

I'm a **Senior Program Manager** transitioning into **Azure Infrastructure Engineering**. 
I've spent years managing Azure projects — coordinating the teams, tracking the 
milestones, managing the risks. But I wanted to prove I could actually build the thing, 
not just manage it.

This project is my way of doing that.

---

## What This Is

A production-style hub-and-spoke network topology built entirely in Bicep — the kind 
of architecture you'd find at a mid-to-large organization running workloads in Azure. 
One central hub, three isolated spoke environments, NSGs enforcing least-privilege 
traffic between tiers, and everything deployed as code.

![Azure Hub and Spoke Architecture](./documentation/diagrams/hub-spoke-architecture.png)

---

## The Scenario

### The Company
A professional services firm with about 1,000 employees going through a digital 
transformation. They're moving workloads to Azure and need a network design that's 
secure, scalable, and doesn't cost a fortune to operate.

### The Problem
They have three very different workloads that need to coexist in Azure:

- **Customer-facing web application**  
  A client portal used by 5,000+ external customers to access project updates, 
  documents, and billing. It needs to be internet-accessible and highly available.

- **Internal employee intranet**  
  SharePoint, HR systems, file shares — the stuff all 1,000 employees use every day. 
  This should never be directly exposed to the internet but needs connectivity back 
  to on-premises systems.

- **AI experimentation environment**  
  The data science team is building ML models on sensitive client data. This needs 
  strict isolation — a misconfiguration here could expose data or run up a massive 
  compute bill.

They looked at three options before landing on hub-and-spoke:

- **One big VNet** — cheaper upfront but a security nightmare. A breach in the web 
  app could pivot straight to HR data or AI training sets.
- **Three isolated VNets** — great isolation but no way to share services, centralize 
  monitoring, or run a single VPN gateway. Costs triple.
- **Hub-and-spoke** — workload isolation plus centralized shared services. This is 
  the right answer.

### What the Architecture Delivers

- Each spoke is isolated — a breach in one can't reach another
- One Azure Bastion, one VPN Gateway, one Log Analytics workspace serving all three 
  spokes instead of duplicating resources
- The network team sees all traffic from a single pane of glass
- Each team gets scoped access — web team owns spoke1, IT owns spoke2, data science 
  owns spoke3
- All inter-spoke and outbound traffic routes through the hub for inspection

This mirrors patterns I've seen firsthand managing Azure projects in federal and 
enterprise environments.

---

## How It's Built

I structured this around reusable Bicep modules and per-spoke parameter files. The 
idea is simple: modules are the building blocks, parameter files are what make each 
environment unique.

For example, `vnet.bicep` is deployed four times — once for the hub, once for each 
spoke — with different parameters each time. No duplicated code, just different inputs.

The same pattern applies to NSGs. One `nsg.bicep` module, one `nsg_associate.bicep` 
module, and each spoke's parameter file defines exactly which rules it needs.

---

## Where Things Stand

I'm building this incrementally so I can test each piece before moving to the next:

1. ✅ Naming convention module
2. ✅ VNet module
3. ✅ Hub and three spoke stacks with parameter files
4. ✅ Bidirectional VNet peering — confirmed Connected and Fully Synchronized in 
   the portal for all three spokes
5. ✅ Network Security Groups — conditional deployment per spoke, least-privilege 
   rules per subnet tier, NSG-to-subnet association via Bicep
6. 🔲 CI/CD pipelines via GitHub Actions
7. 🔲 Intune Autopilot integration

---

## NSG Design

Each spoke has a completely different subnet structure depending on its workload. 
The public spoke has web, app, and data tiers. The intranet spoke only has an app 
tier. The AI spoke has compute, data, services, and MLOps subnets.

Rather than hardcoding which NSGs to create for each spoke, I used Bicep's `filter()` 
function to check whether a subnet actually exists in the parameter file before 
creating or attaching its NSG. No orphaned resources, and adding a new spoke only 
requires a new parameter file — no changes to the template.

### Public Spoke — internet-facing workloads
| Subnet | What it controls |
|--------|-----------------|
| WebSubnet | Allows HTTP/HTTPS inbound from internet; outbound to AppSubnet on 443 |
| AppSubnet | Allows inbound from WebSubnet on 443; outbound to DataSubnet on 1433; blocks SSH and RDP from internet |
| DataSubnet | Allows inbound from AppSubnet on 1433 only; denies everything else inbound |

### Intranet Spoke — internal employee systems
| Subnet | What it controls |
|--------|-----------------|
| AppSubnet | Blocks all inbound from internet; allows outbound to private endpoints and AI-Services |

### AI-Services Spoke — ML and data science workloads
| Subnet | What it controls |
|--------|-----------------|
| AppSubnet | Allows inbound from intranet AppSubnet on 443 |
| ComputeSubnet | Allows inbound from MLOps; outbound to AIData and AIServices |
| DataSubnet | Allows inbound from AICompute on 1433 |
| MLOpsSubnet | Allows outbound to AICompute, AIData, and AIServices |

No explicit return traffic rules anywhere — Azure NSGs are stateful so that's handled 
automatically.

For the full details on the NSG implementation, see [NSG.md](./documentation/NSG.md).

---

Note: This is a live README. I update it as the project progresses.