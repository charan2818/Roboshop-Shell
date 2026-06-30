#!/bin/bash

SG_ID="sg-08e4c0a9a0fac1033"
AMI_ID="ami-0220d79f3f480ecf5"


for instance in $@
do 
    INSTANCE_ID=$( aws ec2 run-instance \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instaances[0].InstanceId' \
    --output text)

    if [ $instance == "frontend"]; then
        IP=$(
            aws ec2 describe-instances\
            --Instance-ids $INSTANCE_ID\
            --query 'Reservations[].Instances[].PublicIpAddress'\
            --output text
        )
    else
        IP=$(
            aws ec2 describe-instances\
            --Instance-ids $INSTANCE_ID\
            --query 'Reservations[].Instances[].PrivateIpAddress'\
            --output text
        )
    fi
done



