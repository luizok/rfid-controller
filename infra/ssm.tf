resource "aws_ssm_parameter" "last_hash" {
  name  = "/${var.project-name}/dev/last_hash"
  type  = "String"
  value = "foo"
  overwrite = true
}
