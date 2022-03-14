# Zip Lambda code
data "archive_file" "ssm-rotation-function"{
  type             = "zip"
  source_dir      = "${path.module}/python-ssm"
  #output_file_mode = "0666"
  output_path      = "${path.module}/python-ssm.zip"
}

#Create Lambda function

resource "aws_lambda_function" "ssm_lambda" {
  filename          = data.archive_file.ssm-rotation-function.output_path
  function_name     = "ssmkeyrotation_lambda"
  handler           = "ssm-rotation-function.Lambda_handler"
  runtime = "python3.8"
  role              = aws_iam_role.lambda_exec.arn  # putting the role in as string will generate a Validation expectation status code 400, updated 
  source_code_hash  = data.archive_file.ssm-rotation-function.output_base64sha256
  memory_size       = 128
  timeout           = 5
}

resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowExecutionFromAPIGateway" # I changed this old AllowAPIgatewayInvokation
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ssm_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

#Grants permissions for REST APIgateway to invoke lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "Allow"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ssm_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"
  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.ssm_API.execution_arn}/*/*"
}

