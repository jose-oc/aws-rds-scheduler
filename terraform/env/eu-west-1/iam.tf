# IAM Role to be assumed by the Lambda function.
resource "aws_iam_role" "rds_scheduler_lambda_role" {
  name        = "${local.lambda_function_name}-role"
  path        = "/rds-scheduler/"
  description = "Role to be assumed by the lambda function to start or stop RDS database instances"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "lambda_logging"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["logs:CreateLogGroup"]
          Effect   = "Allow"
          Resource = "arn:aws:logs:${local.aws_region}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
          Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
          Effect   = "Allow"
          Resource = "arn:aws:logs:${local.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_function_name}:*"
        },
      ]
    })
  }

  inline_policy {
    name = "rds_start_stop_describe"

    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "rds:DescribeDBClusterParameters",
            "rds:StartDBCluster",
            "rds:StopDBCluster",
            "rds:DescribeDBEngineVersions",
            "rds:DescribeGlobalClusters",
            "rds:DescribePendingMaintenanceActions",
            "rds:DescribeDBLogFiles",
            "rds:StopDBInstance",
            "rds:StartDBInstance",
            "rds:DescribeReservedDBInstancesOfferings",
            "rds:DescribeReservedDBInstances",
            "rds:ListTagsForResource",
            "rds:DescribeValidDBInstanceModifications",
            "rds:DescribeDBInstances",
            "rds:DescribeSourceRegions",
            "rds:DescribeDBClusterEndpoints",
            "rds:DescribeDBClusters",
            "rds:DescribeDBClusterParameterGroups",
            "rds:DescribeOptionGroups"
          ],
          Resource = [
            "arn:aws:rds:*:${data.aws_caller_identity.current.account_id}:cluster:*",
            "arn:aws:rds:*:${data.aws_caller_identity.current.account_id}:cluster-endpoint:*",
            "arn:aws:rds:*:${data.aws_caller_identity.current.account_id}:cluster-pg:*",
            "arn:aws:rds:*:${data.aws_caller_identity.current.account_id}:db:*",
            "arn:aws:rds:*:${data.aws_caller_identity.current.account_id}:cev:*/*/*",
            "arn:aws:rds::${data.aws_caller_identity.current.account_id}:global-cluster:*"
          ]
        },
        {
          Effect = "Allow",
          Action = [
            "rds:DescribeDBEngineVersions",
            "rds:DescribeSourceRegions",
            "rds:DescribeReservedDBInstancesOfferings"
          ],
          Resource = "*"
        }
      ]
    })
  }
}
