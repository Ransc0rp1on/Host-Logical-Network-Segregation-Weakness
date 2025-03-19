# Host-Logical-Network-Segregation-Weakness-Exploit
Host Logical Network Segregation Weakness POC \n
**Description**
The remote host is on a different logical network than the Nessus scanner. However, it is on the same physical subnet.
An attacker connecting from the same network as your Nessus scanner could reconfigure his system to force it to belong to the subnet of the remote host.
This may allow an attacker to bypass network filtering between the two subnets.\n
**Solution**
Use VLANs to separate different logical networks.
