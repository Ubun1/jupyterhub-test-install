provider "aws" {
    region =  "us-east-1"
    shared_credentials_file = "~/.aws/credentials"
}

variable "server_port" {
    default = 22
}
variable "local_ip" {
}
variable "key_name" {
}
variable "fqdn" {
}
variable "subnet_id" {
}
variable "domain_cert" {
}
data "aws_route53_zone" "personal" {
  name         = "${var.fqdn}"
}

data "aws_acm_certificate" "cert" {
  domain   = "${var.domain_cert}"
  statuses = ["ISSUED"]
}

resource "aws_instance" "juphub-serv" {
    ami = "ami-05ed6813"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.instance.id}"]
    key_name = "${var.key_name}"

    root_block_device  {
        volume_size = 15
    }

    provisioner "file" {
    source      = "init.sh"
    destination = "./init.sh"
    connection {
        type     = "ssh"
        user     = "ubuntu"
      }
    }

    provisioner "remote-exec" {
        inline = [
            "sudo chmod +x ./init.sh",
            "sudo ./init.sh",
        ]
        connection {
        type     = "ssh"
        user     = "ubuntu"
      }
    }

    tags {    
        Name = "juphub-serv" 
    }
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["${var.local_ip}/32"]
    }   
    ingress {
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # for juphub
    ingress {
        from_port = "8000"
        to_port = "8000"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = "443"
        to_port = "443"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
    
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group" "elb-sg" {
    name = "elb-sg"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "elb" {
  name    = "elb"
  subnets = ["${var.subnet_id}"]

  security_groups = ["${aws_security_group.elb-sg.id}"]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.cert.arn}"
  }

  instances = ["${aws_instance.juphub-serv.id}"]

  tags {
    Name = "elb"
  }
}


resource "aws_route53_record" "4-grade" {
  zone_id = "${data.aws_route53_zone.personal.zone_id}"
  name    = "juphub.${var.fqdn}"
  type    = "A"
  
  alias {
    name                   = "${aws_elb.elb.dns_name}"
    zone_id                = "${aws_elb.elb.zone_id}"
    evaluate_target_health = false
  }
}

output "public_ip" {
    value = "${aws_instance.juphub-serv.public_ip}"
}

output "private_ip" {
    value = "${aws_instance.juphub-serv.private_ip}"
}