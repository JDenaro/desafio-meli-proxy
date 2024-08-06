data "template_file" "dashboard" {
  template = file("dashboard.json")
  vars = {
    api_name = var.api_name
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.api_name}-metrics"
  dashboard_body = data.template_file.dashboard.rendered
}
