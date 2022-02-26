# AWS RDS Scheduler

Scheduler to start/stop AWS RDS databases automatically using AWS Lambda functions. 

Every RDS instance with tag `autostart: yes` will be started up automatically from Monday to Friday in the morning.

Every RDS instance with tag `autostop: yes` will be stopped automatically from Monday to Friday in the evening.

## Function

Lambda function has been tested with python 3.9

Log level is controlled by the lambda function environment variable `LOGLEVEL`.


## Infrastructure

Infrastructure is created using terraform code. 

### Schedule

Lambda function is called via AWS EventBridge rules which has a time set to send two types of events to trigger the 
lambda function, the difference between them are the payload sent which can be `{ action = "start" }` or `{ action = "stop" }`. 

You can change the time of these rules in the [event-bridge.tf](terraform/env/eu-west-1/event-bridge.tf) file, 
it's a cron expression and the time is set to UTC.

### Tags

Tags are quite useful to group AWS resources according to your criteria. 
I usually add two tags (`BuiltWith` and `TFCode`) to know that something was created with terraform 
and the git repository where this code lives, 
so it's easier to find it to make any modifications or destroy the infrastructure in the future. 
This become handy when you manage different repositories.

### Create the infrastructure

You need terraform installed, AWS credentials configured and run these commands in `terraform/env/eu-west-1` directory:

```shell
terraform init
terraform plan
terraform apply
```

