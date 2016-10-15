#!/bin/bash



#set -x -e



##IMAGE ID = ami-06b94666  



## Values for $1 is for Image Id and $2 for Count"



##HOME WORK WEEK7 ##

if [ $# -eq 5 ] 

then    echo "Valid Arguments Passed from Command Line"

    else

    echo "Invalid arguments received please pass all 5 arguments in this order AMI-ID, key-name, security-group, launch-configuration, count"

    exit 1



fi



echo " Now continuing with the script"

echo "AMI-ID = $1, key-name =$2, Security-group=$3, launch-configuration=$4, count=$5"



echo "Step 1 - Create Key, Key Name = Week4Key"

aws ec2 create-key-pair --key-name $2 --query 'KeyMaterial' --output text>Week7Key.pem



echo " Step2 - Create a group-id"



groupid=$(aws ec2 create-security-group --group-name $3 --description "This my-group for Week7 HomeWork")



echo $groupid



echo " Step3 authorize-security-group-ingress"



aws ec2 authorize-security-group-ingress --group-id $groupid --protocol tcp --port 22 --cidr 0.0.0.0/0



echo " Step4 - Launch Instance with client-token"



aws ec2 run-instances --image-id $1 --count $5 --instance-type t2.micro --key-name $2  --security-groups $3 --client-token week7-amenatoken --user-data file://installapp.sh

echo " Display Instances created with Token"

aws ec2 describe-instances --filter --query 'Reservations[].Instances[].[InstanceId,ClientToken]'



#echo  " Step 5 - Get Instance ID"

#ID=$(aws ec2 describe-instances --filter "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId')

#echo $ID

sleep 5s

echo " Adding a WAIT COMMAND  and querying for the intances just launched to input for the WAIT command"

sleep 5s

ID=$(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId')

## WAIT TILL ALL INSTANCES ARE RUNNING



sleep 100s

aws ec2 wait instance-running --instance-ids $ID



echo  " Step 5 - Get Instance ID which are in running state"



ID1=$(aws ec2 describe-instances --filter "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId')



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



aws autoscaling create-launch-configuration --launch-configuration-name $4 --key-name $2 --image-id $1 --instance-type t2.micro --user-data file://installapp.sh  



echo " Launching the aws autoscaling Group with launch configuration-name, set min, max, and desired capacity and attaching the load-balancer"



aws autoscaling create-auto-scaling-group --auto-scaling-group-name my-scaling-group --launch-configuration-name $4 --availability-zone us-west-2b --load-balancer-names my-load-balancer --max-size 5 --min-size 1 --desired-capacity 4

echo " Display the Auto scaling group with instance and launching configuration attached on Screen"

aws autoscaling describe-auto-scaling-instances --output json
