# Availability-set web servers

**Azure VMs · Windows Server · IIS · Azure CLI / PowerShell**

## Purpose and status

Explore the infrastructure needed to move a web workload away from one server. The lab defines two Windows VMs in an availability set, an NSG and an IIS installation step.

Deployment screenshots from an earlier run are available in [screenshots](screenshots/). Scripts were corrected during the repository review and need a fresh Azure deployment test. A shared application endpoint, health-based traffic distribution and measured failover are still future work.

## Architecture

See the [editable architecture and design notes](architecture/README.md). Availability sets spread VMs across fault/update domains; they do not route requests or replicate application state. The current lab exposes each VM separately for HTTP testing.

## Scripts

| Order | Script | Purpose |
| --- | --- | --- |
| 1 | [deploy.ps1](scripts/deploy.ps1) | Resource group, VNet, subnet NSG, availability set and two Windows VMs |
| 2 | [install-iis.ps1](scripts/install-iis.ps1) | Install IIS on both VMs |
| Optional | [nsg-rules.ps1](scripts/nsg-rules.ps1) | Reapply HTTP rules and optionally allow RDP from one administrator IPv4 address |
| Teardown | [cleanup.ps1](scripts/cleanup.ps1) | Delete the dedicated lab resource group after confirmation |

## Run the lab

From this project directory, after `az login` and checking `az account show`:

```powershell
./scripts/deploy.ps1
./scripts/install-iis.ps1
# Optional administrative access; replace the example with your own public IPv4 /32.
./scripts/nsg-rules.ps1 -AdminCidr '203.0.113.10/32'
```

The deployment requests a Windows administrator password securely at runtime. RDP is not opened by default. HTTP is a lab test endpoint; opening a port does not configure TLS or an HTTPS certificate.

## Validation

Check both VMs are running and belong to `avset-web`. Inspect the effective NSG rules, request each VM's HTTP endpoint and verify that RDP is blocked unless the optional administrator rule is applied. Capture redacted evidence and the CLI version. A future load-balancer milestone should test health probes and access during one VM's outage.

## Cleanup and next steps

Run `./scripts/cleanup.ps1` only for this lab's resource group. Deletion is asynchronous; confirm it finishes. Add a load balancer, a repeatable application deployment, TLS, monitoring and a recorded failure test before describing the application as highly available.

[Back to portfolio](../../README.md)
