resource "aws_vpc" "test-vpc" {
  cidr_block = "20.10.0.0/20"
  instance_tenancy = "default"
  tags = {
    "Name" = "test-VPC"
  }
}

resource "aws_subnet" "subnet01" {
    vpc_id = aws_vpc.test-vpc.id
    cidr_block = "20.10.0.0/25"
    availability_zone = "us-east-1a"
    tags = {
      "Name" = "subnet-01"
    }
}

resource "aws_internet_gateway" "test-ig" {
    vpc_id = aws_vpc.test-vpc.id
    tags = {
      "Name" = "rucha-ig"
    }
}

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-ig.id
  }
}

resource "aws_route_table_association" "assoc-subnet-01" {
  subnet_id      = aws_subnet.subnet01.id
  route_table_id = aws_route_table.public-route.id
}

resource "aws_security_group" "allow-ssh" {
  name        = "allow-ssh"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.test-vpc.id

  tags = {
    Name = "allowssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow-ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_instance" "ec2" {
  ami                         = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.subnet01.id
  vpc_security_group_ids      = [aws_security_group.allow-ssh.id]
  key_name                    = "acc-key-pair"
  associate_public_ip_address = true

  tags = {
    Name = "terraform-ec2"
  }
}
