# Lambda function to reactivate AWS users
resource "aws_lambda_function" "reactivate_users_lambda" {
  function_name = "reactivate_users"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  filename      = "reactivate_lambda/lambda_code_reactivate.zip"
}

# EventBridge rule to trigger the reactivation Lambda at 10 AM IST (4:30 AM UTC)
resource "aws_cloudwatch_event_rule" "reactivate_users_event" {
  name                = "reactivate_users_event"
  schedule_expression = "cron(30 4 * * ? *)"  # 4:30 AM UTC (10 AM IST)
}

resource "aws_cloudwatch_event_target" "reactivate_users_target" {
  rule      = aws_cloudwatch_event_rule.reactivate_users_event.name
  target_id = "reactivate_lambda"
  arn       = aws_lambda_function.reactivate_users_lambda.arn
}

resource "aws_lambda_permission" "reactivate_lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reactivate_users_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.reactivate_users_event.arn
}

