# IAM role for Cloudwatch &SSM policy

resource "aws_iam_role" "lambda_exec" {
  name = "ssmlambda"
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

##configure policy

resource "aws_iam_policy" "ssm_policy" {
  name        = "ssm_lambda_policy"
  description = "MANAGED BY TERRAFORM Allow ssm_lambda to log"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": ["logs:CreateLogStream", "logs:CreateGroup"],
          "Resource": "arn:aws:logs:*:*:*"
        },
        
        {
          "Effect": "Allow",
          "Action": ["ssm:PutParameter","ssm:GetParameters","ssm:GetParameter","ssm:DeleteParameter","ssm:DeleteParameters","logs:PutLogEvents" ],
          "Resource": "*"
        },

        {
          "Effect": "Allow",
          "Action": ["ssm:DescribeParameters"],
          "Resource": "*"
        }
    ]
}
POLICY
}

#Attach IAM policy role to Lambda
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.ssm_policy.arn
              
}
