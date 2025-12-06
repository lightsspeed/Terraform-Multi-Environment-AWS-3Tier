terraform {
  backend "s3" {
    bucket         = "terraform-3tier-1764945557-akhi" # ← your real bucket
    key            = "dev/terraform.tfstate"           # ← FIXED for dev
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}