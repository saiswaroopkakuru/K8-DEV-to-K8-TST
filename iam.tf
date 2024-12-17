resource "aws_iam_role" "s3_access_role" {
  name = "${local.application}-${local.service}-${terraform.workspace}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}

  POLICY
}

resource "aws_iam_policy" "we_case_management_ml_s3" {
  name = "${local.application}-${local.service}-${terraform.workspace}"
  policy = data.aws_iam_policy_document.we_case_management_ml_document.json
}

data "aws_iam_policy_document" "we_case_management_ml_document" {
  statement {
    effect = "Allow"

    actions = [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListObjectsV2"      
    ]
    
    resources = [
      "${module.models.s3_bucket_arn}",
      "${module.models.s3_bucket_arn}/*"
    ]
    }
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.we_case_management_ml_s3.arn
}