
# Module to deploy basic networking 
module "vpc-dev" {
  source = "github.com/JcmcJc/ACS730-Final-Project//networkmodule"
  #source             = "github.com/JcmcJc/acsnetworkmodule.git"
  env                = var.env
  vpc_cidr           = var.vpc_cidr
  public_cidr_blocks = var.public_subnet_cidrs
  private_cidr_blocks = var.private_subnet_cidrs
  prefix             = var.prefix
  default_tags       = var.default_tags
}
