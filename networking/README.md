# Networking Fundamentals

Student: **Abhinav**

This module documents practical networking troubleshooting, connectivity checks, DNS resolution diagnostics, and port testing. Command execution outputs were captured live on the host system.

## 1. Network Commands Reference & Understanding

| Command | What I understood |
| --- | --- |
| `ping -c 2 google.com` | Tests IP reachability and round-trip delay using ICMP Echo Request/Reply packets. |
| `traceroute -m 3 google.com` | Traces the network path/routing hops to a remote host by incrementing IP packet TTL values. |
| `netstat -an` | Displays active TCP/UDP socket connections, listening ports, and socket states (`ss -tuln` on Linux). |
| `nc -zv google.com 80` | Tests if a specific TCP port is open and accepting socket connections without sending full application data. |
| `tcpdump -i any -c 5` | Intercepts and captures live network interface packets for low-level protocol analysis. |
| `nslookup google.com` | Queries domain name servers interactively to resolve IP addresses from domain hostnames. |
| `dig google.com` | Performs detailed DNS lookups displaying answer sections, query execution time, and TTL records. |
| `curl -I https://www.google.com` | Sends an HTTP HEAD request to verify web server responsiveness, TLS handshake, and response headers. |
| `arp -a` | Displays the local Address Resolution Protocol cache mapping IPv4 addresses to physical MAC addresses. |
| `systemctl status NetworkManager` | Checks the status of the network management daemon on systemd-based Linux systems. |

## 2. Real Captured Execution Output

```bash
ping -c 2 google.com
nc -zv google.com 80
nslookup google.com
curl -I https://www.google.com
traceroute -m 3 google.com
netstat -an | head -n 5
dig google.com +short
```

```
PING google.com (172.217.161.142): 56 data bytes
64 bytes from 172.217.161.142: icmp_seq=0 ttl=117 time=30.525 ms
64 bytes from 172.217.161.142: icmp_seq=1 ttl=117 time=31.817 ms

--- google.com ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 30.525/31.171/31.817/0.646 ms

Connection to google.com port 80 [tcp/http] succeeded!

Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
Name:	google.com
Address: 172.217.161.142

HTTP/2 200 
content-type: text/html; charset=ISO-8859-1
date: Fri, 04 Sep 2026 18:33:44 GMT
server: gws

traceroute to google.com (172.217.161.142), 3 hops max, 40 byte packets
 1  wifi.height8tech.com (100.129.160.1)  9.373 ms  8.150 ms  5.945 ms
 2  202.131.133.5.convergentindia.com (202.131.133.5)  6.937 ms  32.946 ms  8.992 ms
 3  115.117.125.189.static-mumbai.vsnl.net.in (115.117.125.189)  127.878 ms  9.641 ms  10.426 ms

Active Internet connections (including servers)
Proto Recv-Q Send-Q  Local Address          Foreign Address        (state)    
tcp4       0      0  127.0.0.1.50625        127.0.0.1.51308        ESTABLISHED

172.217.161.142
```

## 3. Systematic Troubleshooting Order

When diagnosing network connectivity issues in production environments, I follow a strict bottom-up OSI layer-by-layer approach:

1. **Local Interface & IP Configuration:** Check IP assignment and interface status using `ifconfig` or `ip address`.
2. **Gateway Reachability:** Test local network routing and gateway connectivity using `ping <gateway-ip>` and `ip route`.
3. **DNS Resolution:** Verify hostname resolution using `nslookup` or `dig`.
4. **Port Availability:** Verify application listener status and firewall rules using `nc -zv host port` or `telnet`.
5. **Application Health:** Fetch HTTP response headers using `curl -I`.
6. **Packet Capture Analysis:** If deeper protocol issues persist, capture raw packet flows using `tcpdump`.

*In an interview I'd say:* Always start network troubleshooting at the lower layers by verifying IP assignment and local gateway routing before blaming upper-layer application services or DNS resolvers.
