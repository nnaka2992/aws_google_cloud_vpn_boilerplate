locals {
  tunnels = {
    0 = {
      tunnel_name                     = "${var.project_name}-network-aws-vpn-tunnel-0"
      peer_external_gateway_interface = 0
      shared_secret                   = aws_vpn_connection.main[0].tunnel1_preshared_key
      cgw_inside_ip_range             = format("%s/%s", aws_vpn_connection.main[0].tunnel1_cgw_inside_address, "30")
      peer_ip_address                 = aws_vpn_connection.main[0].tunnel1_vgw_inside_address
      interface_name                  = "${var.project_name}-network-router-interface-0"
      peer_name                       = "${var.project_name}-network-router-peer-0"
      vpn_gateway_interface           = 0
    },
    1 = {
      tunnel_name                     = "${var.project_name}-network-aws-vpn-tunnel-1"
      peer_external_gateway_interface = 1
      shared_secret                   = aws_vpn_connection.main[0].tunnel2_preshared_key
      cgw_inside_ip_range             = format("%s/%s", aws_vpn_connection.main[0].tunnel2_cgw_inside_address, "30")
      peer_ip_address                 = aws_vpn_connection.main[0].tunnel2_vgw_inside_address
      interface_name                  = "${var.project_name}-network-router-interface-1"
      peer_name                       = "${var.project_name}-network-router-peer-1"
      vpn_gateway_interface           = 0
    },
    2 = {
      tunnel_name                     = "${var.project_name}-network-aws-vpn-tunnel-2"
      peer_external_gateway_interface = 2
      shared_secret                   = aws_vpn_connection.main[1].tunnel1_preshared_key
      cgw_inside_ip_range             = format("%s/%s", aws_vpn_connection.main[1].tunnel1_cgw_inside_address, "30")
      peer_ip_address                 = aws_vpn_connection.main[1].tunnel1_vgw_inside_address
      interface_name                  = "${var.project_name}-network-router-interface-2"
      peer_name                       = "${var.project_name}-network-router-peer2"
      vpn_gateway_interface           = 1
    },
    3 = {
      tunnel_name                     = "${var.project_name}-network-aws-vpn-tunnel-3"
      peer_external_gateway_interface = 3
      shared_secret                   = aws_vpn_connection.main[1].tunnel2_preshared_key
      cgw_inside_ip_range             = format("%s/%s", aws_vpn_connection.main[1].tunnel2_cgw_inside_address, "30")
      peer_ip_address                 = aws_vpn_connection.main[1].tunnel2_vgw_inside_address
      interface_name                  = "${var.project_name}-network-router-interface-3"
      peer_name                       = "${var.project_name}-network-router-peer-3"
      vpn_gateway_interface           = 1
    },
  }
}

resource "google_compute_router" "main" {
  name    = "${var.project_name}-network-router"
  network = var.google_vpc_id
  bgp {
    asn               = var.google_bgp_asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    #    dynamic "advertised_ip_ranges" {
    #      for_each = toset(var.google_cloud_datastream_source_ranges)
    #      content {
    #        range = advertised_ip_ranges.value
    #      }
    #    }
  }
}

resource "google_compute_ha_vpn_gateway" "main" {
  name    = "${var.project_name}-network-vpn-gw"
  network = var.google_vpc_id
}

resource "google_compute_external_vpn_gateway" "main" {
  name            = "${var.project_name}-network-aws-vpn-gw"
  redundancy_type = "FOUR_IPS_REDUNDANCY"
  description     = "An externally managed VPN gateway"
  interface {
    id         = 0
    ip_address = aws_vpn_connection.main[0].tunnel1_address
  }
  interface {
    id         = 1
    ip_address = aws_vpn_connection.main[0].tunnel2_address
  }
  interface {
    id         = 2
    ip_address = aws_vpn_connection.main[1].tunnel1_address
  }
  interface {
    id         = 3
    ip_address = aws_vpn_connection.main[1].tunnel2_address
  }

  depends_on = [aws_vpn_connection.main]
}

resource "google_compute_vpn_tunnel" "main" {
  for_each = local.tunnels

  name                            = each.value.tunnel_name
  peer_external_gateway_interface = each.value.peer_external_gateway_interface
  shared_secret                   = each.value.shared_secret
  vpn_gateway_interface           = each.value.vpn_gateway_interface

  peer_external_gateway = google_compute_external_vpn_gateway.main.id
  ike_version           = 2
  router                = google_compute_router.main.id
  vpn_gateway           = google_compute_ha_vpn_gateway.main.id

  depends_on = [google_compute_router.main, google_compute_external_vpn_gateway.main]
}

resource "google_compute_router_interface" "main" {
  for_each = local.tunnels

  name       = each.value.interface_name
  ip_range   = each.value.cgw_inside_ip_range
  vpn_tunnel = each.value.tunnel_name

  router = google_compute_router.main.name

  depends_on = [google_compute_router.main, google_compute_vpn_tunnel.main]
}

resource "google_compute_router_peer" "main" {
  for_each = local.tunnels

  name            = each.value.peer_name
  peer_ip_address = each.value.peer_ip_address
  interface       = each.value.interface_name

  router                    = google_compute_router.main.name
  peer_asn                  = var.aws_bgp_asn
  advertised_route_priority = 1000

  depends_on = [
    google_compute_router.main,
    aws_vpn_connection.main,
    google_compute_router_interface.main,
  ]
}
