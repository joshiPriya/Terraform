#provider block

provider "aws" {
 
  region     = "${var.region}"
}


#Create EC2 instance
resource "aws_instance" "TestInstance1" {
  ami             = "${data.aws_ami.TestAMI.id}"
  instance_type   = "${var.instance_type}"
  count = 1
  key_name = "demo-key"
  vpc_security_group_ids = [
      "${aws_security_group.webSG.id}",
  ]
  tags = {
    Name = "HelloWorld"
  }

   connection {
    type = "ssh"
    user = "ec2-user"
    host = "${self.public_ip}"
    private_key = "${file("demo-key.pem")}"
  }

  
#provisioners - File 
   
  provisioner "file" {
    source      = "playbook.yaml"
    destination = "/tmp/playbook.yaml"

 }

  #provisioners - remote-exec 
  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install  ansible2 -y",
      "sleep 20s",
      "sudo ansible-playbook -i localhost /tmp/playbook.yaml",
      "sudo chmod 657 /var/www/html"
    ]
    
  }

#    provisioner "file" {
#     source      = "index.html"
#     destination = "/var/www/html/index.html"

#  }

  }

  

# data source - AMI
data "aws_availability_zones" "available" {}
data "aws_ami" "TestAMI" {
  most_recent = true
  owners = ["amazon"]

  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
   filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#resources
#crate vpc
# resource "aws_vpc" "vpc" {
#   cidr_block           = "10.1.0.0/16"
#   enable_dns_hostnames = "true"

# }


#Create Security Group  
resource "aws_security_group" "webSG" {
  name        = "webSG"
  description = "Allow ssh  inbound traffic"
  vpc_id      =  "vpc-73500f09"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 433
    to_port     = 433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}



#outputs

output "TestInstance1_pub_ip" {
    value = "${aws_instance.TestInstance1.0.public_ip}"
}

output "TestInstance1_id" {
    value = "${aws_instance.TestInstance1.0.id}"
}
