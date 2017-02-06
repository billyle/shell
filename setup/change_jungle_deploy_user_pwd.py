#!/usr/bin/python
import random
import string
import socket
import fcntl
import struct
import os

#ip = socket.gethostbyname(socket.gethostname())
#print (ip)
def Psswd(length):
    chars=string.ascii_letters+string.digits
    return ''.join([random.choice(chars) for i in range(length)])
def get_ip_address(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])
passwd = Psswd(20)
username = 'jungle_deployer'
os.system('echo %s | /usr/bin/passwd --stdin %s' %(passwd,username))
ip = get_ip_address('eth0')
shortname = ip.split('.')[-1]
print
print
print '    change password success!!!'
print ''
show = r'    t%s:%s:%s:%s' %(shortname,ip,username,passwd) 
print show
print
print
