# Declaración de variables
variable "aws_access_key" {
    type = string
    sensitive = true
    description = "AWS Access Key"
}

variable "aws_secret_key" {
    type = string
    sensitive = true
    description = "AWS Secret Key"
}

# Proveedor de AWS
provider "aws" {
    region = "us-east-1"
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}

# Verifica si el grupo de seguridad ya existe
data "aws_security_group" "existing_sg" {
    name = "instance_security_group_custom"
    vpc_id = "tu-vpc-id"  # Asegúrate de que este sea el ID correcto de tu VPC
}

# Recurso de grupo de seguridad
resource "aws_security_group" "instance_security_group_custom" {
    count = data.aws_security_group.existing_sg ? 0 : 1  # Crear solo si no existe

    name = "instance_security_group_custom"
    description = "Custom security group for EC2 instance"

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
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 3000
        to_port = 3000
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

# Recurso de instancia EC2
resource "aws_instance" "clientesqa_instance" {
    ami = "ami-0a3c3a20c09d6f377"  # AMI de Amazon Linux
    instance_type = "t2.micro"  # Tipo de instancia
    key_name = "clavepem"  # Nombre de tu clave de acceso existente en AWS

    # Asociar la instancia con el grupo de seguridad creado o existente
    vpc_security_group_ids = data.aws_security_group.existing_sg ? [
        data.aws_security_group.existing_sg.id
    ] : [
        aws_security_group.instance_security_group_custom.id
    ]

    # Etiquetas para identificar la instancia
    tags = {
        Name = "ORG-CLIENTES-QA"
    }
}

# Bloque de salida para obtener la dirección IP pública de la instancia
output "instance_ip_clientesqa" {
    value = aws_instance.clientesqa_instance.public_ip
}
