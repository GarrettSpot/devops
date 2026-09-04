```
~ ❯ ping google.com
PING google.com (142.251.220.110) 56(84) bytes of data.
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=1 ttl=116 time=10.1 ms
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=2 ttl=116 time=15.8 ms
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=3 ttl=116 time=9.60 ms
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=4 ttl=116 time=12.9 ms
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=5 ttl=116 time=111 ms
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=6 ttl=116 time=9.91 ms
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=7 ttl=116 time=31.2 ms
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=8 ttl=116 time=13.2 ms
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=9 ttl=116 time=22.8 ms
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=10 ttl=116 time=12.0 ms
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=11 ttl=116 time=18.3 ms
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=12 ttl=116 time=12.6 ms
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=13 ttl=116 time=10.0 ms
64 bytes from pnmaaa-be-in-f14.1e100.net (142.251.220.110): icmp_seq=14 ttl=116 time=9.90 ms
^C
--- google.com ping statistics ---
14 packets transmitted, 14 received, 0% packet loss, time 13016ms
rtt min/avg/max/mdev = 9.597/21.365/110.864/25.507 ms

~ ✗ traceroute google.com
traceroute to google.com (142.251.220.110), 30 hops max, 60 byte packets
 1  _gateway (100.129.160.1)  37.902 ms  37.843 ms  37.833 ms
 2  202.131.133.5.convergentindia.com (202.131.133.5)  37.757 ms  37.748 ms  38.983 ms
 3  115.117.125.189.static-mumbai.vsnl.net.in (115.117.125.189)  39.947 ms  39.937 ms  39.928 ms
 4  172.28.117.90 (172.28.117.90)  42.400 ms  41.126 ms  42.519 ms
 5  115.112.15.114.static-chennai.vsnl.net.in (115.112.15.114)  44.794 ms  44.787 ms  50.158 ms
 6  * * *
 7  142.251.55.90 (142.251.55.90)  38.498 ms 142.251.55.28 (142.251.55.28)  45.510 ms 74.125.252.214 (74.125.252.214)  45.489 ms
 8  142.251.51.118 (142.251.51.118)  34.184 ms 142.250.239.228 (142.250.239.228)  31.913 ms 142.251.55.221 (142.251.55.221)  32.023 ms
 9  pnmaaa-be-in-f14.1e100.net (142.251.220.110)  35.385 ms  36.796 ms 142.251.229.251 (142.251.229.251)  42.889 ms

~ ❯ netstat -tuln
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 172.17.0.1:53           0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.1:631           0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.54:53           0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN     
tcp6       0      0 ::1:631                 :::*                    LISTEN     
udp        0      0 224.0.0.251:5353        0.0.0.0:*                          
udp        0      0 224.0.0.251:5353        0.0.0.0:*                          
udp        0      0 224.0.0.251:5353        0.0.0.0:*                          
udp        0      0 224.0.0.251:5353        0.0.0.0:*                          
udp        0      0 0.0.0.0:5353            0.0.0.0:*                          
udp        0      0 172.17.0.1:53           0.0.0.0:*                          
udp        0      0 127.0.0.54:53           0.0.0.0:*                          
udp        0      0 127.0.0.53:53           0.0.0.0:*                          
udp6       0      0 :::5353                 :::*                               

~ ❯ telnet google.com 80
Trying 142.251.220.110...
Connected to google.com.
Escape character is '^]'.

^C
Connection closed by foreign host.

~ ✗ sudo tcpdump -i wlp0s20f3 host google.com
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on wlp0s20f3, link-type EN10MB (Ethernet), snapshot length 262144 bytes
^C
0 packets captured
0 packets received by filter
0 packets dropped by kernel

~ ❯ nslookup google.com
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
Name:	google.com
Address: 142.251.220.110
Name:	google.com
Address: 2404:6800:4007:82f::200e

~ ❯ dig google.com

; <<>> DiG 9.20.27 <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 48404
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		83	IN	A	142.251.220.110

;; Query time: 44 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Fri Sep 04 23:03:53 IST 2026
;; MSG SIZE  rcvd: 55

~ ✗ curl -I https://www.google.com
HTTP/2 200 
content-type: text/html; charset=ISO-8859-1
content-security-policy-report-only: object-src 'none';base-uri 'self';script-src 'nonce-GjXqQI-ArU49ngOLstToWA' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
accept-ch: Sec-CH-Prefers-Color-Scheme
p3p: CP="This is not a P3P policy! See g.co/p3phelp for more info."
date: Fri, 04 Sep 2026 17:34:23 GMT
server: gws
x-xss-protection: 0
x-frame-options: SAMEORIGIN
expires: Fri, 04 Sep 2026 17:34:23 GMT
cache-control: private
set-cookie: __Secure-STRP=ANmZwa13VzE25LpSRqwdU0N89zzpP3bK6oSLm-191HgrbcjwPadVtyGZKxv33lhFK_lDFCh2Nh5sKQlCpSfW2QOIuhBMNhDlpQZ0; expires=Fri, 04-Sep-2026 17:39:23 GMT; path=/; domain=.google.com; Secure; SameSite=strict
set-cookie: AEC=AdJVEavamPViS5YZy7urmHqkTA3GwALDOFyKyhSHE-RJK2aQ-p-kVqqJRwA; expires=Wed, 03-Mar-2027 17:34:23 GMT; path=/; domain=.google.com; Secure; HttpOnly; SameSite=lax
set-cookie: NID=534=SHG1nP7sB9ofdvXYik8Ee4jnPMLowuz8dM36-5aAYrvCH4cQ48eWFOQ_GzrF77dZ9shmi7V2Y_BHXMj5lMhfVtoDxeGF_ydSyxtQM8dAeeWADfg1jlTsGFsEoptlIS5vQdCi5Uk2N0ONkqnSK1hSZ_WMMAVavBCOgImYo3MkJivU7zwfHZANJ_myyBll79k5dRB3CxluUqRa24x42KA; expires=Sat, 06-Mar-2027 17:34:23 GMT; path=/; domain=.google.com; HttpOnly
alt-svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000

~ ❯ arp -a
_gateway (100.129.160.1) at f4:1e:57:3d:a6:d6 [ether] on wlp0s20f3
? (100.129.160.121) at 90:4c:02:ca:f7:3d [ether] on wlp0s20f3

~ ❯ systemctl status NetworkManager
● NetworkManager.service - Network Manager
     Loaded: loaded (/usr/lib/systemd/system/NetworkManager.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-09-04 19:08:09 IST; 3h 57min ago
 Invocation: b37b5f8427364cf5ac489df9764882d5
       Docs: man:NetworkManager(8)
   Main PID: 880 (NetworkManager)
      Tasks: 4 (limit: 18620)
     Memory: 24.9M (peak: 26.8M)
        CPU: 5.796s
     CGroup: /system.slice/NetworkManager.service
             └─880 /usr/bin/NetworkManager --no-daemon

Sep 04 22:10:57 omarchy NetworkManager[880]: <info>  [1788540057.6307] dhcp4 (wlp0s20f3): canceled DH>
Sep 04 22:10:57 omarchy NetworkManager[880]: <info>  [1788540057.6307] dhcp4 (wlp0s20f3): state chang>
Sep 04 22:10:57 omarchy NetworkManager[880]: <info>  [1788540057.6308] dhcp4 (wlp0s20f3): activation:>
Sep 04 22:10:57 omarchy NetworkManager[880]: <info>  [1788540057.6309] device (p2p-dev-wlp0s20f3): su>
Sep 04 22:10:57 omarchy NetworkManager[880]: <info>  [1788540057.6309] device (wlp0s20f3): ip:dhcp4: >
Sep 04 22:10:57 omarchy NetworkManager[880]: <info>  [1788540057.6309] dhcp4 (wlp0s20f3): canceled DH>
Sep 04 22:10:57 omarchy NetworkManager[880]: <info>  [1788540057.6309] dhcp4 (wlp0s20f3): state chang>
Sep 04 22:10:57 omarchy NetworkManager[880]: <info>  [1788540057.6309] dhcp4 (wlp0s20f3): activation:>
Sep 04 22:10:57 omarchy NetworkManager[880]: <info>  [1788540057.7696] dhcp4 (wlp0s20f3): state chang>
Sep 04 22:10:57 omarchy NetworkManager[880]: <info>  [1788540057.7699] dhcp4 (wlp0s20f3): state chang>
```
