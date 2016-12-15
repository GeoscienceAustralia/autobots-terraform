provider "aws" {
    region = "ap-southeast-2"
}

#data "aws_availability_zones" "all" {}

#variable "aws_availability_zones" {
#    default = ["ap-southeast-2a","ap-southeast-2b","ap-southeast-2c"]
#}

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

resource "aws_subnet" "elb-subnet" {
    vpc_id = "${aws_vpc.www-vpc.id}"
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true
}

resource "aws_launch_configuration" "www-lc" {
    name_prefix = "www-lc"
    image_id = "ami-4d3b062e"
    instance_type = "t2.micro"
    
    user_data = <<-EOF
    #!/bin/bash
    echo "Hello World" >> index.html
    busybox httpd -f -p 80 &
    EOF

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "www" {
    launch_configuration = "${aws_launch_configuration.www-lc.name}"
    load_balancers = ["${aws_elb.elb.name}"]
    health_check_type = "ELB"
    vpc_zone_identifier = ["${aws_subnet.www-subnet.id}"]
    min_size = 1
    max_size = 2
}

resource "aws_elb" "elb" {
    name = "wwwterraformelb"
    subnets = ["${aws_subnet.elb-subnet.id}"] 
    security_groups = ["${aws_security_group.elbsg.id}"]
    cross_zone_load_balancing = true
    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }
}


resource "aws_security_group" "www" {
    name = "wwwterraformsg"
    vpc_id = "${aws_vpc.www-vpc.id}"
    description = "Autobots are the best"
    ingress {
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "elbsg" {
    name = "elbterraformsg"
    vpc_id = "${aws_vpc.www-vpc.id}"
    description = "Autobots are the best"
    ingress {
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

