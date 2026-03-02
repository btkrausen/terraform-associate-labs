# Static configuration with hardcoded values
resource "aws_vpc" "production" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "production-vpc"
    Environment = "production"
    Project     = "static-infrastructure"
    ManagedBy   = "manual-deployment"
    Region      = "us-east-1"
    AccountID   = "123456789"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.production.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name        = "production-private-subnet"
    Environment = "production"
    Project     = "static-infrastructure"
    ManagedBy   = "terraform"
    Region      = "us-east-1"
    AZ          = "us-east-1a"
  }
}

resource "aws_route_table" "static" {
  vpc_id = aws_vpc.production.id

  tags = {
    Name        = "production-route-table"
    Environment = "production"
    Project     = "static-infrastructure"
    ManagedBy   = "terraform"
    Region      = "us-east-1"
  }
}