# Terraform Config file (main.tf). This has provider block (AWS) and config for provisioning one EC2 instance resource.  

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }

  required_version = ">=0.14"
}
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "env" = var.env })
}

# Create a new VPC 
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-vpc"
    }
  )
}

# Add provisioning of the public subnetin the default VPC
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-public-subnet-${count.index}"
    }
  )
}
# Add provisioning of the private subnetin the default VPC
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-private-subnet-${count.index}"
    }
  )
}


# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-igw"
    }
  )
}
#Create elastic ips for nat gateways
resource "aws_eip" "static_eip" {
  #instance = aws_instance.acs73026.id
  count = length(aws_subnet.public_subnet[*].id)
  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-eip${count.index}"
    }
  )
}

#Create nat gateway
resource "aws_nat_gateway" "nat" {
  count          = length(aws_subnet.public_subnet[*].id)
  connectivity_type = "public"
  allocation_id = aws_eip.static_eip[count.index].id
  subnet_id         = aws_subnet.public_subnet[count.index].id
   tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-ngw"
    }
  )
}

# Route table to route add default gateway pointing to Internet Gateway (IGW)
resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.prefix}-route-public-subnets"
  }
}
# Route table pointing to subnet 2 bastion
resource "aws_route_table" "private_subnet0" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[0].id
  }
  tags = {
    Name = "${var.prefix}-route-private-subnet0"
  }
}
# Route table pointing to subnet 2 bastion
resource "aws_route_table" "private_subnet1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[1].id
  }
  tags = {
    Name = "${var.prefix}-route-private-subnet1"
  }
}
# Associate subnets with the custom route table
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}
#Nat gateway 0 to private subnet 0
resource "aws_route_table_association" "private_route_table_association" {
  #count          = length(aws_subnet.private_subnet[*].id)
  route_table_id = aws_route_table.private_subnet0.id
  subnet_id      = aws_subnet.private_subnet[0].id
}
#Nat gateway1 to private subnet1
resource "aws_route_table_association" "private_route_table_association1" {
  #count          = length(aws_subnet.private_subnet[*].id)
  route_table_id = aws_route_table.private_subnet1.id
  subnet_id      = aws_subnet.private_subnet[1].id
}

