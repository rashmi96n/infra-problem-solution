# Specify the provider and access details
provider "aws" {
  region = "eu-west-1"
  access_key = "AKIAZWJRXR5ANGDSZ36M"
  secret_key = "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"
}


# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames=true
  enable_dns_support=true
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}


# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

#create a route table
resource "aws_route_table" "public-route" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags = {
    Name = "public-route-table-demo"
  }
}

#route table association
resource "aws_route_table_association" "route" {
  subnet_id      = "${aws_subnet.default.id}"
  route_table_id = "${aws_route_table.public-route.id}"
}


# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "thoughtworks_elb"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "thoughtworks"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name = "thoughtworks-elb"

  subnets         = ["${aws_subnet.default.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = ["${aws_instance.web.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

#resource "aws_key_pair" "auth" {
#  key_name   = "${var.key_name}"
#  public_key = "${file(var.public_key_path)}" 
#}

resource "aws_instance" "web" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    type="ssh"
    user = "ubuntu"
    host = self.public_ip
    private_key = file("EC2Tutorial.pem")
    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "rashmi"
  
  # Tag for the aws instance
  tags = {
    Name = "TWApp"
  }
  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.default.id}"

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
provisioner "file" {
    source      = "automation.sh"
    destination = "$HOME/automation.sh"
}



provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/automation.sh",
      "$HOME/automation.sh"
    ]
  }
}
