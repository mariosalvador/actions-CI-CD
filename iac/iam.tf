resource "aws_iam_openid_connect_provider" "openid-connect-git" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "1b511abead59c6ce207077c0bf0e0043b1382612",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
    "6938fd4d98bab03faadb97b34396831e3780aea1"
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
          Federated = aws_iam_openid_connect_provider.openid-connect-git.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:mariosalvador/actions-CI-CD:*"
          }
        }
      }
    ]
  })

  tags = {
    IAC = "True"
  }
}


resource "aws_iam_role_policy" "ecr_app_permissions" {
  name = "ecr-app-permissions"
  role = aws_iam_role.ecr-role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ECRGetAuthorizationToken"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Sid    = "ECRRepositoryPermissions"
        Effect = "Allow"

        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]

        Resource = aws_ecr_repository.ecr-reposi.arn
      }
    ]
  })
}
