provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "example" {
  function_name = "example"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "example.handler"
  runtime       = "nodejs12.x"
  source_code_zip = file("example.zip")
  environment {
    variables = {
      EXAMPLE_ENV_VAR = "example_value"
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_exec" {
  name = "lambda_exec"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:*"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  role = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec.arn
}

resource "aws_api_gateway_rest_api" "example" {
  name = "example"
}

resource "aws_api_gateway_resource" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "example"
}

resource "aws_api_gateway_method" "example" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.example.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  type = "AWS_PROXY"
  uri = aws_lambda_function.example.invoke_arn
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name = "prod"
}

resource "aws_cognito_user_pool" "example" {
  name = "example"
}

resource "aws_cognito_user_pool_client" "example" {
  name = "example"
  user_pool_id = aws_cognito_user_pool.example.id
}

resource "aws_api_gateway_authorizer" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  name = "example"
  type = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns = [aws_cognito_user_pool.example.arn]
}

resource "aws_api_gateway_method_response" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  status_code = aws_api_gateway_method_response.example.status_code
}
