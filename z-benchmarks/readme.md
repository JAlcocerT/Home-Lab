Was writing about benchmarking Mini PCs [here](https://jalcocert.github.io/JAlcocerT/benchmarking-computers/).via [this script](https://github.com/JAlcocerT/Linux/blob/main/Z_Linux_Installations_101/Benchmark101.sh).



```sh
sysbench --test=cpu --cpu-max-prime=20000 --num-threads=4 run #4 cores
7z b -mmt4
```

Check CPU cores and test with sysbench:

```sh
#cat /proc/cpuinfo
#uname -a
#nproc
sudo apt install sysbench -y
sysbench --test=cpu --cpu-max-prime=20000 --num-threads=4 run
```

* Benchmark with 7zip:

```sh
sudo apt-get install p7zip-full
7z b -mmt
7z b -mmt4
7z b
```


```sh
git clone https://github.com/JAlcocerT/Py_Trip_Planner/
cd Py_Trip_Planner

sudo bash -c 'time docker pull python:3.8' #let's remove the time of downloading the Python base image from the equation, it was ~1 min!

#docker build -t pytripplanner .
time bash -c 'time docker build --no-cache -t pytripplanner .'
#sudo bash -c 'time podman build -t pytripplanner .'
```

```sh
apt install cargo
#cargo install --git https://github.com/astral-sh/rye rye
time cargo install --git https://github.com/astral-sh/rye rye
```

```sh
ip addr show
hostname -I

#sudo apt-get install net-tools
#ifconfig
#ifconfig eth0 | grep -A 10 "<global>" #check mac, and transfered packages
ifconfig eth0 | grep "inet " | awk '{ print $2 }' #if ETH Connected - SEE THE LOCAL IP
#ifconfig tailscale0 | grep "inet " | awk '{ print $2 }' #for Tailscale

ping -c 4 192.168.0.1 #gateway
ping -c 4 192.168.0.117 #ping the orange pi which is connected to same device
ping 9.9.9.9 #ping quad9 dns server
```

```sh
sudo apt-get install speedtest-cli
speedtest-cli #speedtest-cli --simple
```


```sh
curl -sS https://ipinfo.io/json #the command to use
curl -sS http://ip-api.com/json/ #provides info about country, ISP, ...
curl -6 ifconfig.me #ipv6 info 
```