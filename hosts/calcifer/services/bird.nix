{
  # BGP with the Kubernetes nodes on VLAN 30 (Cilium's BGP control plane): they
  # announce the LoadBalancer VIPs and their pod /64s, calcifer routes them and
  # announces nothing back. Design and address plan: docs/network.md in flux-fleet.
  services.bird = {
    enable = true;
    config = ''
      router id 10.0.30.1;

      # Interface state, needed to resolve the directly connected next hops.
      protocol device {}

      # Write the accepted cluster routes to the kernel; learn nothing from it.
      protocol kernel {
        ipv4 { import none; export where source = RTS_BGP; };
      }
      protocol kernel {
        ipv6 { import none; export where source = RTS_BGP; };
      }

      # Only VIP host routes and the per-node pod /64s are accepted from the cluster.
      define CLUSTER_V4 = [ 10.0.40.0/24{32,32}, 10.0.50.0/24{32,32} ];
      define CLUSTER_V6 = [
        2606:6d00:ffb:6640::/64{128,128},
        2606:6d00:ffb:6650::/64{128,128},
        2606:6d00:ffb:6680::/60{64,64}
      ];

      template bgp cluster_peer {
        graceful restart on;
      }

      # Any node in cluster VLAN 30 (10.0.30.10, .11, ...) may peer: calcifer listens,
      # and each node that connects gets its own session (nodes_v4_1, ...).
      protocol bgp nodes_v4 from cluster_peer {
        local 10.0.30.1 as 65000;
        neighbor range 10.0.30.0/24 as 65030;
        dynamic name "nodes_v4_";
        ipv4 { import where net ~ CLUSTER_V4; export none; };
      }

      protocol bgp nodes_v6 from cluster_peer {
        local 2606:6d00:ffb:6630::1 as 65000;
        neighbor range 2606:6d00:ffb:6630::/64 as 65030;
        dynamic name "nodes_v6_";
        ipv6 { import where net ~ CLUSTER_V6; export none; };
      }
    '';
  };
}
