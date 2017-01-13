#!/bin/sh -x
#
# do some preparations and tests
# in case this failed in the template
#
/bin/ping -c1 cdn.redhat.com || {
    echo "Failed to ping cdn.redhat.com. Your installation will fail!"
    exit 1
}

/bin/ping -c1 registry.access.redhat.com || {
    echo "Failed to ping registry.access.redhat.com. Your installation will fail!"
    exit 1
}

yum repolist enabled | grep -q rhel-7-server-ose-3.3-rpms || {
    echo "Failed to find repo rhel-7-server-ose-3.3-rpms. Trying to enable."
    test -f "/root/redhat-pool.id" &&  {
      poolid=`cat /root/redhat-pool.id`
      subscription-manager attach --pool=$poolid
    }
    subscription-manager repos \
    --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-optional-rpms" \
    --enable="rhel-7-server-ose-3.3-rpms"
    yum clean all
}

yum install -y wget unzip nfs-utils showmount rpcbind
yum install -y git net-tools bind-utils iptables-services bridge-utils bash-completion
yum update -y
yum install -y atomic-openshift-utils 
yum install -y atomic-openshift* openshift* etcd

rpm -q atomic-openshift | grep -v "not installed"| grep -qw atomic-openshift || {
    echo "Failed to install openshift packages. check that the host managed to subscribe to the repo rhel-7-server-ose-3.3-rpms" | tee -a /tmp/v1_installscript.log
    exit 1
}

