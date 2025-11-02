# 12. Final Verification

### 12.1. Verify DNS with nslookup and dig
```bash
nslookup app0.okondratov.online
```
```text
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
Name:	app0.okondratov.online
Address: 20.31.255.92
```
```bash
dig +short app0.okondratov.online
```
```text
20.31.255.92
```

### 12.2. Verify Network Connectivity with ping and curl
```bash
ping app0.okondratov.online
```
```text 
PING app0.okondratov.online (20.31.255.92): 56 data bytes
36 bytes from 20.31.255.92: Destination Host Unreachable
36 bytes from 20.31.255.92: Destination Host Unreachable
```
```bash
curl -vk https://app0.okondratov.online/get
```
