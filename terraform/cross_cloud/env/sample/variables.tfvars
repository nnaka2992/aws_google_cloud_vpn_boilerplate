project_name            = "aws-google-cloud-vpn-boilerplate"
preshared_key_secret_id = "preshared_key"
vpn_conn = {
  "0" = {
    tunnel1_inside_cidr = "169.254.30.0/30"
    tunnel2_inside_cidr = "169.254.31.0/30"
  }
  "1" = {
    tunnel1_inside_cidr = "169.254.32.0/30"
    tunnel2_inside_cidr = "169.254.33.0/30"
  }
}
google_project_id = "aws-google-cloud-vpn-boilerplate"
google_region     = "asia-northeast1"
google_vpc_id     = "projects/aws-google-cloud-vpn-boilerplate/global/networks/aws-google-cloud-vpn-boilerplate"
google_bgp_asn    = 65534

aws_region  = "ap-northeast-1"
aws_bgp_asn = 64512
aws_vpc = {
  main = {
    vpc_id = "vpc-007e70425e4a8890d"
    vpc_id = "vpc-1234567890abcdef0"
    subnet_ids = [
      "subnet-0123456789abcdef0",
      "subnet-1123456789abcdef0",
      "subnet-2123456789abcdef0",
    ]
    ip_cidr_range = ["172.32.0.0/16"]
  }
}
