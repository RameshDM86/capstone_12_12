# S3 static website bucket


resource "aws_s3_bucket" "my-static-website" {
  bucket = "${var.bucket_name}-${var.bucket_env}" # give a unique bucket name
  force_destroy = true
  tags = {
    Name = "By ${var.bucket_name}"
    Environment = var.bucket_env
  }
}

resource "aws_s3_bucket_website_configuration" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket ACL access

resource "aws_s3_bucket_ownership_controls" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "my-static-website" {
  depends_on = [
    aws_s3_bucket_ownership_controls.my-static-website,
    aws_s3_bucket_public_access_block.my-static-website,
  ]

  bucket = aws_s3_bucket.my-static-website.id
  acl    = "public-read"
}

# s3 static website url


locals {
  origin_id = "s3origin"
}

resource "aws_s3_bucket" "static_web" {

  bucket = "${var.prefix}-s3-bkt"
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.static_web.id
  policy = data.aws_iam_policy_document.default.json
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  
  origin {
    domain_name              = aws_s3_bucket.static_web.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = local.origin_id
  }

  aliases = var.aliases

  enabled             = true
  comment             = "Static Website using S3 and Cloudfront OAC"
  default_root_object = "index.html"
  web_acl_id = var.web_acl_id

  default_cache_behavior {
    cache_policy_id        = data.aws_cloudfront_cache_policy.example.id
    allowed_methods        = var.allowed_methods
    cached_methods         = var.cached_methods
    target_origin_id       = local.origin_id
    viewer_protocol_policy = var.viewer_protocol_policy
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${aws_s3_bucket.static_web.id}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}