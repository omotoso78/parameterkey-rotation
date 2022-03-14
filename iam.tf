# IAM role for Cloudwatch

resource "aws_iam_role" "lambda_exec" {
  name = "ssmlambda_cloudwatch"
  assume_role_policy = <<-POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}


##configure inline policy (using data source option to be completed later)

resource "aws_iam_policy" "ssm_inline" {
  name        = "ssm_lambda_inline"
  path        = "/"
  description = "MANAGED BY TERRAFORM Allow ssm_lambda to log"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Resource": "aws_lambda_function.ssm_lambda.arn"
        },
        {
          "Effect": "Allow",
          "Action": ["ssm:*"],
          "Resource": "aws_lambda_function.ssm_lambda.arn"
        }
    ]
}
POLICY
}


/*data "aws_iam_policy_document" "ssm_lambda_inline" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]

    resources = [
      aws_lambda_function.ssm_lambda.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:*"
    ]

    resources = [
      aws_lambda_function.ssm_lambda.arn,
    ]

    }

  statement {
    effect = "Allow"
    actions = [
      "ssm:*"
    ]

    resources = [
      aws_lambda_function.ssm_lambda.arn,
    ]
  }
}

resource "aws_iam_policy" "policydocument" {
  name        = "ssm_lambda-inlinepolicy"
  policy      = data.aws_iam_policy_document.ssm_lambda_inline.json
}*/



#Attach IAM policy role to Lambda
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_role.lambda_exec.arn
              
}