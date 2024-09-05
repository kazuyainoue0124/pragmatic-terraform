# バケット名は全世界で一意でなければならない
# TODO: このままだとエラーになるため、 apply の実行前に別のバケット名へ変更する
resource "aws_s3_bucket" "private" {
  bucket = "private-pragmatic-terraform"
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
