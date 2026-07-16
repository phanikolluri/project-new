terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}



resource "aws_db_parameter_group" "main" {
  name_prefix = "wmp-db"
  family      = "postgres16"
}


resource "aws_db_subnet_group" "main" {
  name       = "wmp-db"
  subnet_ids = ["subnet-0d6e6257f7a9c428c", "subnet-0c0ea58946872d97d"]

  tags = {
    Name = "wmp-db"
  }
}

resource "aws_security_group" "main" {
  name       = "wmp-rds-db"

  ingress {
    from_port        = 5432
    to_port          = 5432
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
    Name = "wmp-rds-db"
  }
}


resource "aws_db_instance" "main" {
  allocated_storage    = 10
  db_name              = "wmp-db"
  engine               = "postgres"
  engine_version       = "16.0"
  instance_class       = "db.t3.micro"
  username             = "wmpuser"
  password             = "WmpUser#1234"
  parameter_group_name = aws_db_parameter_group.main.name
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.main.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  
}

resource "null_resource" "schema_load" {

  provisioner "local-exec" {
    command = <<EOF
curl -o global-bundle.pem https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
PGPASSWORD='WmpUser#1234' /usr/pgsql-16/bin/psql  'host=${aws_db_instance.main.address} port=5432 dbname=wmp-db user=wmpuser sslmode=verify-full sslrootcert=./global-bundle.pem' <${path.module}/setup.sql
EOF
  }
}
