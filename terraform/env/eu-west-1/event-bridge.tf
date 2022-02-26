resource "aws_cloudwatch_event_rule" "rds_start" {
  name                = "rds-scheduler-start"
  description         = "CRON to start RDS DB Instances in working days"
  schedule_expression = "cron(30 5 ? * MON-FRI *)"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "lambda_rds_scheduler_start" {
  rule      = aws_cloudwatch_event_rule.rds_start.name
  target_id = "SendToLambdaToStartRDS"
  arn       = aws_lambda_function.lambda_function_rds_scheduler.arn
  input     = jsonencode({ action = "start" })
  retry_policy { maximum_event_age_in_seconds = 3600 }
}

resource "aws_cloudwatch_event_rule" "rds_stop" {
  name                = "rds-scheduler-stop"
  description         = "CRON to stop RDS DB Instances nightly"
  schedule_expression = "cron(30 18 * * ? *)"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "lambda_rds_scheduler_stop" {
  rule      = aws_cloudwatch_event_rule.rds_stop.name
  target_id = "SendToLambdaToStopRDS"
  arn       = aws_lambda_function.lambda_function_rds_scheduler.arn
  input     = jsonencode({ action = "stop" })
  retry_policy { maximum_event_age_in_seconds = 10800 }
}
