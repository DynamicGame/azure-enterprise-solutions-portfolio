# Three-tier Azure network

**VNets · NSGs / ASGs · Load balancers · Firewall · Bastion · Private endpoints**

## Purpose and status

Design network boundaries for a web, application and database workload. Component scripts cover the infrastructure, but end-to-end application connectivity and security enforcement have not been demonstrated by repository evidence. Integration work is in progress.

## Architecture

The [architecture notes](three-tier-architecture/architecture/README.md) distinguish the intended application flow from the resources currently scripted. The design uses `10.0.0.0/16`:

| Subnet | CIDR | Use |
| --- | --- | --- |
| web-subnet | 10.0.1.0/24 | Web VM NICs |
| app-subnet | 10.0.2.0/24 | App VM NICs and internal load-balancer frontend |
| db-subnet | 10.0.3.0/24 | Reserved database-tier subnet; SQL endpoint is elsewhere |
| AzureBastionSubnet | 10.0.10.0/26 | Bastion |
| AzureFirewallSubnet | 10.0.20.0/26 | Firewall |
| private-endpoints | 10.0.30.0/24 | SQL, Blob and Key Vault private endpoints |

## Script order

Scripts are in [three-tier-architecture/scripts](three-tier-architecture/scripts/). Review configuration before execution:

1. `deploy-network.ps1` — VNet, subnets, ASGs, NSGs and empty route tables.
2. `deploy-firewall.ps1` — Firewall, policy and outbound rules.
3. `deploy-web.ps1` — public load balancer and web VMs.
4. `deploy-app.ps1` — internal load balancer and app VMs; IIS is only a placeholder workload.
5. `deploy-db.ps1` — SQL, private endpoint and DNS.
6. `deploy-private-endpoints.ps1` — Blob and Key Vault resources, private endpoints and DNS.
7. `deploy-bastion.ps1` — management access.
8. `nsg-rules.ps1` — tier access rules.
9. Review routing before running `route-tables.ps1`; see the routing constraint below.

Windows and SQL passwords are requested at runtime. Check extension availability, service quotas, resource-name availability and the selected subscription before starting. Firewall, Bastion, SQL and VMs incur ongoing charges.

## Integration constraints

- The public load balancer only configures port 80. Port 443 in an NSG does not provide TLS.
- The app-tier IIS binding is adjusted to port 8080; it is not a deployed backend API, and the web tier does not yet forward application requests to it.
- `0.0.0.0/0` UDRs control default-route egress, not every VNet or private-endpoint flow. Sending public-load-balancer return traffic through Firewall can create asymmetric routing. Resolve and test the ingress/egress design before associating the web route table.
- NSG default `AllowVNetInBound` rules still matter. ASG allow rules alone do not prove tier isolation. The SQL private endpoint lives outside `db-subnet`, so that subnet's NSG and `asg-db` do not enforce SQL endpoint access.
- The draft Firewall policy permits broad web browsing. It is not an egress allowlist or proof of zero-trust enforcement.

## Validation and cleanup

Record DNS resolution to private addresses, endpoint connection approval, public access being disabled, both load-balancer probes, Bastion access and allowed/denied inter-tier flows. Inspect effective routes and test return traffic before claiming Firewall inspection. Deploy and test an actual web-to-app-to-SQL request before marking integration complete.

Use `three-tier-architecture/scripts/cleanup.ps1` to remove the dedicated group after confirmation. Check deletion has completed. See [repository review](../docs/REVIEW.md) for outstanding items.

[Back to portfolio](../README.md)
