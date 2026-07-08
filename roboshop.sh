#!/bin/bash

SG_ID="sg-08e4c0a9a0fac1033"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID=
DOMAIN_NAME= "caws1.in"

for instance in $@
do 
    INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

    if [ $instance == "frontend" ]; then
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
        )
        RECORD_NAME="$DOMAIN_NAME"
    else
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID  \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
        )
        RECORD_NAME="$intance.$DOMAIN_NAME"
    fi

    echo " IP Address : $IP "
    
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID 
    --change-batch '
     {
        "Comment" : " Update A record ",
        "Changes" : 
        [
            {
            "Action" : "UPSERT",
            "ResourceRecordSet" : {
                "Name" : "'$RECORD_NAME'",
                "Type" : "A",
                "TTL" : 300,
                "ResourceRecords" : [
                    {
                        "Value" : " '$IP' "
                    }
                    ]
                }
           }
        ]
    }

    echo "record update for '$instance' "  

done



