## Hub-and-Spoke Network Infrastructure

I built this Azure hub-and-spoke network as a portfolio project to demonstrate hands-on infrastructure skills. After managing Azure projects for years as a program manager, I wanted to prove I could design and implement the architecture—not just coordinate the teams building it.

---

## What This Is

A production-style network topology with one central hub and three isolated workload environments—the kind of setup you’d expect at a mid-to-large organization running Azure.

![Azure Hub and Spoke Architecture](./documentation/diagrams/hub-spoke-architecture.png)

---

## Real-Life Scenario

### The Company
A mid-sized professional services firm with approximately 1,000 employees undergoing rapid digital transformation. The organization runs three critical IT workloads that must coexist securely in Azure.

### The Challenge
The company’s IT landscape includes:

- **Customer-facing web application**  
  A client portal used by 5,000+ external customers to access project updates, documents, and billing. This workload must be internet-accessible, highly available, and performant.

- **Internal employee intranet**  
  SharePoint sites, HR systems, file shares, and business applications used daily by all 1,000 employees. This environment must never be directly exposed to the internet but requires secure connectivity to on-premises systems via VPN.

- **AI experimentation environment**  
  A new initiative where the data science team builds machine learning models using sensitive client data. This workload requires expensive GPU compute and strict isolation to prevent accidental data exposure or runaway costs.

### Why They Needed Hub-and-Spoke

The company initially considered three options:

- **One large VNet**  
  A security risk—if the web application were compromised, attackers could potentially access internal HR systems or AI training data.

- **Three isolated VNets with no connectivity**  
  Prevents centralized monitoring, logging, and VPN access while tripling the cost of shared services.

- **Hub-and-spoke topology**  
  Provides workload isolation while centralizing security and shared services.

### The Solution

A hub-and-spoke architecture delivers:

- **Strong security boundaries**  
  AI workloads are fully isolated from the public-facing web application. A breach in one spoke cannot pivot to another.

- **Cost efficiency**  
  A single Azure Bastion, VPN Gateway, and Azure Firewall serve all workloads instead of duplicating resources per environment.

- **Centralized monitoring**  
  The network team can observe traffic patterns across all spokes from a single Log Analytics workspace hosted in the hub.

- **Flexible access control**  
  The web team has Contributor access to spoke1, IT owns spoke2, the data science team controls spoke3, and the network team maintains the hub foundation.

- **Traffic inspection**  
  All inter-spoke and outbound traffic is routed through the hub, where Azure Firewall inspects and logs activity.

- **Compliance and policy enforcement**  
  Policies are analyzed and implemented to meet the security and governance requirements of each workload.

### Real-World Context

This design mirrors patterns I observed while managing Azure projects in real enterprise environments.
