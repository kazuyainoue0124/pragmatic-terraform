data "aws_ami" "recent_amazon_linux_2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name = "state"
    values = ["available"]
  }
}

resource "aws_instance" "example4" {
  ami = data.aws_ami.recent_amazon_linux_2.image_id
  instance_type = "t3.micro"
}