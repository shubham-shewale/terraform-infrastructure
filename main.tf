module "vpc" {
  source = "./modules/vpc"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
}

module "alb_sg" {
  source = "./modules/alb_sg"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

module "nacl" {
  source = "./modules/nacl"

  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "alb" {
  source = "./modules/alb"

  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  security_groups = [module.alb_sg.security_group_id]
  # Add acm_certificate_arn if using HTTPS
}