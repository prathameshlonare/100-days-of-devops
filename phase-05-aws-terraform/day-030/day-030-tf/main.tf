resource "aws_s3_bucket" "dorm_dish_assets" {
  bucket = "day30-console-asset-bucket-201158794154"

  tags = {
    project = "Dorm-and-Dish"
    Managedby = "Terraform"
    Environment = "Production"
  }
}

import {
  to = aws_s3_bucket.dorm_dish_assets
  id = "day30-console-asset-bucket-201158794154"
}