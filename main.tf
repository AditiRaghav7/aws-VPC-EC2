terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# Create a VPC
resource "aws_vpc" "terraform_VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform_VPC"
  }
}

# Private subnet
resource "aws_subnet" "private-subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.terraform_VPC.id
  tags = {
    Name = "private-subnet"
  }
}

# Public subnet
resource "aws_subnet" "public-subnet" {
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.terraform_VPC.id
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Internet gateway
resource "aws_internet_gateway" "my-igw-tf" {
  vpc_id = aws_vpc.terraform_VPC.id
  tags = {
    Name = "my-igw-terraform"
  }
}

# Routing table
resource "aws_route_table" "my-rt" {
  vpc_id = aws_vpc.terraform_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw-tf.id
  }

  tags = {
    Name = "my-route-table-ec2"
  }
}

resource "aws_route_table_association" "public-sub" {
  route_table_id = aws_route_table.my-rt.id
  subnet_id      = aws_subnet.public-subnet.id
}


resource "aws_instance" "VPC-ec2" {
  ami                         = "ami-0b02608ac063c1939"
  instance_type               = "t3.nano"
  subnet_id                   = aws_subnet.public-subnet.id

  tags = {
    Name = "VPC-ec2"
  }
}
