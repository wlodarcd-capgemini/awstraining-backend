################################################################################
# Remote State Bucket Module
################################################################################
module "remote-state-bucket" {
  source = "../../modules/bucket"

  name    = var.name
  profile = var.profile
  region  = var.region
}