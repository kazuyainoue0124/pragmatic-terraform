variable "name" {}
variable "policy" {}
variable "identifier" {}

resource "aws_iam_role" "default" {
  name = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

/*
  ポリシードキュメントで「実行可能なアクション」や「操作可能なリソース」を指定する
  identifiers で関連づけることのできるサービスを指定できる(信頼ポリシー)
*/
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [var.identifier]
    }
  }
}

/*
  ポリシードキュメントを保持するリソースが IAMポリシー
  ポリシー名とポリシードキュメントを設定する
*/
resource "aws_iam_policy" "default" {
  name = var.name
  policy = var.policy
}

/*
  IAM ロールに IAM ポリシーを関連づける
*/
resource "aws_iam_role_policy_attachment" "default" {
  role = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

output "iam_role_arn" {
  value = aws_iam_role.default.arn
}

output "iam_role_name" {
  value = aws_iam_role.default.name
}
