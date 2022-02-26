# Zip the function source code
data "archive_file" "lambda_my_function" {
  type             = "zip"
  source_file      = "${path.module}/../../../src/lambda_rds_scheduler.py"
  output_file_mode = "0666"
  output_path      = "${path.module}/../../../tmp/lambda_rds_scheduler.zip"
}

resource "aws_lambda_function" "lambda_function_rds_scheduler" {
  description   = local.lambda_description
  filename      = data.archive_file.lambda_my_function.output_path
  function_name = local.lambda_function_name
  role          = aws_iam_role.rds_scheduler_lambda_role.arn
  handler       = local.lambda_handler

  package_type     = "Zip"
  source_code_hash = data.archive_file.lambda_my_function.output_base64sha256
  timeout          = local.lambda_timeout
  memory_size      = local.lambda_memory_size
  publish          = false
  architectures    = ["arm64"]

  runtime = "python3.9"

  environment {
    variables = {
      LOGLEVEL = "debug"
    }
  }
}

resource "aws_lambda_permission" "allow_eventbridge_start" {
  statement_id  = "AllowExecutionFromCloudWatchToStartRDS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_rds_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds_start.arn
}

resource "aws_lambda_permission" "allow_eventbridge_stop" {
  statement_id  = "AllowExecutionFromCloudWatchToStopRDS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_rds_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds_stop.arn
}

resource "aws_cloudwatch_log_group" "lambda_cloudwatch_log_group" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = local.cloud_watch_retention_in_days
}