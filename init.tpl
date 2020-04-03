#!/bin/bash -xe
yum update -y
yum install -y git httpd
chkconfig --levels 235 httpd on
echo "# Nothing in here" > /etc/httpd/conf.d/welcome.conf
git clone https://github.com/josdindaniel/demo-app-aws-elb-classic.git
cd demo-app-aws-elb-classic/
INSTANCEID=$(curl http://169.254.169.254/2016-06-30/meta-data/instance-id)
HOSTURL=$(curl http://169.254.169.254/2016-06-30/meta-data/public-hostname)
IPV4=$(curl http://169.254.169.254/2016-06-30/meta-data/public-ipv4)
MACID=$(curl http://169.254.169.254/2016-06-30/meta-data/mac)
AZID=$(curl http://169.254.169.254/2016-06-30/meta-data/placement/availability-zone)
TYPEID=$(curl http://169.254.169.254/2016-06-30/meta-data/instance-type)
VPCID=$(curl http://169.254.169.254/2016-06-30/meta-data/network/interfaces/macs/$MACID/vpc-id)
SUBNETID=$(curl http://169.254.169.254/2016-06-30/meta-data/network/interfaces/macs/$MACID/subnet-id)
sed -i "s/instanceID/$INSTANCEID/g" assets/index.html
sed -i "s/publicHostname/$HOSTURL/g" assets/index.html
sed -i "s/publicIP/$IPV4/g" assets/index.html
sed -i "s/macID/$MACID/g" assets/index.html
sed -i "s/zoneID/$AZID/g" assets/index.html
sed -i "s/instanceTYPE/$TYPEID/g" assets/index.html
sed -i "s/vcpID/$VPCID/g" assets/index.html
sed -i "s/subnetID/$SUBNETID/g" assets/index.html
cp -f assets/index.html /var/www/html/index.html
service httpd restart
