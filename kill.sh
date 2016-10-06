#!/bin/bash
#set -x -e

##IMAGE ID = ami-06b94666  
## Values for $1 is for Image Id and $2 for Count"
echo "This script is to destroy resources built with create-env.sh script"

echo " Decrease Desired capacity of Autoscaling group to 1"
aws autoscaling  set-desired-capacity --auto-scaling-group-name my-scaling-group --desired-capacity 1

echo " Detachng Load Balancer from autoscaling group"
aws autoscaling detach-load-balancers --auto-scaling-group-name my-scaling-group --load-balancer-names my-load-balancer

## Update autoscaling group min/max to Zero
echo " Updating autoscaling group desired size and min size to zero"
aws autoscaling update-auto-scaling-group --auto-scaling-group-name my-scaling-group --max-size 5 --min-size 0 --desired-capacity 1
aws autoscaling update-auto-scaling-group --auto-scaling-group-name my-scaling-group --max-size 5 --min-size 0 --desired-capacity 0

echo " getting instances still attached to autoscaling group if any"
# Get instance attached to Auto Scaling Group
IDautoscalinginstances=$(aws autoscaling describe-auto-scaling-instances --query 'AutoScalingInstances[].InstanceId')

echo " Detach instance from Auto scaling group"
aws autoscaling detach-instances --instance-ids $IDautoscalinginstances --auto-scaling-group-name my-scaling-group --should-decrement-desired-capacity

# This step is not needed
#ARNname=$(aws autoscaling  describe-auto-scaling-groups --query 'AutoScalingGroups[].AutoScalingGroupARN')

echo " Update the autoscaling group to detach the launched configuration"
aws autoscaling update-auto-scaling-group --auto-scaling-group-name my-scaling-group

echo " Check if configurations attached to auto-scaling-group "
aws autoscaling describe-auto-scaling-instances --output json

echo " Force delete auto-scaling-group" 
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name my-scaling-group --force-delete

echo " Delete launched configuration"
aws autoscaling delete-launch-configuration --launch-configuration-name my-config-name

echo " Any instances if still attached to Load Balancer"
Instanceattached=$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[].Instances')

echo " Deregister instances attached to Load Balancer"
aws elb deregister-instances-from-load-balancer --load-balancer-name my-load-balancer --instances $Instanceattached 

echo " Delete Load Balancer Listeners"
aws elb delete-load-balancer-listeners --load-balancer-name my-load-balancer  --load-balancer-ports 80

echo " Delete load balancer"
aws elb delete-load-balancer --load-balancer-name  my-load-balancer

echo " Delete the deregistered instances"
aws ec2 terminate-instances --instance-ids $Instanceattached

echo " Display auto-scaling-group has no configurations attached "
aws autoscaling describe-auto-scaling-instances --output json
