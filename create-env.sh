#!/bin/bash

#set -x -e



##IMAGE ID = ami-06b94666  

## Values for $1 is for Image Id and $2 for Count"



##HOME WORK WEEK4 ##

echo "Step 1 - Create Key, Key Name = Week4Key"



aws ec2 create-key-pair --key-name Week4Key --query 'KeyMaterial' --output text>Week4Key.pem



echo " Step2 - Create a group-id"

groupid=$(aws ec2 create-security-group --group-name my-group --description "This my-group for Week4 HomeWork")

echo $groupid



echo " Step3 authorize-security-group-ingress"

aws ec2 authorize-security-group-ingress --group-id $groupid --protocol tcp --port 22 --cidr 0.0.0.0/0



echo " Step4 - Launch Instance 

aws ec2 run-instances --image-id $1 --count $2 --instance-type t2.micro --key-name Week4Key  --security-groups my-group --client-token amenatoken --user-data file://installapp.sh



#echo  " Step 5 - Get Instance ID"

#ID=$(aws ec2 describe-instances --filter "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId')



#echo $ID





##  Add a WAIT COMMAND

ID=$(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId')



## WAIT TILL ALL INSTANCES ARE RUNNING

#sleep 100

aws ec2 wait instance-running --instance-ids $ID

echo  " Step 5 - Get Instance ID"

ID1=$(aws ec2 describe-instances --filter "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId')





=======



echo " Creating a Load Balancer,Load Balancer Name is my-load-balancer in Availability Zone = us-west-2b"

IDlb=$(aws elb create-load-balancer --load-balancer-name my-load-balancer --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zone us-west-2b --security-groups $groupid)

## Load Balancer name = my-load-balancer-1339931006.us-west-2.elb.amazonaws.com



IDrunning=$( aws ec2 describe-instances --filter "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId')

echo " The running Instances are ...."

echo $IDrunning

echo " Register instance with Load Balancer"

aws elb register-instances-with-load-balancer --load-balancer-name my-load-balancer --instances $IDrunning



echo "Create aws autoscaling configuration"

#aws autoscaling create-launch-configuration --launch-configuration-name my-config-name --key-name Week4Key --image-id ami-06b94666  --instance-type t2.micro --user-data file://installapp.sh  

aws autoscaling create-launch-configuration --launch-configuration-name my-config-name --key-name Week4Key --image-id $1 --instance-type t2.micro --user-data file://installapp.sh  

echo " Launching the aws autoscaling Group with launch configuration-name, set min, max, and desired capacity and attaching the load-balancer"

aws autoscaling create-auto-scaling-group --auto-scaling-group-name my-scaling-group --launch-configuration-name my-config-name --availability-zone us-west-2b --load-balancer-names my-load-balancer --max-size 5 --min-size 1 --desired-capacity 4

