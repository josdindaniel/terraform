provider "aws" {
  access_key  = var.access_key
  secret_key  = var.secret_key
  region      = var.region
}

# Template User Data
data "template_file" "init" {
  template = file("init.tpl")
}

# Create VPC
resource "aws_vpc" "vpc-cloudprices" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name  = "vpc-cloudprices"
  }
}

# Create subnet public 1
resource "aws_subnet" "publicsubnet-cloudprices" {
  vpc_id              = aws_vpc.vpc-cloudprices.id
  cidr_block          = "10.0.1.0/24"
  availability_zone   = "us-east-1e"
  tags = {
    Name  = "publicsubnet-cloudprices"
  }
}
# Create subnet public 2
resource "aws_subnet" "publicsubnet2-cloudprices" {
  vpc_id              = aws_vpc.vpc-cloudprices.id
  cidr_block          = "10.0.2.0/24"
  availability_zone   = "us-east-1f"
  tags = {
    Name  = "publicsubnet2-cloudprices"
  }
}
# Create route table
resource "aws_route_table" "rt-cloudprices" {
  vpc_id = aws_vpc.vpc-cloudprices.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id        = aws_internet_gateway.igw-cloudprices.id
  }
  tags = {
    Name = "rt-cloudprices"
  }
}

# Association public subnet 1 and route table
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.publicsubnet-cloudprices.id
  route_table_id = aws_route_table.rt-cloudprices.id
}

# Association public subnet 2 and route table
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.publicsubnet2-cloudprices.id
  route_table_id = aws_route_table.rt-cloudprices.id
}

# Set main rout table in VPC
resource "aws_main_route_table_association" "rta-main" {
  vpc_id         = aws_vpc.vpc-cloudprices.id
  route_table_id = aws_route_table.rt-cloudprices.id
}

# Create internet gateway
resource "aws_internet_gateway" "igw-cloudprices"{
  vpc_id = aws_vpc.vpc-cloudprices.id
  tags = {
    Name = "igw-cloudprices"
  }
}

# Create security groups Web
resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Allow inbound web traffic"
  vpc_id      = aws_vpc.vpc-cloudprices.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-sg"
  }
}

# Create instance 1
resource "aws_instance" "webserver" {
  ami               = "ami-428aa838"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1e"
  key_name          = "amazonvm"
  subnet_id         = aws_subnet.publicsubnet-cloudprices.id
  security_groups   = [aws_security_group.web-sg.id]
  user_data         = data.template_file.init.rendered
  tags = {
    Name = "webserver"
  }
}

# Assign elastic ip to instance 1
resource "aws_eip" "ip-webserver" {
  instance    = aws_instance.webserver.id
  depends_on  = [aws_instance.webserver]
  tags = {
    Name = "ip-webserver"
  }
}

/*
# Output
output "ip-webserver" {
  value = aws_eip.ip-webserver.public_ip
}
*/
