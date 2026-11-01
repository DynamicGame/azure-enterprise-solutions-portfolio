# Compute architecture

```mermaid
flowchart TB
    Browser[HTTP test client]
    subgraph VNet["vnet-ha-web · 10.0.0.0/16"]
        subgraph Subnet["snet-web · 10.0.1.0/24 · subnet NSG"]
            subgraph Availability["avset-web · 2 fault domains / 5 update domains"]
                VM1[webvm01 · Windows / IIS]
                VM2[webvm02 · Windows / IIS]
            end
        end
    end
    Browser --> PIP1[VM1 public IP] --> VM1
    Browser --> PIP2[VM2 public IP] --> VM2
```

The availability set is placement metadata, not a network hop. Both VMs share a subnet NSG. HTTP is allowed for testing; RDP requires an explicitly supplied administrator IPv4 /32. There is no load balancer or configured HTTPS listener in this implementation.

The [original diagram](High-availability-webserver-architecture.drawio.png) is retained for history. Its single-public-IP path through the availability set is conceptual and should not be read as the deployed traffic flow.

[Deployment guide](../README.md)
