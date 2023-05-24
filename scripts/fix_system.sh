sudo systemctl restart bluetooth 
sudo systemctl start sound-workaround
sudo rmmod hid_multitouch;
sudo modprobe hid_multitouch;
