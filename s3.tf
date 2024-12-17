
# s3 bucket for the trained models
module "models" {
  source  = "git::https://git.prd.costargroup.com/tf/csgp-aws-s3.git?ref=v2"

  application           = local.application
  service               = local.service
  vertical              = local.vertical
  component             = "trained-models"
  s3_allowed_role_arn   = aws_iam_role.s3_access_role.arn
  s3_versioning_enabled = "false"
  dataclassification    = local.data_classification
  provisionedby         = local.provisioned_by
  publiclyaccessible    = local.publicly_accessible
}
#  kms_master_key_id = aws_kms_key.tensorflow.key_id
#  lifecycle_rules = [
#    {
#      id                                     = "90-day-expiration"
#      enabled                                = true
#      abort_incomplete_multipart_upload_days = 7
#      expiration = {
#        days = 90
#      }
#    }
#  ]
#}
