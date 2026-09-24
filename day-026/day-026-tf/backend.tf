terraform {
  backend "s3" {
    bucket = "day26-tfstate-bucket-201158794154-eu-north-1-an"
    key = "day26/scratch/terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "day26-tfstate-locks"
    encrypt = true
  }
}