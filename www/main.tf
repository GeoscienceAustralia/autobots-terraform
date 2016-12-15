provider "aws" {
    region = "ap-southeast-2"
}

resource "aws_vpc" "www-vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.www-vpc.id}"
}

resource "aws_route" "internet-access" {
    route_table_id = "${aws_vpc.www-vpc.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "www-subnet" {
    vpc_id = "${aws_vpc.www-vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
}

resource "aws_instance" "www" {
    ami = "ami-4d3b062e"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.www.id}"]
    subnet_id = "${aws_subnet.www-subnet.id}"
    user_data = <<-EOF
    #!/bin/bash
    echo "Hello World" >> index.html
    busybox httpd -f -p 80 &
    EOF
}

resource "aws_security_group" "www" {
    name = "wwwterraformsg"
    vpc_id = "${aws_vpc.www-vpc.id}"
    description = "Autobots are the best"
    ingress {
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
