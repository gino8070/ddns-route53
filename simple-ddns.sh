#!/bin/bash

readonly RECORD_NAME="fuga.example.com"
readonly TTL=60
readonly HOSTED_ZONE_ID="XXXXXXXXXXXXXX"
readonly PROFILE="aws-profile-name"

my_global_ip=$(curl -s https://diagnostic.opendns.com/myip)

mk_change_batch_file() {
cat << EOS
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$RECORD_NAME",
        "Type": "A",
        "TTL": $TTL,
        "ResourceRecords": [
          {
            "Value": "$my_global_ip"
          }
        ]
      }
    }
  ]
}
EOS
}

temp_file=$(mktemp)
mk_change_batch_file > $temp_file

aws route53 change-resource-record-sets \
--hosted-zone-id $HOSTED_ZONE_ID \
--change-batch file://$temp_file \
--profile $PROFILE

echo "created record"
rm $temp_file
