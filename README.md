# AWS RDS Scheduler

Scheduler to start/stop AWS RDS databases automatically using AWS Lambda functions. 

Every RDS instance with tag `autostart: yes` will be started up automatically from Monday to Friday in the morning.

Every RDS instance with tag `autostop. yes` will be stopped automatically from Monday to Friday in the evening.

## Infrastructure

Infrastructure is created using terraform code. 

### Create the infrastructure

You need terraform installed, AWS credentials configured and run these commands in `terraform/env/eu-west-1` directory:

```shell
terraform init
terraform plan
terraform apply
```

## Function

Lambda function has been tested with python 3.9

Log level is controlled by the lambda function environment variable `LOGLEVEL`.
