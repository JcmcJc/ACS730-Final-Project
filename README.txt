###Deployment pre-requisites:
Create two S3 buckets with unique names. The buckets will store Terraform state. The names of the buckets should start with the {env}-<unique bucket name>.
Ensure that networkmodule is in the same folder as prod, dev, and staging.
##Deployment Process
1. Upload the code to AWS Cloud9 environment or Start with the existing code or start from the scratch
2. Update the config.tf in dev and prod subfolders to reflect the bucket names
3. Update the bucket names in the dev webserver main.tf, the prod webserver main.tf, networkmodule main.tf, and prodnetworkmodule main.tf to get the data from the respective envrionment networks.
4. Update the desired input varibles in dev and deploy dev network with the commands below
```
   cd ~/Finalproject/dev/network 
   tf init
   tf plan
   tf apply 
```
5. Deploy the webservers of the dev environment
```
   cd ~/Finalproject/dev/network 
   tf init
   tf plan
   tf apply 
```
6. Update the desired input varibles in prod and deploy prod network with the commands below
```
   cd ~/summer/Lab4/aws_network/prod/webservers
   tf init
   tf plan
   tf apply
 ```
7. Deploy the webservers of the prod environment (MUST Deploy this last for VPC peering to work correctly)
```
   cd ~/summer/Lab4/aws_network/dev/webservers 
   tf init
   tf plan
   tf apply 
```
8. Manually change the public subnet route table to allow VPC peering with CIDR 10.1.0.0/16 on AWS

###Clean Up process 

The cleaniup process is a reverse of the deployment process,

1. Delete  instances in prod webserver
``` 
 cd ../../prod/webservers/
 tf destroy  -auto-approve
 ```
2. Delete  instances in prod network
``` 
 cd ../../prod/network/
 tf destroy  -auto-approve
 ```
3. Delete  instances in dev webserver
``` 
 cd ../../dev/webservers/
 tf destroy  -auto-approve
 ```
4. Delete  instances in dev network
``` 
 cd ../../dev/network/
 tf destroy  -auto-approve
 ```
