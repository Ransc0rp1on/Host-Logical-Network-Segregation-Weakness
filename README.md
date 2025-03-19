# Host Logical Network Segregation Weakness - Proof of Concept (PoC)

![Network Segmentation Warning](https://img.shields.io/badge/Risk-Low-yellow) 
![Vulnerability Type](https://img.shields.io/badge/Type-Network%20Architecture-red)

A demonstration of network segmentation bypass through layer 2 adjacency despite logical subnet separation.

## 📖 Description

This repository demonstrates a network architecture vulnerability where:
- Two or more devices **reside on different IP subnets** (logical separation)
- But share the **same physical broadcast domain** (layer 2 adjacency)
- Allowing potential bypass of network access controls

![Vulnerability Diagram](https://i.imgur.com/3GzXf7l.png)

## 🔍 Vulnerability Details

**Technical Context**  
Traditional network security often relies on IP-based filtering (layer 3) while neglecting physical layer controls. When devices in separate subnets share the same broadcast domain:

1. **ARP Protocol Exposure**: Devices can discover each other via layer 2 ARP requests
2. **MAC Address Communication**: Direct communication possible using MAC addresses
3. **VLAN Hopping Risk**: Potential gateway spoofing between subnets

**Impact**  
- Bypass firewall rules between subnets
- Potential lateral movement paths
- Violates PCI DSS Requirement 1.2.1 ("Implement subnet separation")

## 🧪 Proof of Concept

### Prerequisites
- Kali Linux or similar distro
- Root privileges
- Nmap + tcpdump installed
- Network access to target subnet

### Manual Verification Steps

1. **ARP Discovery**  
```bash
sudo arp-scan -I eth0 172.21.4.0/24
