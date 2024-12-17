locals {
  common_tags = {
    vertical            = local.vertical
    application         = local.application
    service             = local.service
    environment         = terraform.workspace
    data_classification = local.data_classification
    publicly_accessible = local.publicly_accessible
    provisioned_by      = local.provisioned_by
  }
  channels = {
    sbx = "sbx"
    dvm = "dev"
    dvr = "dev"
    tsm = "tst"
    tsr = "tst"
    prd = "prd"
  }
  application         = "we"
  service             = "case-management-ml"
  data_classification = "Confidential"
  publicly_accessible = "False"
  provisioned_by      = "Terraform"
  vertical            = element(split("-", data.aws_iam_account_alias.current.account_alias), 1)
}