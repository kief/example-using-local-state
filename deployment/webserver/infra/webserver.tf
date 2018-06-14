
data "aws_ami" "webserver" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "webserver" {

  ami                     = "${data.aws_ami.webserver.id}"
  instance_type           = "t2.micro"
  subnet_id               = "${element(split (",", module.base-network.private_subnet_ids), 0)}"
  vpc_security_group_ids  = [ "${module.bastion.allow_ssh_from_bastion_security_group_id}" ]
  key_name                = "${aws_key_pair.webserver.key_name}"

  tags {
    Name                  = "${var.service}-${var.component}-${var.deployment_identifier}"
    ServerRole            = "webserver"
    DeploymentIdentifier  = "${var.deployment_identifier}"
    Service               = "${var.service}"
    Component             = "${var.component}"
    Estate                = "${var.estate}"
  }
}

resource "aws_key_pair" "webserver" {
  key_name = "webserver-${var.service}-${var.component}-${var.deployment_identifier}"
  public_key = "${file(var.webserver_ssh_public_key_path)}"
}
