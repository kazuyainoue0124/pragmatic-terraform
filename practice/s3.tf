# バケット名は全世界で一意でなければならない
# TODO: このままだとエラーになるため、 apply の実行前に別のバケット名へ変更する
resource "aws_s3_bucket" "private" {
  bucket = "inoue-private-pragmatic-terraform"
}

# バージョニングを有効にする
# バージョニングを有効にすると、バケット内のオブジェクトのバージョンをいつでも復元できる
resource "aws_s3_bucket_versioning" "private" {
  bucket = aws_s3_bucket.private.id
  versioning_configuration {
    status = "Enabled"
  }
}

# サーバー側の暗号化を有効にする
# バケット内のオブジェクトが保存時に暗号化され、参照時に復号化される
resource "aws_s3_bucket_server_side_encryption_configuration" "private" {
  bucket = aws_s3_bucket.private.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# バケットのパブリックアクセスをブロックする
# オブジェクトが予期せず公開されるのを防ぐ
# 理由がなければ下記のように全ての項目を true にする
resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.private.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "public" {
  bucket = "inoue-public-pragmatic-terraform"
}

resource "aws_s3_bucket_acl" "public" {
  bucket = aws_s3_bucket.public.id
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "public" {
  bucket = aws_s3_bucket.public.id

  cors_rule {
    allowed_origins = ["https://example.com"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "alb_log" {
  bucket = "inoue-alb-log-pragmatic-terraform"
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    id     = "log_expiration"
    status = "Enabled"

    expiration {
      days = 180
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    principals {
      type = "AWS"
      # AWS アカウント ID（書籍どおりの番号なので実際とは異なる）
      identifiers = ["582318560864"]
    }
  }
}
