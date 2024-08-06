resource "aws_api_gateway_account" "ApiGatewayAccount" {
  cloudwatch_role_arn = aws_iam_role.IamRole.arn
}

resource "aws_api_gateway_rest_api" "ApiGatewayRestApi" {
  name           = var.api_name
  api_key_source = "HEADER"
  endpoint_configuration {
    types = [
      "REGIONAL"
    ]
  }
}

resource "aws_api_gateway_resource" "ApiGatewayResource" {
  rest_api_id = aws_api_gateway_rest_api.ApiGatewayRestApi.id
  path_part   = "{proxy+}"
  parent_id   = aws_api_gateway_rest_api.ApiGatewayRestApi.root_resource_id
}

resource "aws_api_gateway_method" "ApiGatewayMethod" {
  rest_api_id      = aws_api_gateway_rest_api.ApiGatewayRestApi.id
  resource_id      = aws_api_gateway_resource.ApiGatewayResource.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = false

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "ApiGatewayIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.ApiGatewayRestApi.id
  resource_id             = aws_api_gateway_resource.ApiGatewayResource.id
  http_method             = aws_api_gateway_method.ApiGatewayMethod.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://api.mercadolibre.com/{proxy}"
  integration_http_method = "GET"

  #cache_key_parameters = ["method.request.path.proxy"]

  timeout_milliseconds = 29000
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "ApiGatewayDeployment" {
  rest_api_id = aws_api_gateway_rest_api.ApiGatewayRestApi.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_method.ApiGatewayMethod, aws_api_gateway_integration.ApiGatewayIntegration]
}

resource "aws_api_gateway_stage" "ApiGatewayStage" {
  deployment_id = aws_api_gateway_deployment.ApiGatewayDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.ApiGatewayRestApi.id
  stage_name    = var.stage_name

  # access_log_settings {
  #   destination_arn = aws_cloudwatch_log_group.CwLogGroup.arn
  #   format          = "{ \"requestId\":\"$context.requestId\", \"extendedRequestId\":\"$context.extendedRequestId\",\"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }"
  # }
  # depends_on = [aws_cloudwatch_log_group.CwLogGroup, aws_api_gateway_account.ApiGatewayAccount]
}

resource "aws_api_gateway_method_settings" "ApiGatewayMethodSettings" {
  rest_api_id = aws_api_gateway_rest_api.ApiGatewayRestApi.id
  stage_name  = aws_api_gateway_stage.ApiGatewayStage.stage_name
  method_path = "*/*"

  settings {
    logging_level      = "INFO"
    metrics_enabled    = true
    data_trace_enabled = true
  }

  depends_on = [aws_api_gateway_account.ApiGatewayAccount]
}
