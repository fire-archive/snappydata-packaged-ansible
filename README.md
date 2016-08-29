# What is SnappyData?

https://github.com/SnappyDataInc/snappydata

SnappyData is a **distributed in-memory data store for real-time operational analytics, delivering stream analytics, OLTP (online transaction processing) and OLAP (online analytical processing) in a single integrated cluster**. We realize this platform through a seamless integration of Apache Spark (as a big data computational engine) with GemFire XD (as an in-memory transactional store with scale-out SQL semantics).

## How to install

This was tested on Ubuntu 16.04. We are using libvirt because of performance differences on virtualbox.

Install:

* __Install Vagrant 1.8.4+__ https://www.vagrantup.com/downloads.html
* `sudo apt-get install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils`
* `sudo apt-get install virt-manager`
* `vagrant plugin install vagrant-libvirt`
* `vagrant up --provider=libvirt`
* Password: vagrant
* Can also put `export VAGRANT_DEFAULT_PROVIDER=libvirt` in profile.
* `vagrant provision`

Point your sql client to `snappydata.192.168.55.4.nip.io`.

## How to install via ansible


* `sudo add-apt-repository ppa:ansible/ansible`
* `sudo apt-get update`
* `sudo apt install ansible`
* Go to the location of the `playbook.yml`;
* `ansible-playbook playbook.yml -i x.x.x.x, -u centos -b --become-user root`

## Notes

The YCSB SnappyStore driver hard codes the hostname. Patches are accepted to fix this.

```
vagrant ssh
# Password: vagrant
sudo su - snappydata-ycsb
cd ~/src
./bin/ycsb load snappystore -P workloads/workloada -s -threads 8 -p recordcount=1000000
./bin/ycsb run snappystore -P workloads/workloada -s -threads 8 -p operationcount=1000000 -p requestdistribution=zipfian
```
