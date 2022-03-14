#lambda function name
output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.ssm_lambda.function_name
}
#for PUT method url
output "base_url" {
  description = "Base URL for API Gateway stage."

  value = "${aws_api_gateway_deployment.ssm_APIdeployment.invoke_url}"
}

# will print out token key
output "rest_api_key"{
  description = "token_key"
  sensitive = true #required as terraform knows that information is sensitive. 

  value = aws_api_gateway_api_key.rotationkey.value
}