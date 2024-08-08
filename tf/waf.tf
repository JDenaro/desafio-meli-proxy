resource "aws_wafv2_web_acl" "WafV2WebAcl" {
  name        = "${var.api_name}-web-acl"
  scope       = "REGIONAL"
  description = "Web ACL for rate limiting"

  default_action {
    allow {}
  }

  rule {
    name     = "LimitIP-152-152-152-152"
    priority = 1
    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"

        scope_down_statement {
          byte_match_statement {
            search_string = "/"
            field_to_match {
              uri_path {}
            }
            positional_constraint = "STARTS_WITH"
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "LimitIP-152-152-152-152"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "LimitPathCategories"
    priority = 2
    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = 10000
        aggregate_key_type = "IP"

        scope_down_statement {
          byte_match_statement {
            search_string = "/categories/"
            field_to_match {
              uri_path {}
            }
            positional_constraint = "STARTS_WITH"
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "LimitPathCategories"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "LimitIP-152-152-152-152-AndPathItems"
    priority = 3
    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = 100 # No se pueden 10, 100 es el minimo :(
        aggregate_key_type = "IP"

        scope_down_statement {
          and_statement {
            statement {
              byte_match_statement {
                search_string = "/items/"
                field_to_match {
                  uri_path {}
                }
                positional_constraint = "STARTS_WITH"
                text_transformation {
                  priority = 1
                  type     = "LOWERCASE"
                }
              }
            }
            statement {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.WafV2IpSet.arn
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "LimitIP-152-152-152-152-AndPathItems"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.api_name}-web-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_ip_set" "WafV2IpSet" {
  name        = "${var.api_name}-ip-set"
  scope       = "REGIONAL"
  description = "IP Set for rate limiting"

  addresses = ["152.152.152.152/32"]

  ip_address_version = "IPV4"
}

resource "aws_wafv2_web_acl_association" "WafV2WebAclAssociation" {
  resource_arn = aws_api_gateway_stage.ApiGatewayStage.arn
  web_acl_arn  = aws_wafv2_web_acl.WafV2WebAcl.arn
}
