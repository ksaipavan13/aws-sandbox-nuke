provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Lambda function to run at 6 PM IST (12:30 PM UTC)
resource "aws_lambda_function" "scheduled_lambda" {
  function_name = "scheduled_lambda_function"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_code.zip"  # Path to your Lambda zip file

  environment {
    variables = {
      LAMBDA_TASK = "perform_task"
    }
  }
}

# EventBridge rule to trigger Lambda at 6 PM IST (12:30 PM UTC)
resource "aws_cloudwatch_event_rule" "lambda_schedule_rule" {
  name                = "lambda_schedule_rule"
  schedule_expression = "cron(30 12 * * ? *)"  # 12:30 PM UTC (6 PM IST)
}

resource "aws_cloudwatch_event_target" "lambda_schedule_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule_rule.name
  target_id = "scheduled_lambda"
  arn       = aws_lambda_function.scheduled_lambda.arn
}

resource "aws_lambda_permission" "lambda_schedule_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduled_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule_rule.arn
}

