CentOS 6
========

```
yum erase yum-autoupdate yum-conf-sl-other dhclient selinux-*
yum update
yum install screen bind-utils man traceroute telnet rsync openssh-clients vim ntp bc jwhois wget perl epel-release rpmforge-release htop
```

Edit `/etc/yum.repos.d/rpmforge.repo`, enable the -extras repo and add:

```
includepkgs = git-* *-git git

yum install git
```

VMs: yum install gcc make kernel-devel, install vmware tools, remove dvd drive & resize ram 
Physical: yum install sl_enable_serialconsole-96

Packages of interest: nfs-utils bind samba

Cloning
-------

Review/rename files:

```
/etc/resolv.conf
/etc/sysconfig/network
/etc/sysconfig/network-scripts/ifcfg-eth0
/etc/sysconfig/network-scripts/ifcfg-eth0.0
/etc/sudoers
/etc/ssh/ssh_host_[dsa|rsa]_key
/etc/ssh/sshd_config
```

Windows 7
=========
Need Ultimate for Aero Glass remoting!

  * VMware Tools
  * Remote Desktop
  * Activation
  * Updates
  * Disable sleep
  * Hibernation, swapfile
  * Add Domain admins to Administrators group

VirtualBox
==========

```
vboxmanage createvm --name "$NAME" --ostype Windows2008_64 --register --basefolder /data/vbox
vboxmanage createhd --filename $NAME/$NAME.vdi --size 256500
vboxmanage storagectl $NAME --name "SATA" --add sata --controller IntelAhci
vboxmanage storageattach $NAME --storagectl SATA --port 0 --device 0 --medium $NAME/$NAME.vdi --type hdd
vboxmanage storageattach $NAME --storagectl SATA --port 1 --device 0 --medium "/data/software/OSes/Windows Server 2008 R2 SP1 x64.iso" --type dvddrive
vboxmanage modifyvm $NAME --vrde on --vrdeport 3391 --vrdeaddress 127.0.0.1
vboxmanage modifyvm $NAME --hostonlyadapter1 vboxnet0 --nic1 hostonly
vboxmanage startvm $NAME --type headless
```
