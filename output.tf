output "cloudfront_domain" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}

output "bucket_name" {
  value = aws_s3_bucket.static_web.id
}

#output "cf_domain" {
#  value = resource.static_web_stack.cloudfront_domain
#}

#output "cf_id" {
# value = resource.static_web_stack.cloudfront_id
#}

#output "bucket_name_another" {
#   value = aws.static_web_stack.bucket_name_another
#}

output "website_url" {
  value = "http://${aws_s3_bucket.my-static-website.bucket}.s3-website.us-east-1.amazonaws.com"
}