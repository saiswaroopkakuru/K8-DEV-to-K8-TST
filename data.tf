data "aws_region" "current" {}
data "aws_iam_account_alias" "current" {}
data "aws_caller_identity" "current" {}
data "aws_iam_role" "build_agent" {
  name = "CSGPBuildAgentRole"
}