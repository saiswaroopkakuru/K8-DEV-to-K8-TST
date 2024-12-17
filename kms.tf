#resource "aws_kms_key" "tensorflow" {
#  description = "KMS key for Case-management"
#  enable_key_rotation = true
#  policy = data.aws_iam_policy_document.tensorflow_kms_key.json
#  tags = local.common_tags
#}
#
#resource "aws_kms_alias" "tensorflow" {
#  name = "alias/${local.application}-${local.service}-${terraform.workspace}"
#  target_key_id = aws_kms_key.tensorflow.arn
#}
#
#data "aws_iam_policy_document" "tensorflow_kms_key" {
#  statement {
#    effect = "Allow"
#    principals {
#      type = "Service"
#      identifiers = [
#          "logs.${data.aws_region.current.name}.amazonaws.com",
#          ]
#    }
#    actions = [
#      "kms:Encrypt",
#      "kms:Decrypt",
#      "kms:ReEncrypt*",
#      "kms:GenerateDataKey*",
#      "kms:DescribeKey"
#    ]
#    resources = [
#      "*"
#    ]
#  }
#
#  statement {
#    effect = "Allow"
#    principals {
#      type = "AWS"
#      identifiers = [
#        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws_research_${local.channels[terraform.workspace]}_developers"
#      ]
#    }
#    actions = [
#      "kms:Decrypt"
#    ]
#    resources = [
#      "*"
#    ]
#  }
#
#  statement {
#    sid = "Enable IAM User Permissions"
#    effect = "Allow"
#    principals {
#      type = "AWS"
#      identifiers = [
#        data.aws_iam_role.build_agent.arn
#      ]
#    }
#    actions = [
#      "kms:*",
#    ]
#    resources = [
#      "*"
#    ]
#  }
#
#  statement {
#    sid = "Enable IAM policies"
#    effect = "Allow"
#    principals {
#      type = "AWS"
#      identifiers = [
#        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#      ]
#    }
#    actions = [
#      "kms:*"
#    ]
#    resources = [
#      "*"
#    ]
#  }
#}