locals {
  app        = "rds-scheduler"
  aws_region = "eu-west-1"
  stack      = "rds-scheduler"

  lambda_function_name = "rds-scheduler"
  lambda_description   = "RDS Scheduler to start/stop RDS databases based on tags."
  lambda_handler       = "lambda_rds_scheduler.lambda_handler"
  lambda_timeout       = 3
  lambda_memory_size   = 128

  cloud_watch_retention_in_days = 3
}
