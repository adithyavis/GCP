#!/bin/bash
echo "Creating instance"
gcloud sql instances create adithyasqlinstance --tier=db-f1-micro --region=us-central1
echo "Creating Database"
gcloud sql databases create adithyaempmgmt --instance=adithyasqlinstance
echo "Creating user"
gcloud sql users create adithyaappuser --instance=adithyasqlinstance
echo "getting IP"
ip=`gcloud sql instances describe adithyasqlinstance --format="value(ipAddresses.ipAddress)"`
gcloud sql connect adithyasqlinstance --user=root << EOF
USE adithyaempmgmt;
CREATE TABLE test (name VARCHAR(10), lastname VARCHAR(10));
INSERT INTO test VALUES ('adithya', 'viswamithiran');
INSERT INTO test VALUES ('adi', 'v');
INSERT INTO test VALUES ('aditya', 'viswa');
SELECT * FROM test;
UPDATE test SET lastname ='v' WHERE name='adi';
SELECT * FROM test;
DELETE FROM test WHERE name='aditya';
SELECT * FROM test;
GRANT SELECT, INSERT on adithyaempmgmt.test to adithyaappuser;
SHOW GRANTS for adithyaappuser;
REVOKE SELECT, INSERT on adithyaempmgmt.test from adithyaappuser;
SHOW GRANTS for adithyaappuser;
EOF