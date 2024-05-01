sudo dnf upgrade
sudo yum install iproute libibverbs libibverbs-utils infiniband-diags librdmacm-utils -y
sudo dnf install python3-pip nano iperf3 perl git -y
sudo yum install python36 tk tcl lsof pciutils pkgconf-pkg-config -y

tar -xvzf MLNX_OFED_LINUX-5.8-4.1.5.0-rhel8.9-x86_64.tgz

cd MLNX_OFED_LINUX-5.8-4.1.5.0-rhel8.9-x86_64

# Only for SmartNIC machines
sudo ./mlnxofedinstall
sudo /etc/init.d/openibd restart
# Configure RoCE interface on server
sudo ip addr add 192.168.1.1/24 dev eth1

# Setup Soft-RoCE interface on clients without SmartNIC
sudo rdma link add rxe0 type rxe netdev eth1

# Install perftest on client and server
git clone https://github.com/linux-rdma/perftest.git
sudo pip3 install pyelftools meson
sudo dnf install --enabler=powertools ninja-build libpcap-devel lua-devel -y
sudo yum install gcc gcc-c++ kernel-devel make cmake -y
cd perftest/
./autogen.sh
./configure
make 
make install

sudo reboot
# Start perftest server on router
./raw_ethernet_send_bw --duration=30

# Connect client to server
./raw_ethernet_send_bw --duration=30 192.168.1.1

