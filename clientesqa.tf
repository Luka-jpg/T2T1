variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
    region = "us-east-1"  # Cambiado a us-east-1
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}

data "aws_security_group" "existing" {
    name = "instance_security_group"
}

resource "aws_security_group" "instance_security_group" {
    count = data.aws_security_group.existing.id == null ? 1 : 0
    name = "instance_security_group"
    description = "Security group for EC2 instance"
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "clientesqa_instance" {
    ami = "ami-019f9b3318b7155c5"  # AMI de Amazon Linux
    instance_type = "t2.micro"  # Tipo de instancia
    key_name = "clavepem"  # Nombre de la clave de acceso existente en AWS
    
    vpc_security_group_ids = coalesce([data.aws_security_group.existing.id], length(aws_security_group.instance_security_group) > 0 ? [aws_security_group.instance_security_group[0].id] : [])

    tags = {
        Name = "ORG-CLIENTES-QA"  # Nombre de la instancia
    }
}

output "instance_ip_clientesqa" {
    value = aws_instance.clientesqa_instance.public_ip
}
