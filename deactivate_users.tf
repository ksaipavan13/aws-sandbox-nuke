# Lambda function to deactivate AWS users
resource "aws_lambda_function" "deactivate_users_lambda" {
  function_name = "deactivate_users"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  filename      = "deactivate_lambda/lambda_code_deactivate.zip"
}

# EventBridge rule to trigger the deactivation Lambda at 6 PM IST (12:30 PM UTC)
resource "aws_cloudwatch_event_rule" "deactivate_users_event" {
  name                = "deactivate_users_event"
  schedule_expression = "cron(30 12 * * ? *)"  # 12:30 PM UTC (6 PM IST)
}

resource "aws_cloudwatch_event_target" "deactivate_users_target" {
  rule      = aws_cloudwatch_event_rule.deactivate_users_event.name
  target_id = "deactivate_lambda"
  arn       = aws_lambda_function.deactivate_users_lambda.arn
}

resource "aws_lambda_permission" "deactivate_lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deactivate_users_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.deactivate_users_event.arn
}

