resource "aws_vpc" "vpc-rucha" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "rucha-vpc"
    "Description" = "Practice VPC"
  }
}