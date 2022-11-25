resource "aws_instance" "web_server" {
  ami           = "ami-08c40ec9ead489470"
  instance_type = "t2.micro"
  associate_public_ip_address = true
tags = {
    Name = "web_server"
  }
# VPC
  subnet_id = aws_subnet.public_subnets[1].id
# Security Group
  vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]
# the Public SSH key. This relies on an ssh key pair of the same name being available in this directory (not included obviously)  
  key_name = aws_key_pair.aws-key.id
# copy across the Python app to the instance
  provisioner "file" {
    source = "flask_app.zip"
    destination = "/tmp/flask_app.zip"
  }
# cloud_init script to run
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install python3-venv unzip
    sudo apt install unzip
    sudo apt install python3-flask
    mkdir flask_dir && cd flask_dir
    python3 -m venv venv
    source venv/bin/activate
    pip install flask
    python -m flask --version
    unzip /tmp/flask_app.zip
    cd /flask_dir/venv/flask
    flask run --host 0.0.0.0
    EOF

# Setting up the ssh connection to install the nginx server
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("${var.PRIVATE_KEY_PATH}")
  }
}
