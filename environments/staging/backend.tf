terraform {
  backend "s3" {
    bucket         = "terraform-3tier-1764945557-akhi"
    key            = "staging/terraform.tfstate"        # ← FIXED for staging
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}