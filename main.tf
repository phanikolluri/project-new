module "eks" {
  source = "./modules/eks"
}

terraform {
  backend "s3" {
    bucket = "eks-s3-bucket41"
    key    = "eks-project/terraform.tfstate"
    region = "us-east-1"
  }
}

