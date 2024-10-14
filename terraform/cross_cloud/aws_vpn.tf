locals {
  vpn_connections = { for i, v in var.vpn_conn :
    i => {
      name                  = "${var.project_name}-vpn-connection-${i}"
      customer_gateway_id   = aws_customer_gateway.main[i].id
      type                  = aws_customer_gateway.main[i].type
      tunnel1_inside_cidr   = v.tunnel1_inside_cidr
      tunnel2_inside_cidr   = v.tunnel2_inside_cidr
      tunnel1_preshared_key = local.preshared_key
      tunnel2_preshared_key = local.preshared_key
    }
  }
  customer_gws = {
    0 = {
      name       = "${var.project_name}-cgw-0"
      bgp_asn    = var.google_bgp_asn
      ip_address = google_compute_ha_vpn_gateway.main.vpn_interfaces[0].ip_address
      type       = "ipsec.1"
    }
    1 = {
      name       = "${var.project_name}-cgw-1"
      bgp_asn    = var.google_bgp_asn
      ip_address = google_compute_ha_vpn_gateway.main.vpn_interfaces[1].ip_address
      type       = "ipsec.1"
    }
  }
}

resource "aws_customer_gateway" "main" {
  for_each = local.customer_gws

  bgp_asn    = each.value.bgp_asn
  ip_address = each.value.ip_address
  type       = each.value.type

  tags = {
    Name = each.value.name
  }
  depends_on = [google_compute_ha_vpn_gateway.main]
}

resource "aws_ec2_transit_gateway" "main" {
  description                     = "connection between GCP and AWS"
  amazon_side_asn                 = var.aws_bgp_asn
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  vpn_ecmp_support                = "enable"
  dns_support                     = "enable"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  for_each           = var.aws_vpc
  subnet_ids         = each.value.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = each.value.vpc_id
  depends_on         = [aws_ec2_transit_gateway.main]
}

resource "aws_vpn_connection" "main" {
  for_each           = local.vpn_connections
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  customer_gateway_id                     = each.value.customer_gateway_id
  type                                    = each.value.type
  tunnel1_inside_cidr                     = each.value.tunnel1_inside_cidr
  tunnel1_preshared_key                   = each.value.tunnel1_preshared_key
  tunnel1_enable_tunnel_lifecycle_control = true
  tunnel2_inside_cidr                     = each.value.tunnel2_inside_cidr
  tunnel2_preshared_key                   = each.value.tunnel2_preshared_key
  tunnel2_enable_tunnel_lifecycle_control = true

  depends_on = [aws_ec2_transit_gateway.main, aws_customer_gateway.main]
}
