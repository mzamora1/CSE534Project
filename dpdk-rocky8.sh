sudo dnf upgrade
sudo dnf install python3-pip nano iperf3 perl git -y
sudo yum install python36 tk tcl lsof pciutils pkgconf-pkg-config -y

tar -xvzf MLNX_OFED_LINUX-5.8-4.1.5.0-rhel8.9-x86_64.tgz

cd MLNX_OFED_LINUX-5.8-4.1.5.0-rhel8.9-x86_64

sudo ./mlnxofedinstall --dpdk
sudo /etc/init.d/openibd restart
sudo ip addr add 192.168.1.1/24 dev eth1


# Install/Compile DPDK
curl -o dpdk-23.07.zip -L https://github.com/DPDK/dpdk/archive/refs/tags/v23.07.zip

export RTE_SDK=/home/rocky/dpdk-23.07
export RTE_TARGET=x86_64-native-linux-gcc

echo vm.nr_hugepages=256 | sudo tee -a /etc/sysctl.conf

unzip dpdk-23.07.zip
cd dpdk-23.07
sudo pip3 install pyelftools meson
sudo dnf install --enabler=powertools ninja-build libpcap-devel lua-devel -y
sudo yum install gcc gcc-c++ kernel-devel make cmake -y
sudo ln -s /usr/local/lib64/libnuma.so.1 /usr/lib/libnuma.so
meson setup -Dmax_numa_nodes=1 build
cd build
ninja

sudo /usr/local/bin/meson install
sudo nano /etc/ld.so.conf # ADD /usr/local/lib64 \n /usr/lib64
sudo ldconfig

export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig

cd ..
# Install/Compile pktgen
git clone http://dpdk.org/git/apps/pktgen-dpdk
cd pktgen-dpdk
make

echo 2048 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
sudo reboot

nano cfg/default.cfg
./tools/run.py -s default
./tools/run.py default