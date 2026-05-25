

    Internet([Public Internet])
    PublicIP[Public IP Address]
    NSG[Network Security Group<br/>Allow: 80/443<br/>Restricted: RDP/SSH]

    subgraph AVSET[Availability Set<br/>FD1/FD2 • UD1–UD5]
        VM1[webvm01<br/>Windows/Linux VM]
        VM2[webvm02<br/>Windows/Linux VM]
    end

    NIC1[NIC + Private IP]
    NIC2[NIC + Private IP]

    VNET[VNet: 10.0.0.0/16<br/>Subnet: 10.0.1.0/24]

    Internet --> PublicIP --> NSG --> AVSET
    VM1 --> NIC1 --> VNET
    VM2 --> NIC2 --> VNET
