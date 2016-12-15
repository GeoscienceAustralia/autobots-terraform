provider "aws" {
    region = "ap-southeast-2"
}

resource "aws_instance" "www" {
    ami = "ami-4d3b062e"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.www.name}"]
    user_data = <<-EOF
    #!/bin/bash
    echo "Hello World" >> index.html
    busybox httpd -f -p 80 &
    EOF
}

resource "aws_security_group" "www" {
    name = "wwwterraformsg"
    description = "Shane is the best"
    ingress {
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
