#Configure Rest API object
/*resource "aws_api_gateway_rest_api" "ssm_api" {
  name        = "SSM1API"
  description = "Terraform built Serverless SSM Rotation Application"
}
# next 2 define a single proxy resource
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.ssm_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.ssm_api.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.ssm_api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "PUT"
  authorization = "NONE" 
}

# intergrate API gateway with Lambda
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.ssm_api.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST" # while all methods can be used here Lambda function can only be invoked with post
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.ssm_lambda.invoke_arn}"
}
# The next 2 enables empty path queries
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.ssm_api.id}"
  resource_id   = "${aws_api_gateway_rest_api.ssm_api.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.ssm_api.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.ssm_lambda.invoke_arn}"
}

#Create API deployment, activating configuration, expose API to internet
resource "aws_api_gateway_deployment" "ssm_api" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = "${aws_api_gateway_rest_api.ssm_api.id}"
  stage_name  = "prod"
}

# The next set of codes Provides API Gateway Usage Plan Key.

resource "aws_api_gateway_usage_plan" "myusageplan" {
  name = "my_usage_plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.ssm_api.id
    stage  = aws_api_gateway_deployment.ssm_api.stage_name
  }
}

resource "aws_api_gateway_api_key" "mykey" {
  name = "my_key"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.mykey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.myusageplan.id
}*/

#Configure Rest API object
resource "aws_api_gateway_rest_api" "ssm_API" {
  name        = "SSM1API"
  description = "Terraform built Serverless SSM Rotation Application"
}
#Configure API resource
resource "aws_api_gateway_resource" "ssm_APIResource" {
  rest_api_id = aws_api_gateway_rest_api.ssm_API.id
  parent_id   = aws_api_gateway_rest_api.ssm_API.root_resource_id
  path_part   = "prod"
}
#REST API method
resource "aws_api_gateway_method" "ssm_APIMethod" {
  rest_api_id   = aws_api_gateway_rest_api.ssm_API.id
  resource_id   = aws_api_gateway_resource.ssm_APIResource.id
  http_method   = "PUT" 
  authorization = "NONE" 
  api_key_required = true # to connect created token key to method
}
resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.ssm_API.id
  resource_id = aws_api_gateway_resource.ssm_APIResource.id
  http_method = aws_api_gateway_method.ssm_APIMethod.http_method

  integration_http_method = "PUT" # while all methods can be used here Lambda function can only be invoked with post
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.ssm_lambda.invoke_arn
}

#Configure API deployment

resource "aws_api_gateway_deployment" "ssm_APIdeployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.ssm_API.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.ssm_API.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Confiure API stage
resource "aws_api_gateway_stage" "ssm_APIstage" {
  deployment_id = aws_api_gateway_deployment.ssm_APIdeployment.id
  rest_api_id   = aws_api_gateway_rest_api.ssm_API.id
  stage_name    = "prod"
}
#configure path method setting 
#resource "aws_api_gateway_method_settings" "all" {
  #rest_api_id = aws_api_gateway_rest_api.ssm_API.id
  #stage_name  = aws_api_gateway_stage.ssm_APIstage.stage_name
 # method_path = "*/*" 

 /* settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}*/

#provide API gateway usage plan
resource "aws_api_gateway_usage_plan" "ssm-usage-plan" {
  name         = "ssm-usage-plan"
  description  = "usage plan for terraform built serveless ssm rotation app"
  product_code = "MYCODE"

  api_stages {
    api_id = aws_api_gateway_rest_api.ssm_API.id
    stage  = aws_api_gateway_stage.ssm_APIstage.stage_name
  }
}
# The next set of codes Provides API Gateway Usage Plan Key.

resource "aws_api_gateway_api_key" "rotationkey" {
  name = "my_key"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.rotationkey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.ssm-usage-plan.id
}