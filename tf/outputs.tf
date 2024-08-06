output "ApiGwStageInvokeUrl" {
  description = "Stage invoke url"
  value       = aws_api_gateway_stage.ApiGatewayStage.invoke_url
}

# output "ApiGwDeployInvokeUrl" {
#   description = "Deployment invoke url"
#   value       = aws_api_gateway_deployment.ApiGatewayDeployment.invoke_url
# }
