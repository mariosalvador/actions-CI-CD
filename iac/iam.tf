resource "aws_iam_openid_connect_provider" "openid-connect-git" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  tags = {
    IAC  = "True"
    Name = "GitHub OIDC Provider"
  }
}


resource "aws_iam_role" "ecr-role" {
  name = "ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = "sts:AssumeRoleWithWebIdentity"

        Principal = {
          Federated = "arn:aws:iam::652656942111:oidc-provider/token.actions.githubusercontent.com"
        }

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = [
              "sts.amazonaws.com"
            ]
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:mariosalvador/actions-CI-CD:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
  })

  tags = {
    IAC = "True"
  }
}


resource "aws_iam_role_policy" "ecr-app-permissions" {
  name = "ecr-app-permissions"

  role = aws_iam_role.ecr-role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid = "ECRAppPermissions"

        Effect = "Allow"

        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      }
    ]
  })
}
