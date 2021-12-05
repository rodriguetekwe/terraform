

#this is our entire network structure

resource "aws_vpc" "appvpc" {
cidr_block = var.myvpcvarsCidr
tags= {
    Name = "myappvpc"
}
}
resource "aws_internet_gateway" "IG" {
  vpc_id = aws_vpc.appvpc.id

  tags = {
    Name = "appIG"
  }
}


resource "aws_route_table" "myRT" {
  vpc_id = aws_vpc.appvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.IG.id
  }

  tags = {
    Name = "appRT"
  }
}


resource "aws_subnet" "appPubSn" {
  vpc_id     = aws_vpc.appvpc.id
  cidr_block = var.myappSNcidr

  tags = {
    Name = "myappPubSN"
  }
}

resource "aws_subnet" "appPrvt" {
  vpc_id     = aws_vpc.appvpc.id
  cidr_block = var.prvtSN

  tags = {
    Name = "myappPrtSN"
  }
}


resource "aws_route_table_association" "myRTassocc" {
  subnet_id      = aws_subnet.appPubSn.id
  route_table_id = aws_route_table.myRT.id
}

#this is a securigroupe for my web sever in a puplic SN

resource "aws_security_group" "my_instance_SG" {
  name        = "allow HTTP/HTTPs traffic"
  description = "Allow port 80/443 traffic"
  vpc_id      = aws_vpc.appvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.appvpc.id]
  }

ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "myappinstance-SG"
  }
} 


#this is ssh security group for my instances in private only


resource "aws_security_group" "my_SSH_SG" {
  name        = "allow_only_port_22_traffic"
  description = "Allow port 22 traffic only"
  vpc_id      = aws_vpc.appvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.Bastionhost_SG
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "appSSH-SG"
  }
} 
