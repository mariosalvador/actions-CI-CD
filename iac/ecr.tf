resource "aws_ecr_repository" "ecr-reposi" {
  name = "ecr-reposi"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = {
    IAC = "True"
  }
}
