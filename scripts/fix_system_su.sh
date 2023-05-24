systemctl restart bluetooth 
systemctl start sound-workaround
rmmod hid_multitouch;
modprobe hid_multitouch;
