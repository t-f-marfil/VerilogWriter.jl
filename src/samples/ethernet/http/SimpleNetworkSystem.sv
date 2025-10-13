module SimpleNetworkSystem (
    output logic ufp_ready,
    input ufp_valid,
    input ufp_last,
    input [31:0] ufp_data,
    output logic debug_valid_srv,
    output logic [71:0] debug_data_srv,
    input start,
    output logic dfp_awvalid,
    output logic [31:0] dfp_wdata,
    output logic [7:0] dfp_awlen,
    output logic dfp_wlast,
    output logic dfp_wvalid,
    input dfp_awready,
    input dfp_wready,
    input CLK,
    input RST
);
    logic ufp_ready_icmpEchoSystem_snsys_1;
    logic CLK_dummyio_snsys_1;
    logic ufp_ready_ipv4BufferSelector_snsys_1;
    logic ufp_valid_ipv4BufferSelector_snsys_1;
    logic dfp_last_icmp_ipv4BufferSelector_snsys_1;
    logic [7:0] ufp_awlen_3_TxBufferSelector3_snsys_1;
    logic RST_dummyio_snsys_1;
    logic CLK_TcpServerSystem_snsys_1;
    logic rx_valid_SampleHttpResponseGenerator_snsys_1;
    logic dfp_rx_data_valid_TcpServerSystem_snsys_1;
    logic dfp_wready_TxBufferSelector3_snsys_1;
    logic ufp_awready_2_TxBufferSelector3_snsys_1;
    logic [31:0] ufp_dest_addr_TcpServerSystem_snsys_1;
    logic wready_fifoOnBram_icmp_snsys_1;
    logic [71:0] debug_data_TcpServerSystem_snsys_1;
    logic CLK_SampleHttpResponseGenerator_snsys_1;
    logic dfp_valid_tcp_ipv4BufferSelector_snsys_1;
    logic dummy1_5_dummyio_snsys_1;
    logic [47:0] ufp_hwaddr_TcpServerSystem_snsys_1;
    logic [7:0] dfp_awlen_icmpEchoSystem_snsys_1;
    logic [31:0] ufp_tx_data_TcpServerSystem_snsys_1;
    logic dfp_awready_TcpServerSystem_snsys_1;
    logic [31:0] ufp_wdata_3_TxBufferSelector3_snsys_1;
    logic [31:0] source_address_ipv4BufferSelector_snsys_1;
    logic [71:0] debug_data_rcvparse_TcpServerSystem_snsys_1;
    logic RST_TcpServerSystem_snsys_1;
    logic [31:0] dfp_data_ipv4_EtherRecvBufferSelector_snsys_1;
    logic ufp_last_icmpEchoSystem_snsys_1;
    logic [71:0] dummy72_2_dummyio_snsys_1;
    logic ufp_valid_icmpEchoSystem_snsys_1;
    logic rlast_fifoOnBram_icmp_snsys_1;
    logic [71:0] dummy72_5_dummyio_snsys_1;
    logic [71:0] dummy72_6_dummyio_snsys_1;
    logic [7:0] ufp_awlen_2_TxBufferSelector3_snsys_1;
    logic [7:0] dfp_awlen_linkLocalIpClaimerSystem_snsys_1;
    logic [31:0] ufp_data_TcpServerSystem_snsys_1;
    logic ufp_awvalid_1_TxBufferSelector3_snsys_1;
    logic [31:0] ufp_src_addr_TcpServerSystem_snsys_1;
    logic [47:0] ether_dest_addr_out_ipv4BufferSelector_snsys_1;
    logic dfp_wvalid_TcpServerSystem_snsys_1;
    logic ufp_awready_1_TxBufferSelector3_snsys_1;
    logic wready_fifoOnBram_tcp_snsys_1;
    logic CLK_EtherRecvBufferSelector_snsys_1;
    logic [7:0] dfp_awlen_TxBufferSelector3_snsys_1;
    logic dfp_wvalid_icmpEchoSystem_snsys_1;
    logic ufp_wready_3_TxBufferSelector3_snsys_1;
    logic ufp_wlast_1_TxBufferSelector3_snsys_1;
    logic [15:0] ufp_total_length_data_TcpServerSystem_snsys_1;
    logic dfp_wvalid_linkLocalIpClaimerSystem_snsys_1;
    logic ufp_last_TcpServerSystem_snsys_1;
    logic [31:0] rdata_fifoOnBram_icmp_snsys_1;
    logic ufp_last_EtherRecvBufferSelector_snsys_1;
    logic [31:0] dfp_wdata_TcpServerSystem_snsys_1;
    logic rx_ready_SampleHttpResponseGenerator_snsys_1;
    logic [31:0] ip_addr_linkLocalIpClaimerSystem_snsys_1;
    logic dfp_awvalid_linkLocalIpClaimerSystem_snsys_1;
    logic RST_EtherRecvBufferSelector_snsys_1;
    logic rready_fifoOnBram_tcp_snsys_1;
    logic dummy1_4_dummyio_snsys_1;
    logic dfp_last_arp_EtherRecvBufferSelector_snsys_1;
    logic [31:0] tx_data_SampleHttpResponseGenerator_snsys_1;
    logic CLK_icmpEchoSystem_snsys_1;
    logic CLK_fifoOnBram_icmp_snsys_1;
    logic ufp_ready_EtherRecvBufferSelector_snsys_1;
    logic [1:0] rx_strb_SampleHttpResponseGenerator_snsys_1;
    logic ufp_tx_data_ready_TcpServerSystem_snsys_1;
    logic [47:0] ether_src_addr_in_ipv4BufferSelector_snsys_1;
    logic [31:0] wdata_fifoOnBram_icmp_snsys_1;
    logic [31:0] ufp_wdata_linkLocalIpClaimerSystem_snsys_1;
    logic ufp_wvalid_2_TxBufferSelector3_snsys_1;
    logic RST_TxBufferSelector3_snsys_1;
    logic [31:0] dfp_data_icmp_ipv4BufferSelector_snsys_1;
    logic CLK_ipv4BufferSelector_snsys_1;
    logic dfp_valid_ipv4_EtherRecvBufferSelector_snsys_1;
    logic dfp_last_tcp_ipv4BufferSelector_snsys_1;
    logic [71:0] debug_data_ipv4BufferSelector_snsys_1;
    logic debug_valid_icmpEchoSystem_snsys_1;
    logic tx_last_SampleHttpResponseGenerator_snsys_1;
    logic ufp_last_ipv4BufferSelector_snsys_1;
    logic dfp_wlast_TcpServerSystem_snsys_1;
    logic [7:0] ufp_awlen_1_TxBufferSelector3_snsys_1;
    logic ufp_wready_linkLocalIpClaimerSystem_snsys_1;
    logic ufp_wvalid_1_TxBufferSelector3_snsys_1;
    logic rlast_fifoOnBram_tcp_snsys_1;
    logic [31:0] dfp_rx_data_TcpServerSystem_snsys_1;
    logic ufp_tx_data_last_TcpServerSystem_snsys_1;
    logic [15:0] ufp_tx_checksum_data_only_TcpServerSystem_snsys_1;
    logic dfp_awready_TxBufferSelector3_snsys_1;
    logic debug_valid_rcvparse_TcpServerSystem_snsys_1;
    logic [15:0] ufp_total_length_data_icmpEchoSystem_snsys_1;
    logic [47:0] rx_dest_hwaddr_icmpEchoSystem_snsys_1;
    logic tx_ready_SampleHttpResponseGenerator_snsys_1;
    logic [31:0] ufp_data_icmpEchoSystem_snsys_1;
    logic dfp_valid_icmp_ipv4BufferSelector_snsys_1;
    logic dfp_awready_linkLocalIpClaimerSystem_snsys_1;
    logic [31:0] ufp_dest_addr_icmpEchoSystem_snsys_1;
    logic ufp_awvalid_3_TxBufferSelector3_snsys_1;
    logic [31:0] ufp_data_ipv4BufferSelector_snsys_1;
    logic CLK_fifoOnBram_tcp_snsys_1;
    logic ufp_hwaddr_valid_TcpServerSystem_snsys_1;
    logic [31:0] dfp_data_arp_EtherRecvBufferSelector_snsys_1;
    logic [15:0] ufp_tx_total_length_data_only_TcpServerSystem_snsys_1;
    logic tx_valid_SampleHttpResponseGenerator_snsys_1;
    logic [71:0] dummy72_3_dummyio_snsys_1;
    logic [47:0] rx_src_hwaddr_icmpEchoSystem_snsys_1;
    logic [47:0] src_addr_EtherRecvBufferSelector_snsys_1;
    logic CLK_TxBufferSelector3_snsys_1;
    logic [1:0] dfp_rx_data_strb_TcpServerSystem_snsys_1;
    logic rvalid_fifoOnBram_tcp_snsys_1;
    logic [47:0] ether_src_addr_out_ipv4BufferSelector_snsys_1;
    logic ufp_wlast_3_TxBufferSelector3_snsys_1;
    logic ufp_awready_3_TxBufferSelector3_snsys_1;
    logic rready_fifoOnBram_icmp_snsys_1;
    logic ufp_wlast_2_TxBufferSelector3_snsys_1;
    logic [71:0] dummy72_1_dummyio_snsys_1;
    logic dfp_wlast_TxBufferSelector3_snsys_1;
    logic ufp_wvalid_linkLocalIpClaimerSystem_snsys_1;
    logic [71:0] debug_data_EtherRecvBufferSelector_snsys_1;
    logic [15:0] tx_total_length_SampleHttpResponseGenerator_snsys_1;
    logic [15:0] tx_checksum_SampleHttpResponseGenerator_snsys_1;
    logic debug_valid_EtherRecvBufferSelector_snsys_1;
    logic dfp_awvalid_TcpServerSystem_snsys_1;
    logic [31:0] dfp_wdata_TxBufferSelector3_snsys_1;
    logic [71:0] debug_data_srv_TcpServerSystem_snsys_1;
    logic ufp_valid_EtherRecvBufferSelector_snsys_1;
    logic ip_addr_valid_linkLocalIpClaimerSystem_snsys_1;
    logic [31:0] rx_data_SampleHttpResponseGenerator_snsys_1;
    logic [31:0] ufp_wdata_2_TxBufferSelector3_snsys_1;
    logic ufp_wready_1_TxBufferSelector3_snsys_1;
    logic dfp_wready_TcpServerSystem_snsys_1;
    logic CLK_linkLocalIpClaimerSystem_snsys_1;
    logic dummy1_1_dummyio_snsys_1;
    logic dummy1_2_dummyio_snsys_1;
    logic [71:0] debug_data_TxBufferSelector3_snsys_1;
    logic [31:0] destination_address_ipv4BufferSelector_snsys_1;
    logic RST_SampleHttpResponseGenerator_snsys_1;
    logic [31:0] wdata_fifoOnBram_tcp_snsys_1;
    logic dfp_valid_arp_EtherRecvBufferSelector_snsys_1;
    logic dfp_rx_data_ready_TcpServerSystem_snsys_1;
    logic dfp_ready_arp_EtherRecvBufferSelector_snsys_1;
    logic [31:0] dfp_data_tcp_ipv4BufferSelector_snsys_1;
    logic dfp_awvalid_icmpEchoSystem_snsys_1;
    logic RST_icmpEchoSystem_snsys_1;
    logic RST_fifoOnBram_icmp_snsys_1;
    logic dfp_ready_tcp_ipv4BufferSelector_snsys_1;
    logic ufp_awvalid_2_TxBufferSelector3_snsys_1;
    logic dfp_last_ipv4_EtherRecvBufferSelector_snsys_1;
    logic debug_valid_TcpServerSystem_snsys_1;
    logic dummy1_6_dummyio_snsys_1;
    logic rvalid_fifoOnBram_icmp_snsys_1;
    logic [47:0] dest_addr_EtherRecvBufferSelector_snsys_1;
    logic wlast_fifoOnBram_tcp_snsys_1;
    logic [15:0] total_length_data_ipv4BufferSelector_snsys_1;
    logic start_linkLocalIpClaimerSystem_snsys_1;
    logic wvalid_fifoOnBram_icmp_snsys_1;
    logic [31:0] ufp_wdata_1_TxBufferSelector3_snsys_1;
    logic dfp_awvalid_TxBufferSelector3_snsys_1;
    logic [31:0] config_src_addr_TcpServerSystem_snsys_1;
    logic RST_fifoOnBram_tcp_snsys_1;
    logic ufp_ready_TcpServerSystem_snsys_1;
    logic dummy1_3_dummyio_snsys_1;
    logic dfp_wvalid_TxBufferSelector3_snsys_1;
    logic [47:0] ether_dest_addr_in_ipv4BufferSelector_snsys_1;
    logic wlast_fifoOnBram_icmp_snsys_1;
    logic dfp_wready_linkLocalIpClaimerSystem_snsys_1;
    logic dfp_ready_icmp_ipv4BufferSelector_snsys_1;
    logic dfp_ready_ipv4_EtherRecvBufferSelector_snsys_1;
    logic [31:0] rdata_fifoOnBram_tcp_snsys_1;
    logic RST_linkLocalIpClaimerSystem_snsys_1;
    logic [71:0] dummy72_4_dummyio_snsys_1;
    logic [31:0] dfp_wdata_icmpEchoSystem_snsys_1;
    logic dfp_wlast_linkLocalIpClaimerSystem_snsys_1;
    logic wvalid_fifoOnBram_tcp_snsys_1;
    logic ufp_wlast_linkLocalIpClaimerSystem_snsys_1;
    logic debug_valid_TxBufferSelector3_snsys_1;
    logic dfp_awready_icmpEchoSystem_snsys_1;
    logic RST_ipv4BufferSelector_snsys_1;
    logic rx_icmp_last_icmpEchoSystem_snsys_1;
    logic debug_valid_srv_TcpServerSystem_snsys_1;
    logic [31:0] dfp_wdata_linkLocalIpClaimerSystem_snsys_1;
    logic debug_valid_ipv4BufferSelector_snsys_1;
    logic ufp_valid_TcpServerSystem_snsys_1;
    logic [31:0] configured_ip_addr_icmpEchoSystem_snsys_1;
    logic ip_addr_configured_icmpEchoSystem_snsys_1;
    logic [31:0] ufp_src_addr_icmpEchoSystem_snsys_1;
    logic [71:0] debug_data_icmpEchoSystem_snsys_1;
    logic ufp_wvalid_3_TxBufferSelector3_snsys_1;
    logic ufp_wready_2_TxBufferSelector3_snsys_1;
    logic dfp_wready_icmpEchoSystem_snsys_1;
    logic [31:0] ufp_data_EtherRecvBufferSelector_snsys_1;
    logic [7:0] dfp_awlen_TcpServerSystem_snsys_1;
    logic ufp_tx_data_valid_TcpServerSystem_snsys_1;
    logic dfp_wlast_icmpEchoSystem_snsys_1;
    logic config_valid_TcpServerSystem_snsys_1;

    ipv4BufferSelector_snsys_1 ipv4BufferSelector_snsys_1_inst (
        .CLK(CLK_ipv4BufferSelector_snsys_1),
        .RST(RST_ipv4BufferSelector_snsys_1),
        .ufp_valid(ufp_valid_ipv4BufferSelector_snsys_1),
        .ufp_last(ufp_last_ipv4BufferSelector_snsys_1),
        .ufp_data(ufp_data_ipv4BufferSelector_snsys_1),
        .ufp_ready(ufp_ready_ipv4BufferSelector_snsys_1),
        .debug_valid(debug_valid_ipv4BufferSelector_snsys_1),
        .debug_data(debug_data_ipv4BufferSelector_snsys_1),
        .source_address(source_address_ipv4BufferSelector_snsys_1),
        .destination_address(destination_address_ipv4BufferSelector_snsys_1),
        .total_length_data(total_length_data_ipv4BufferSelector_snsys_1),
        .ether_src_addr_in(ether_src_addr_in_ipv4BufferSelector_snsys_1),
        .ether_dest_addr_in(ether_dest_addr_in_ipv4BufferSelector_snsys_1),
        .ether_src_addr_out(ether_src_addr_out_ipv4BufferSelector_snsys_1),
        .ether_dest_addr_out(ether_dest_addr_out_ipv4BufferSelector_snsys_1),
        .dfp_ready_icmp(dfp_ready_icmp_ipv4BufferSelector_snsys_1),
        .dfp_valid_icmp(dfp_valid_icmp_ipv4BufferSelector_snsys_1),
        .dfp_data_icmp(dfp_data_icmp_ipv4BufferSelector_snsys_1),
        .dfp_last_icmp(dfp_last_icmp_ipv4BufferSelector_snsys_1),
        .dfp_ready_tcp(dfp_ready_tcp_ipv4BufferSelector_snsys_1),
        .dfp_valid_tcp(dfp_valid_tcp_ipv4BufferSelector_snsys_1),
        .dfp_data_tcp(dfp_data_tcp_ipv4BufferSelector_snsys_1),
        .dfp_last_tcp(dfp_last_tcp_ipv4BufferSelector_snsys_1)
    );
    fifoOnBram_tcp_snsys_1 fifoOnBram_tcp_snsys_1_inst (
        .CLK(CLK_fifoOnBram_tcp_snsys_1),
        .RST(RST_fifoOnBram_tcp_snsys_1),
        .wvalid(wvalid_fifoOnBram_tcp_snsys_1),
        .wlast(wlast_fifoOnBram_tcp_snsys_1),
        .wready(wready_fifoOnBram_tcp_snsys_1),
        .wdata(wdata_fifoOnBram_tcp_snsys_1),
        .rvalid(rvalid_fifoOnBram_tcp_snsys_1),
        .rlast(rlast_fifoOnBram_tcp_snsys_1),
        .rready(rready_fifoOnBram_tcp_snsys_1),
        .rdata(rdata_fifoOnBram_tcp_snsys_1)
    );
    EtherRecvBufferSelector_snsys_1 EtherRecvBufferSelector_snsys_1_inst (
        .CLK(CLK_EtherRecvBufferSelector_snsys_1),
        .RST(RST_EtherRecvBufferSelector_snsys_1),
        .ufp_valid(ufp_valid_EtherRecvBufferSelector_snsys_1),
        .ufp_last(ufp_last_EtherRecvBufferSelector_snsys_1),
        .ufp_ready(ufp_ready_EtherRecvBufferSelector_snsys_1),
        .ufp_data(ufp_data_EtherRecvBufferSelector_snsys_1),
        .dest_addr(dest_addr_EtherRecvBufferSelector_snsys_1),
        .src_addr(src_addr_EtherRecvBufferSelector_snsys_1),
        .debug_valid(debug_valid_EtherRecvBufferSelector_snsys_1),
        .debug_data(debug_data_EtherRecvBufferSelector_snsys_1),
        .dfp_ready_arp(dfp_ready_arp_EtherRecvBufferSelector_snsys_1),
        .dfp_valid_arp(dfp_valid_arp_EtherRecvBufferSelector_snsys_1),
        .dfp_data_arp(dfp_data_arp_EtherRecvBufferSelector_snsys_1),
        .dfp_last_arp(dfp_last_arp_EtherRecvBufferSelector_snsys_1),
        .dfp_ready_ipv4(dfp_ready_ipv4_EtherRecvBufferSelector_snsys_1),
        .dfp_valid_ipv4(dfp_valid_ipv4_EtherRecvBufferSelector_snsys_1),
        .dfp_data_ipv4(dfp_data_ipv4_EtherRecvBufferSelector_snsys_1),
        .dfp_last_ipv4(dfp_last_ipv4_EtherRecvBufferSelector_snsys_1)
    );
    icmpEchoSystem_snsys_1 icmpEchoSystem_snsys_1_inst (
        .ufp_dest_addr(ufp_dest_addr_icmpEchoSystem_snsys_1),
        .ufp_ready(ufp_ready_icmpEchoSystem_snsys_1),
        .ufp_valid(ufp_valid_icmpEchoSystem_snsys_1),
        .ufp_last(ufp_last_icmpEchoSystem_snsys_1),
        .ufp_total_length_data(ufp_total_length_data_icmpEchoSystem_snsys_1),
        .ufp_src_addr(ufp_src_addr_icmpEchoSystem_snsys_1),
        .ufp_data(ufp_data_icmpEchoSystem_snsys_1),
        .dfp_awvalid(dfp_awvalid_icmpEchoSystem_snsys_1),
        .dfp_wdata(dfp_wdata_icmpEchoSystem_snsys_1),
        .dfp_awlen(dfp_awlen_icmpEchoSystem_snsys_1),
        .dfp_wlast(dfp_wlast_icmpEchoSystem_snsys_1),
        .dfp_wvalid(dfp_wvalid_icmpEchoSystem_snsys_1),
        .dfp_awready(dfp_awready_icmpEchoSystem_snsys_1),
        .dfp_wready(dfp_wready_icmpEchoSystem_snsys_1),
        .debug_data(debug_data_icmpEchoSystem_snsys_1),
        .debug_valid(debug_valid_icmpEchoSystem_snsys_1),
        .ip_addr_configured(ip_addr_configured_icmpEchoSystem_snsys_1),
        .rx_src_hwaddr(rx_src_hwaddr_icmpEchoSystem_snsys_1),
        .rx_dest_hwaddr(rx_dest_hwaddr_icmpEchoSystem_snsys_1),
        .configured_ip_addr(configured_ip_addr_icmpEchoSystem_snsys_1),
        .rx_icmp_last(rx_icmp_last_icmpEchoSystem_snsys_1),
        .CLK(CLK_icmpEchoSystem_snsys_1),
        .RST(RST_icmpEchoSystem_snsys_1)
    );
    TcpServerSystem_snsys_1 TcpServerSystem_snsys_1_inst (
        .ufp_hwaddr_valid(ufp_hwaddr_valid_TcpServerSystem_snsys_1),
        .ufp_hwaddr(ufp_hwaddr_TcpServerSystem_snsys_1),
        .ufp_tx_data(ufp_tx_data_TcpServerSystem_snsys_1),
        .ufp_tx_total_length_data_only(ufp_tx_total_length_data_only_TcpServerSystem_snsys_1),
        .config_src_addr(config_src_addr_TcpServerSystem_snsys_1),
        .dfp_rx_data_ready(dfp_rx_data_ready_TcpServerSystem_snsys_1),
        .ufp_tx_data_ready(ufp_tx_data_ready_TcpServerSystem_snsys_1),
        .debug_valid_srv(debug_valid_srv_TcpServerSystem_snsys_1),
        .config_valid(config_valid_TcpServerSystem_snsys_1),
        .debug_data_srv(debug_data_srv_TcpServerSystem_snsys_1),
        .dfp_rx_data_valid(dfp_rx_data_valid_TcpServerSystem_snsys_1),
        .ufp_tx_data_valid(ufp_tx_data_valid_TcpServerSystem_snsys_1),
        .ufp_tx_data_last(ufp_tx_data_last_TcpServerSystem_snsys_1),
        .dfp_rx_data_strb(dfp_rx_data_strb_TcpServerSystem_snsys_1),
        .ufp_tx_checksum_data_only(ufp_tx_checksum_data_only_TcpServerSystem_snsys_1),
        .dfp_rx_data(dfp_rx_data_TcpServerSystem_snsys_1),
        .debug_data(debug_data_TcpServerSystem_snsys_1),
        .dfp_awvalid(dfp_awvalid_TcpServerSystem_snsys_1),
        .debug_valid(debug_valid_TcpServerSystem_snsys_1),
        .dfp_wdata(dfp_wdata_TcpServerSystem_snsys_1),
        .dfp_awlen(dfp_awlen_TcpServerSystem_snsys_1),
        .dfp_wlast(dfp_wlast_TcpServerSystem_snsys_1),
        .dfp_wvalid(dfp_wvalid_TcpServerSystem_snsys_1),
        .dfp_awready(dfp_awready_TcpServerSystem_snsys_1),
        .dfp_wready(dfp_wready_TcpServerSystem_snsys_1),
        .ufp_dest_addr(ufp_dest_addr_TcpServerSystem_snsys_1),
        .debug_valid_rcvparse(debug_valid_rcvparse_TcpServerSystem_snsys_1),
        .ufp_ready(ufp_ready_TcpServerSystem_snsys_1),
        .ufp_valid(ufp_valid_TcpServerSystem_snsys_1),
        .ufp_last(ufp_last_TcpServerSystem_snsys_1),
        .ufp_total_length_data(ufp_total_length_data_TcpServerSystem_snsys_1),
        .ufp_src_addr(ufp_src_addr_TcpServerSystem_snsys_1),
        .ufp_data(ufp_data_TcpServerSystem_snsys_1),
        .debug_data_rcvparse(debug_data_rcvparse_TcpServerSystem_snsys_1),
        .CLK(CLK_TcpServerSystem_snsys_1),
        .RST(RST_TcpServerSystem_snsys_1)
    );
    linkLocalIpClaimerSystem_snsys_1 linkLocalIpClaimerSystem_snsys_1_inst (
        .ufp_wready(ufp_wready_linkLocalIpClaimerSystem_snsys_1),
        .ufp_wvalid(ufp_wvalid_linkLocalIpClaimerSystem_snsys_1),
        .ufp_wdata(ufp_wdata_linkLocalIpClaimerSystem_snsys_1),
        .ufp_wlast(ufp_wlast_linkLocalIpClaimerSystem_snsys_1),
        .dfp_awvalid(dfp_awvalid_linkLocalIpClaimerSystem_snsys_1),
        .dfp_wdata(dfp_wdata_linkLocalIpClaimerSystem_snsys_1),
        .dfp_awlen(dfp_awlen_linkLocalIpClaimerSystem_snsys_1),
        .dfp_wlast(dfp_wlast_linkLocalIpClaimerSystem_snsys_1),
        .dfp_wvalid(dfp_wvalid_linkLocalIpClaimerSystem_snsys_1),
        .dfp_awready(dfp_awready_linkLocalIpClaimerSystem_snsys_1),
        .dfp_wready(dfp_wready_linkLocalIpClaimerSystem_snsys_1),
        .start(start_linkLocalIpClaimerSystem_snsys_1),
        .ip_addr(ip_addr_linkLocalIpClaimerSystem_snsys_1),
        .ip_addr_valid(ip_addr_valid_linkLocalIpClaimerSystem_snsys_1),
        .CLK(CLK_linkLocalIpClaimerSystem_snsys_1),
        .RST(RST_linkLocalIpClaimerSystem_snsys_1)
    );
    SampleHttpResponseGenerator_snsys_1 SampleHttpResponseGenerator_snsys_1_inst (
        .CLK(CLK_SampleHttpResponseGenerator_snsys_1),
        .RST(RST_SampleHttpResponseGenerator_snsys_1),
        .rx_valid(rx_valid_SampleHttpResponseGenerator_snsys_1),
        .rx_ready(rx_ready_SampleHttpResponseGenerator_snsys_1),
        .rx_data(rx_data_SampleHttpResponseGenerator_snsys_1),
        .rx_strb(rx_strb_SampleHttpResponseGenerator_snsys_1),
        .tx_valid(tx_valid_SampleHttpResponseGenerator_snsys_1),
        .tx_last(tx_last_SampleHttpResponseGenerator_snsys_1),
        .tx_ready(tx_ready_SampleHttpResponseGenerator_snsys_1),
        .tx_data(tx_data_SampleHttpResponseGenerator_snsys_1),
        .tx_checksum(tx_checksum_SampleHttpResponseGenerator_snsys_1),
        .tx_total_length(tx_total_length_SampleHttpResponseGenerator_snsys_1)
    );
    fifoOnBram_icmp_snsys_1 fifoOnBram_icmp_snsys_1_inst (
        .CLK(CLK_fifoOnBram_icmp_snsys_1),
        .RST(RST_fifoOnBram_icmp_snsys_1),
        .wvalid(wvalid_fifoOnBram_icmp_snsys_1),
        .wlast(wlast_fifoOnBram_icmp_snsys_1),
        .wready(wready_fifoOnBram_icmp_snsys_1),
        .wdata(wdata_fifoOnBram_icmp_snsys_1),
        .rvalid(rvalid_fifoOnBram_icmp_snsys_1),
        .rlast(rlast_fifoOnBram_icmp_snsys_1),
        .rready(rready_fifoOnBram_icmp_snsys_1),
        .rdata(rdata_fifoOnBram_icmp_snsys_1)
    );
    dummyio_snsys_1 dummyio_snsys_1_inst (
        .dummy1_1(dummy1_1_dummyio_snsys_1),
        .dummy1_2(dummy1_2_dummyio_snsys_1),
        .dummy1_3(dummy1_3_dummyio_snsys_1),
        .dummy1_4(dummy1_4_dummyio_snsys_1),
        .dummy1_5(dummy1_5_dummyio_snsys_1),
        .dummy1_6(dummy1_6_dummyio_snsys_1),
        .dummy72_1(dummy72_1_dummyio_snsys_1),
        .dummy72_2(dummy72_2_dummyio_snsys_1),
        .dummy72_3(dummy72_3_dummyio_snsys_1),
        .dummy72_4(dummy72_4_dummyio_snsys_1),
        .dummy72_5(dummy72_5_dummyio_snsys_1),
        .dummy72_6(dummy72_6_dummyio_snsys_1),
        .CLK(CLK_dummyio_snsys_1),
        .RST(RST_dummyio_snsys_1)
    );
    TxBufferSelector3_snsys_1 TxBufferSelector3_snsys_1_inst (
        .CLK(CLK_TxBufferSelector3_snsys_1),
        .RST(RST_TxBufferSelector3_snsys_1),
        .debug_valid(debug_valid_TxBufferSelector3_snsys_1),
        .debug_data(debug_data_TxBufferSelector3_snsys_1),
        .ufp_wready_1(ufp_wready_1_TxBufferSelector3_snsys_1),
        .ufp_wvalid_1(ufp_wvalid_1_TxBufferSelector3_snsys_1),
        .ufp_wdata_1(ufp_wdata_1_TxBufferSelector3_snsys_1),
        .ufp_wlast_1(ufp_wlast_1_TxBufferSelector3_snsys_1),
        .ufp_awlen_1(ufp_awlen_1_TxBufferSelector3_snsys_1),
        .ufp_awvalid_1(ufp_awvalid_1_TxBufferSelector3_snsys_1),
        .ufp_awready_1(ufp_awready_1_TxBufferSelector3_snsys_1),
        .ufp_wready_2(ufp_wready_2_TxBufferSelector3_snsys_1),
        .ufp_wvalid_2(ufp_wvalid_2_TxBufferSelector3_snsys_1),
        .ufp_wdata_2(ufp_wdata_2_TxBufferSelector3_snsys_1),
        .ufp_wlast_2(ufp_wlast_2_TxBufferSelector3_snsys_1),
        .ufp_awlen_2(ufp_awlen_2_TxBufferSelector3_snsys_1),
        .ufp_awvalid_2(ufp_awvalid_2_TxBufferSelector3_snsys_1),
        .ufp_awready_2(ufp_awready_2_TxBufferSelector3_snsys_1),
        .ufp_wready_3(ufp_wready_3_TxBufferSelector3_snsys_1),
        .ufp_wvalid_3(ufp_wvalid_3_TxBufferSelector3_snsys_1),
        .ufp_wdata_3(ufp_wdata_3_TxBufferSelector3_snsys_1),
        .ufp_wlast_3(ufp_wlast_3_TxBufferSelector3_snsys_1),
        .ufp_awlen_3(ufp_awlen_3_TxBufferSelector3_snsys_1),
        .ufp_awvalid_3(ufp_awvalid_3_TxBufferSelector3_snsys_1),
        .ufp_awready_3(ufp_awready_3_TxBufferSelector3_snsys_1),
        .dfp_wready(dfp_wready_TxBufferSelector3_snsys_1),
        .dfp_wvalid(dfp_wvalid_TxBufferSelector3_snsys_1),
        .dfp_wdata(dfp_wdata_TxBufferSelector3_snsys_1),
        .dfp_wlast(dfp_wlast_TxBufferSelector3_snsys_1),
        .dfp_awlen(dfp_awlen_TxBufferSelector3_snsys_1),
        .dfp_awvalid(dfp_awvalid_TxBufferSelector3_snsys_1),
        .dfp_awready(dfp_awready_TxBufferSelector3_snsys_1)
    );
    always_comb begin
        wvalid_fifoOnBram_tcp_snsys_1 = dfp_valid_tcp_ipv4BufferSelector_snsys_1;
        wdata_fifoOnBram_tcp_snsys_1 = dfp_data_tcp_ipv4BufferSelector_snsys_1;
        wlast_fifoOnBram_tcp_snsys_1 = dfp_last_tcp_ipv4BufferSelector_snsys_1;
        dfp_ready_tcp_ipv4BufferSelector_snsys_1 = wready_fifoOnBram_tcp_snsys_1;
        ether_dest_addr_in_ipv4BufferSelector_snsys_1 = dest_addr_EtherRecvBufferSelector_snsys_1;
        ether_src_addr_in_ipv4BufferSelector_snsys_1 = src_addr_EtherRecvBufferSelector_snsys_1;
        ufp_valid_ipv4BufferSelector_snsys_1 = dfp_valid_ipv4_EtherRecvBufferSelector_snsys_1;
        ufp_data_ipv4BufferSelector_snsys_1 = dfp_data_ipv4_EtherRecvBufferSelector_snsys_1;
        ufp_last_ipv4BufferSelector_snsys_1 = dfp_last_ipv4_EtherRecvBufferSelector_snsys_1;
        dfp_ready_arp_EtherRecvBufferSelector_snsys_1 = ufp_wready_linkLocalIpClaimerSystem_snsys_1;
        ufp_valid_icmpEchoSystem_snsys_1 = rvalid_fifoOnBram_icmp_snsys_1;
        ufp_data_icmpEchoSystem_snsys_1 = rdata_fifoOnBram_icmp_snsys_1;
        ufp_last_icmpEchoSystem_snsys_1 = rlast_fifoOnBram_icmp_snsys_1;
        rx_icmp_last_icmpEchoSystem_snsys_1 = rlast_fifoOnBram_icmp_snsys_1;
        config_valid_TcpServerSystem_snsys_1 = ip_addr_valid_linkLocalIpClaimerSystem_snsys_1;
        config_src_addr_TcpServerSystem_snsys_1 = ip_addr_linkLocalIpClaimerSystem_snsys_1;
        rready_fifoOnBram_tcp_snsys_1 = ufp_ready_TcpServerSystem_snsys_1;
        dummy1_6_dummyio_snsys_1 = debug_valid_TxBufferSelector3_snsys_1;
        dummy72_6_dummyio_snsys_1 = debug_data_TxBufferSelector3_snsys_1;
        rx_valid_SampleHttpResponseGenerator_snsys_1 = dfp_rx_data_valid_TcpServerSystem_snsys_1;
        rx_data_SampleHttpResponseGenerator_snsys_1 = dfp_rx_data_TcpServerSystem_snsys_1;
        rx_strb_SampleHttpResponseGenerator_snsys_1 = dfp_rx_data_strb_TcpServerSystem_snsys_1;
        tx_ready_SampleHttpResponseGenerator_snsys_1 = ufp_tx_data_ready_TcpServerSystem_snsys_1;
        rready_fifoOnBram_icmp_snsys_1 = ufp_ready_icmpEchoSystem_snsys_1;
        dfp_ready_ipv4_EtherRecvBufferSelector_snsys_1 = ufp_ready_ipv4BufferSelector_snsys_1;
        dfp_ready_icmp_ipv4BufferSelector_snsys_1 = wready_fifoOnBram_icmp_snsys_1;
        wvalid_fifoOnBram_icmp_snsys_1 = dfp_valid_icmp_ipv4BufferSelector_snsys_1;
        wdata_fifoOnBram_icmp_snsys_1 = dfp_data_icmp_ipv4BufferSelector_snsys_1;
        wlast_fifoOnBram_icmp_snsys_1 = dfp_last_icmp_ipv4BufferSelector_snsys_1;
        dfp_awready_linkLocalIpClaimerSystem_snsys_1 = ufp_awready_1_TxBufferSelector3_snsys_1;
        dfp_wready_linkLocalIpClaimerSystem_snsys_1 = ufp_wready_1_TxBufferSelector3_snsys_1;
        ip_addr_configured_icmpEchoSystem_snsys_1 = ip_addr_valid_linkLocalIpClaimerSystem_snsys_1;
        configured_ip_addr_icmpEchoSystem_snsys_1 = ip_addr_linkLocalIpClaimerSystem_snsys_1;
        dummy1_1_dummyio_snsys_1 = debug_valid_EtherRecvBufferSelector_snsys_1;
        dummy72_1_dummyio_snsys_1 = debug_data_EtherRecvBufferSelector_snsys_1;
        ufp_total_length_data_icmpEchoSystem_snsys_1 = total_length_data_ipv4BufferSelector_snsys_1;
        ufp_src_addr_icmpEchoSystem_snsys_1 = source_address_ipv4BufferSelector_snsys_1;
        ufp_dest_addr_icmpEchoSystem_snsys_1 = destination_address_ipv4BufferSelector_snsys_1;
        rx_src_hwaddr_icmpEchoSystem_snsys_1 = ether_src_addr_out_ipv4BufferSelector_snsys_1;
        rx_dest_hwaddr_icmpEchoSystem_snsys_1 = ether_dest_addr_out_ipv4BufferSelector_snsys_1;
        ufp_awvalid_2_TxBufferSelector3_snsys_1 = dfp_awvalid_icmpEchoSystem_snsys_1;
        ufp_awlen_2_TxBufferSelector3_snsys_1 = dfp_awlen_icmpEchoSystem_snsys_1;
        ufp_wvalid_2_TxBufferSelector3_snsys_1 = dfp_wvalid_icmpEchoSystem_snsys_1;
        ufp_wdata_2_TxBufferSelector3_snsys_1 = dfp_wdata_icmpEchoSystem_snsys_1;
        ufp_wlast_2_TxBufferSelector3_snsys_1 = dfp_wlast_icmpEchoSystem_snsys_1;
        ufp_awvalid_3_TxBufferSelector3_snsys_1 = dfp_awvalid_TcpServerSystem_snsys_1;
        ufp_awlen_3_TxBufferSelector3_snsys_1 = dfp_awlen_TcpServerSystem_snsys_1;
        ufp_wvalid_3_TxBufferSelector3_snsys_1 = dfp_wvalid_TcpServerSystem_snsys_1;
        ufp_wdata_3_TxBufferSelector3_snsys_1 = dfp_wdata_TcpServerSystem_snsys_1;
        ufp_wlast_3_TxBufferSelector3_snsys_1 = dfp_wlast_TcpServerSystem_snsys_1;
        ufp_valid_TcpServerSystem_snsys_1 = rvalid_fifoOnBram_tcp_snsys_1;
        ufp_data_TcpServerSystem_snsys_1 = rdata_fifoOnBram_tcp_snsys_1;
        ufp_last_TcpServerSystem_snsys_1 = rlast_fifoOnBram_tcp_snsys_1;
        ufp_wvalid_linkLocalIpClaimerSystem_snsys_1 = dfp_valid_arp_EtherRecvBufferSelector_snsys_1;
        ufp_wdata_linkLocalIpClaimerSystem_snsys_1 = dfp_data_arp_EtherRecvBufferSelector_snsys_1;
        ufp_wlast_linkLocalIpClaimerSystem_snsys_1 = dfp_last_arp_EtherRecvBufferSelector_snsys_1;
        dummy1_4_dummyio_snsys_1 = debug_valid_TcpServerSystem_snsys_1;
        dummy72_4_dummyio_snsys_1 = debug_data_TcpServerSystem_snsys_1;
        dummy1_5_dummyio_snsys_1 = debug_valid_rcvparse_TcpServerSystem_snsys_1;
        dummy72_5_dummyio_snsys_1 = debug_data_rcvparse_TcpServerSystem_snsys_1;
        dummy1_2_dummyio_snsys_1 = debug_valid_ipv4BufferSelector_snsys_1;
        dummy72_2_dummyio_snsys_1 = debug_data_ipv4BufferSelector_snsys_1;
        dummy1_3_dummyio_snsys_1 = debug_valid_icmpEchoSystem_snsys_1;
        dummy72_3_dummyio_snsys_1 = debug_data_icmpEchoSystem_snsys_1;
        ufp_awvalid_1_TxBufferSelector3_snsys_1 = dfp_awvalid_linkLocalIpClaimerSystem_snsys_1;
        ufp_awlen_1_TxBufferSelector3_snsys_1 = dfp_awlen_linkLocalIpClaimerSystem_snsys_1;
        ufp_wvalid_1_TxBufferSelector3_snsys_1 = dfp_wvalid_linkLocalIpClaimerSystem_snsys_1;
        ufp_wdata_1_TxBufferSelector3_snsys_1 = dfp_wdata_linkLocalIpClaimerSystem_snsys_1;
        ufp_wlast_1_TxBufferSelector3_snsys_1 = dfp_wlast_linkLocalIpClaimerSystem_snsys_1;
        dfp_awready_TcpServerSystem_snsys_1 = ufp_awready_3_TxBufferSelector3_snsys_1;
        dfp_wready_TcpServerSystem_snsys_1 = ufp_wready_3_TxBufferSelector3_snsys_1;
        dfp_awready_icmpEchoSystem_snsys_1 = ufp_awready_2_TxBufferSelector3_snsys_1;
        dfp_wready_icmpEchoSystem_snsys_1 = ufp_wready_2_TxBufferSelector3_snsys_1;
        ufp_total_length_data_TcpServerSystem_snsys_1 = total_length_data_ipv4BufferSelector_snsys_1;
        ufp_src_addr_TcpServerSystem_snsys_1 = source_address_ipv4BufferSelector_snsys_1;
        ufp_dest_addr_TcpServerSystem_snsys_1 = destination_address_ipv4BufferSelector_snsys_1;
        ufp_hwaddr_TcpServerSystem_snsys_1 = ether_src_addr_out_ipv4BufferSelector_snsys_1;
        ufp_hwaddr_valid_TcpServerSystem_snsys_1 = dfp_valid_tcp_ipv4BufferSelector_snsys_1;
        dfp_rx_data_ready_TcpServerSystem_snsys_1 = rx_ready_SampleHttpResponseGenerator_snsys_1;
        ufp_tx_data_valid_TcpServerSystem_snsys_1 = tx_valid_SampleHttpResponseGenerator_snsys_1;
        ufp_tx_data_last_TcpServerSystem_snsys_1 = tx_last_SampleHttpResponseGenerator_snsys_1;
        ufp_tx_data_TcpServerSystem_snsys_1 = tx_data_SampleHttpResponseGenerator_snsys_1;
        ufp_tx_checksum_data_only_TcpServerSystem_snsys_1 = tx_checksum_SampleHttpResponseGenerator_snsys_1;
        ufp_tx_total_length_data_only_TcpServerSystem_snsys_1 = tx_total_length_SampleHttpResponseGenerator_snsys_1;
    end
    always_comb begin
        ufp_ready = ufp_ready_EtherRecvBufferSelector_snsys_1;
        ufp_valid_EtherRecvBufferSelector_snsys_1 = ufp_valid;
        ufp_last_EtherRecvBufferSelector_snsys_1 = ufp_last;
        ufp_data_EtherRecvBufferSelector_snsys_1 = ufp_data;
        debug_valid_srv = debug_valid_srv_TcpServerSystem_snsys_1;
        debug_data_srv = debug_data_srv_TcpServerSystem_snsys_1;
        start_linkLocalIpClaimerSystem_snsys_1 = start;
        dfp_awvalid = dfp_awvalid_TxBufferSelector3_snsys_1;
        dfp_wdata = dfp_wdata_TxBufferSelector3_snsys_1;
        dfp_awlen = dfp_awlen_TxBufferSelector3_snsys_1;
        dfp_wlast = dfp_wlast_TxBufferSelector3_snsys_1;
        dfp_wvalid = dfp_wvalid_TxBufferSelector3_snsys_1;
        dfp_awready_TxBufferSelector3_snsys_1 = dfp_awready;
        dfp_wready_TxBufferSelector3_snsys_1 = dfp_wready;
    end
    always_comb begin
        CLK_ipv4BufferSelector_snsys_1 = CLK;
        RST_ipv4BufferSelector_snsys_1 = RST;
    end
    always_comb begin
        CLK_fifoOnBram_tcp_snsys_1 = CLK;
        RST_fifoOnBram_tcp_snsys_1 = RST;
    end
    always_comb begin
        CLK_EtherRecvBufferSelector_snsys_1 = CLK;
        RST_EtherRecvBufferSelector_snsys_1 = RST;
    end
    always_comb begin
        CLK_icmpEchoSystem_snsys_1 = CLK;
        RST_icmpEchoSystem_snsys_1 = RST;
    end
    always_comb begin
        CLK_TcpServerSystem_snsys_1 = CLK;
        RST_TcpServerSystem_snsys_1 = RST;
    end
    always_comb begin
        CLK_linkLocalIpClaimerSystem_snsys_1 = CLK;
        RST_linkLocalIpClaimerSystem_snsys_1 = RST;
    end
    always_comb begin
        CLK_SampleHttpResponseGenerator_snsys_1 = CLK;
        RST_SampleHttpResponseGenerator_snsys_1 = RST;
    end
    always_comb begin
        CLK_fifoOnBram_icmp_snsys_1 = CLK;
        RST_fifoOnBram_icmp_snsys_1 = RST;
    end
    always_comb begin
        CLK_dummyio_snsys_1 = CLK;
        RST_dummyio_snsys_1 = RST;
    end
    always_comb begin
        CLK_TxBufferSelector3_snsys_1 = CLK;
        RST_TxBufferSelector3_snsys_1 = RST;
    end
endmodule
module ipv4BufferSelector_snsys_1 (
    input CLK,
    input RST,
    input ufp_valid,
    input ufp_last,
    input [31:0] ufp_data,
    output logic ufp_ready,
    output logic debug_valid,
    output logic [71:0] debug_data,
    output logic [31:0] source_address,
    output logic [31:0] destination_address,
    output logic [15:0] total_length_data,
    input [47:0] ether_src_addr_in,
    input [47:0] ether_dest_addr_in,
    output logic [47:0] ether_src_addr_out,
    output logic [47:0] ether_dest_addr_out,
    input dfp_ready_icmp,
    output logic dfp_valid_icmp,
    output logic [31:0] dfp_data_icmp,
    output logic dfp_last_icmp,
    input dfp_ready_tcp,
    output logic dfp_valid_tcp,
    output logic [31:0] dfp_data_tcp,
    output logic dfp_last_tcp
);
    localparam init = 0;
    localparam connectIcmp = 1;
    localparam connectTcp = 2;
    localparam explicitFlushBuffer = 3;
    localparam unknownError = 4;

    reg [2:0] state;
    logic [7:0] protocol;
    logic [7:0] diffserv;
    logic header_read_done;
    logic [15:0] identification;
    logic protocol_tcp;
    logic protocol_icmp;
    logic [7:0] header_read_counter;
    logic invalid_ip_packet;
    logic [7:0] ttl;
    logic [12:0] fragment_offset;
    logic [3:0] version;
    logic [15:0] total_length;
    logic [3:0] ihl_minusone;
    logic [2:0] flags;
    logic [15:0] header_checksum;
    logic [71:0] prev_debug_data;
    logic [3:0] ihl;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            ether_dest_addr_out <= 0;
            ether_src_addr_out <= 0;
        end else begin
            if ((ufp_valid & ufp_ready)) begin
                ether_src_addr_out <= ether_src_addr_in;
                ether_dest_addr_out <= ether_dest_addr_in;
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                init: begin
                    if ((header_read_done & protocol_icmp)) begin
                        state <= connectIcmp;
                    end else if ((header_read_done & protocol_tcp)) begin
                        state <= connectTcp;
                    end else if ((invalid_ip_packet | header_read_done)) begin
                        state <= explicitFlushBuffer;
                    end else if (((ufp_valid & ufp_ready) & ufp_last)) begin
                        state <= unknownError;
                    end
                end
                connectIcmp: begin
                    if (((ufp_valid & ufp_ready) & ufp_last)) begin
                        state <= init;
                    end
                end
                connectTcp: begin
                    if (((ufp_valid & ufp_ready) & ufp_last)) begin
                        state <= init;
                    end
                end
                explicitFlushBuffer: begin
                    if (((ufp_valid & ufp_ready) & ufp_last)) begin
                        state <= init;
                    end
                end
                unknownError: begin
                    if (1) begin
                        state <= init;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        ihl_minusone = (ihl + (~0));
        if ((state == init)) begin
            invalid_ip_packet = ((0 < header_read_counter) & (ihl < 5));
            header_read_done = (((header_read_counter == { 4'd0, ihl_minusone }) & ufp_valid) & ufp_ready);
            protocol_icmp = (protocol == 1);
            protocol_tcp = (protocol == 6);
        end else begin
            invalid_ip_packet = 0;
            header_read_done = 0;
            protocol_icmp = 0;
            protocol_tcp = 0;
        end
    end
    always_comb begin
        total_length_data = ((total_length + 16'd1) + (~({ 12'd0, ihl } << 2)));
        if ((state == init)) begin
            ufp_ready = ((header_read_counter < 5) | (header_read_counter < { 4'd0, ihl }));
        end else if ((state == connectIcmp)) begin
            ufp_ready = dfp_ready_icmp;
        end else if ((state == connectTcp)) begin
            ufp_ready = dfp_ready_tcp;
        end else if ((state == explicitFlushBuffer)) begin
            ufp_ready = 1;
        end else begin
            ufp_ready = 0;
        end
        if ((state == connectIcmp)) begin
            dfp_valid_icmp = ufp_valid;
            dfp_last_icmp = ufp_last;
            dfp_data_icmp = ufp_data;
        end else begin
            dfp_valid_icmp = 0;
            dfp_last_icmp = 0;
            dfp_data_icmp = 0;
        end
        if ((state == connectTcp)) begin
            dfp_valid_tcp = ufp_valid;
            dfp_last_tcp = ufp_last;
            dfp_data_tcp = ufp_data;
        end else begin
            dfp_valid_tcp = 0;
            dfp_last_tcp = 0;
            dfp_data_tcp = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            destination_address <= 0;
            diffserv <= 0;
            flags <= 0;
            fragment_offset <= 0;
            header_checksum <= 0;
            header_read_counter <= 0;
            identification <= 0;
            ihl <= 0;
            protocol <= 0;
            source_address <= 0;
            total_length <= 0;
            ttl <= 0;
            version <= 0;
        end else begin
            if ((state == init)) begin
                if ((ufp_valid & ufp_ready)) begin
                    header_read_counter <= (header_read_counter + 8'd1);
                    if ((header_read_counter == 0)) begin
                        version <= ufp_data[7:4];
                        ihl <= ufp_data[3:0];
                        diffserv <= ufp_data[15:8];
                        total_length <= ({ ufp_data[23:16], ufp_data[31:24] } | 16'd0);
                    end else if ((header_read_counter == 1)) begin
                        identification <= ({ ufp_data[7:0], ufp_data[15:8] } | 16'd0);
                        flags <= ufp_data[23:21];
                        fragment_offset <= ({ ufp_data[20:16], ufp_data[31:24] } | 13'd0);
                    end else if ((header_read_counter == 2)) begin
                        ttl <= ufp_data[7:0];
                        protocol <= ufp_data[15:8];
                        header_checksum <= ({ ufp_data[23:16], ufp_data[31:24] } | 16'd0);
                    end else if ((header_read_counter == 3)) begin
                        source_address <= { ufp_data[7:0], ufp_data[15:8], ufp_data[23:16], ufp_data[31:24] };
                    end else if ((header_read_counter == 4)) begin
                        destination_address <= { ufp_data[7:0], ufp_data[15:8], ufp_data[23:16], ufp_data[31:24] };
                    end
                end
            end else begin
                header_read_counter <= 0;
            end
        end
    end
    always_comb begin
        debug_data = { 16'd0, 1'd0, state, { 1'd0, ufp_last, ufp_valid, ufp_ready }, { 1'd0, dfp_last_tcp, dfp_valid_tcp, dfp_ready_tcp }, total_length_data, 28'd0 };
        debug_valid = (~(debug_data == prev_debug_data));
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            prev_debug_data <= 0;
        end else begin
            prev_debug_data <= debug_data;
        end
    end
endmodule
module fifoOnBram_tcp_snsys_1 (
    input CLK,
    input RST,
    input wvalid,
    input wlast,
    output logic wready,
    input [31:0] wdata,
    output logic rvalid,
    output logic rlast,
    input rready,
    output logic [31:0] rdata
);
    logic rincr;
    logic full;
    logic enread;
    logic empty;
    logic [32:0] din;
    logic [7:0] rptrincr;
    logic [7:0] ptrincr;
    logic [7:0] addrout;
    logic wincr;
    logic [7:0] raddr;
    logic enwrite;
    logic [7:0] addrin;
    logic [7:0] wptr;
    logic [7:0] prevwptr;
    logic [32:0] dout_ramSdpRfInst_;
    logic [7:0] rptr;

    ram_sdp_rf #(
        .addrlen(8),
        .datawid(33)
    ) _instramSdpRfInst_ (
        .clk(CLK),
        .enread(enread),
        .enwrite(enwrite),
        .addrin(addrin),
        .addrout(addrout),
        .din(din),
        .dout(dout_ramSdpRfInst_)
    );
    always_comb begin
        ptrincr = 8'd1;
    end
    always_comb begin
        rincr = rready;
        rvalid = (~empty);
        wincr = wvalid;
        wready = (~full);
    end
    always_comb begin
        empty = (prevwptr == rptr);
        full = ((wptr + ptrincr) == rptr);
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            rptrincr <= 1;
        end else begin
            if ((rincr & (~empty))) begin
                rptrincr <= (rptrincr + ptrincr);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            prevwptr <= 0;
            rptr <= 0;
            wptr <= 0;
        end else begin
            prevwptr <= wptr;
            if ((wincr & (~full))) begin
                wptr <= (wptr + ptrincr);
            end
            if ((rincr & (~empty))) begin
                rptr <= (rptr + ptrincr);
            end
        end
    end
    always_comb begin
        if ((rincr & (~empty))) begin
            raddr = rptrincr;
        end else begin
            raddr = rptr;
        end
    end
    always_comb begin
        enread = 1'd1;
        enwrite = (wvalid & wready);
        addrin = wptr;
        addrout = raddr;
        din = ({ wdata, wlast } | 33'd0);
        { rdata, rlast } = (dout_ramSdpRfInst_ | 33'd0);
    end
endmodule
module EtherRecvBufferSelector_snsys_1 (
    input CLK,
    input RST,
    input ufp_valid,
    input ufp_last,
    output logic ufp_ready,
    input [31:0] ufp_data,
    output logic [47:0] dest_addr,
    output logic [47:0] src_addr,
    output logic debug_valid,
    output logic [71:0] debug_data,
    input dfp_ready_arp,
    output logic dfp_valid_arp,
    output logic [31:0] dfp_data_arp,
    output logic dfp_last_arp,
    input dfp_ready_ipv4,
    output logic dfp_valid_ipv4,
    output logic [31:0] dfp_data_ipv4,
    output logic dfp_last_ipv4
);
    localparam init = 0;
    localparam connectArp = 1;
    localparam connectIpv4 = 2;
    localparam explicitFlushBuffer = 3;

    reg [1:0] state;
    logic htype_arp;
    logic [7:0] header_read_counter;
    logic htype_ipv4;
    logic header_read_done;
    logic [15:0] payload_fallthrough;
    logic [15:0] ethertype_earliest;
    logic [71:0] prev_debug_data;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                init: begin
                    if ((header_read_done & htype_arp)) begin
                        state <= connectArp;
                    end else if ((header_read_done & htype_ipv4)) begin
                        state <= connectIpv4;
                    end else if (header_read_done) begin
                        state <= explicitFlushBuffer;
                    end
                end
                connectArp: begin
                    if (((ufp_valid & ufp_ready) & ufp_last)) begin
                        state <= init;
                    end
                end
                connectIpv4: begin
                    if (((ufp_valid & ufp_ready) & ufp_last)) begin
                        state <= init;
                    end
                end
                explicitFlushBuffer: begin
                    if (((ufp_valid & ufp_ready) & ufp_last)) begin
                        state <= init;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        header_read_done = (((header_read_counter == 3) & ufp_ready) & ufp_valid);
        htype_arp = (ethertype_earliest == 16'd2054);
        htype_ipv4 = (ethertype_earliest == 16'd2048);
    end
    always_comb begin
        if ((state == init)) begin
            ufp_ready = (~(header_read_counter == 4));
        end else if ((state == connectArp)) begin
            ufp_ready = dfp_ready_arp;
        end else if ((state == connectIpv4)) begin
            ufp_ready = dfp_ready_ipv4;
        end else begin
            ufp_ready = 1;
        end
        if ((state == connectArp)) begin
            dfp_valid_arp = ufp_valid;
            dfp_last_arp = ufp_last;
            dfp_data_arp = { ufp_data[15:0], payload_fallthrough };
        end else begin
            dfp_valid_arp = 0;
            dfp_last_arp = 0;
            dfp_data_arp = 0;
        end
        if ((state == connectIpv4)) begin
            dfp_valid_ipv4 = ufp_valid;
            dfp_last_ipv4 = ufp_last;
            dfp_data_ipv4 = { ufp_data[15:0], payload_fallthrough };
        end else begin
            dfp_valid_ipv4 = 0;
            dfp_last_ipv4 = 0;
            dfp_data_ipv4 = 0;
        end
    end
    always_comb begin
        ethertype_earliest = { ufp_data[7:0], ufp_data[15:8] };
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            dest_addr <= 0;
            header_read_counter <= 0;
            payload_fallthrough <= 0;
            src_addr <= 0;
        end else begin
            if ((state == init)) begin
                if ((ufp_ready & ufp_valid)) begin
                    header_read_counter <= (header_read_counter + 8'd1);
                    if ((header_read_counter == 0)) begin
                        dest_addr[47:16] <= { ufp_data[7:0], ufp_data[15:8], ufp_data[23:16], ufp_data[31:24] };
                    end else if ((header_read_counter == 1)) begin
                        dest_addr[15:0] <= { ufp_data[7:0], ufp_data[15:8] };
                        src_addr[47:32] <= { ufp_data[23:16], ufp_data[31:24] };
                    end else if ((header_read_counter == 2)) begin
                        src_addr[31:0] <= { ufp_data[7:0], ufp_data[15:8], ufp_data[23:16], ufp_data[31:24] };
                    end else if ((header_read_counter == 3)) begin
                        payload_fallthrough <= ufp_data[31:16];
                    end
                end
            end else begin
                header_read_counter <= 0;
                if ((ufp_valid & ufp_ready)) begin
                    payload_fallthrough <= ufp_data[31:16];
                end
            end
        end
    end
    always_comb begin
        debug_data = { 44'd0, 2'd0, state, { 1'd0, ufp_last, ufp_valid, ufp_ready }, { 1'd0, dfp_last_ipv4, dfp_valid_ipv4, dfp_ready_ipv4 }, payload_fallthrough };
        debug_valid = (~(prev_debug_data == debug_data));
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            prev_debug_data <= 0;
        end else begin
            prev_debug_data <= debug_data;
        end
    end
endmodule
module icmpEchoSystem_snsys_1 (
    input [31:0] ufp_dest_addr,
    output logic ufp_ready,
    input ufp_valid,
    input ufp_last,
    input [15:0] ufp_total_length_data,
    input [31:0] ufp_src_addr,
    input [31:0] ufp_data,
    output logic dfp_awvalid,
    output logic [31:0] dfp_wdata,
    output logic [7:0] dfp_awlen,
    output logic dfp_wlast,
    output logic dfp_wvalid,
    input dfp_awready,
    input dfp_wready,
    output logic [71:0] debug_data,
    output logic debug_valid,
    input ip_addr_configured,
    input [47:0] rx_src_hwaddr,
    input [47:0] rx_dest_hwaddr,
    input [31:0] configured_ip_addr,
    input rx_icmp_last,
    input CLK,
    input RST
);
    logic ufp_valid_icmpRecvParser_echosys_snsys_1;
    logic ufp_wvalid_randomReadAccessBuffer_echosys_snsys_1;
    logic dfp_wvalid_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [15:0] tx_identifier_icmpEchoServer_echosys_snsys_1;
    logic ufp_wlast_randomReadAccessBuffer_echosys_snsys_1;
    logic rx_data_invalid_icmpEchoServer_echosys_snsys_1;
    logic info_core_valid_icmpRecvParser_echosys_snsys_1;
    logic [12:0] rx_data_count_icmpEchoServer_echosys_snsys_1;
    logic [15:0] checksum_data_only_icmpRecvParser_echosys_snsys_1;
    logic dfp_rvalid_randomReadAccessBuffer_echosys_snsys_1;
    logic [15:0] rx_checksum_data_only_icmpEchoServer_echosys_snsys_1;
    logic tx_ipaddr_valid_icmpEchoServer_echosys_snsys_1;
    logic debug_valid_randomReadAccessBuffer_echosys_snsys_1;
    logic dfp_last_icmpRecvParser_echosys_snsys_1;
    logic dfp_arvalid_randomReadAccessBuffer_echosys_snsys_1;
    logic rx_data_valid_icmpEchoServer_echosys_snsys_1;
    logic rx_data_flush_icmpEchoServer_echosys_snsys_1;
    logic dfp_awvalid_IcmpEchoMessageBlock_echosys_snsys_1;
    logic ip_addr_configured_icmpEchoServer_echosys_snsys_1;
    logic [31:0] dfp_data_icmpRecvParser_echosys_snsys_1;
    logic no_data_payload_icmpRecvParser_echosys_snsys_1;
    logic [15:0] total_length_data_IcmpEchoMessageBlock_echosys_snsys_1;
    logic RST_icmpEchoServer_echosys_snsys_1;
    logic CLK_icmpEchoServer_echosys_snsys_1;
    logic [7:0] _type_icmpRecvParser_echosys_snsys_1;
    logic dfp_awready_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [31:0] configured_ip_addr_icmpEchoServer_echosys_snsys_1;
    logic dfp_wlast_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [31:0] ufp_dest_addr_icmpRecvParser_echosys_snsys_1;
    logic commandValid_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [47:0] tx_dest_hwaddr_icmpEchoServer_echosys_snsys_1;
    logic [15:0] rx_total_length_data_icmpEchoServer_echosys_snsys_1;
    logic [7:0] tx_type_icmpEchoServer_echosys_snsys_1;
    logic [31:0] rx_src_ipaddr_icmpEchoServer_echosys_snsys_1;
    logic commandReady_IcmpEchoMessageBlock_echosys_snsys_1;
    logic RST_randomReadAccessBuffer_echosys_snsys_1;
    logic [15:0] checksum_icmpRecvParser_echosys_snsys_1;
    logic [12:0] rx_data_araddr_icmpEchoServer_echosys_snsys_1;
    logic ufp_addr_valid_IcmpEchoMessageBlock_echosys_snsys_1;
    logic tx_icmp_data_ready_icmpEchoServer_echosys_snsys_1;
    logic [71:0] debug_data_randomReadAccessBuffer_echosys_snsys_1;
    logic [31:0] sourceAddr_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [31:0] ufp_data_icmpRecvParser_echosys_snsys_1;
    logic [15:0] rx_sequence_number_icmpEchoServer_echosys_snsys_1;
    logic [7:0] dfp_awlen_IcmpEchoMessageBlock_echosys_snsys_1;
    logic rx_icmp_info_valid_icmpEchoServer_echosys_snsys_1;
    logic rx_data_arready_icmpEchoServer_echosys_snsys_1;
    logic [15:0] rx_identifier_icmpEchoServer_echosys_snsys_1;
    logic rx_data_full_icmpEchoServer_echosys_snsys_1;
    logic rx_no_data_payload_icmpEchoServer_echosys_snsys_1;
    logic [7:0] code_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [15:0] total_length_data_icmpRecvParser_echosys_snsys_1;
    logic tx_icmp_misc_ready_icmpEchoServer_echosys_snsys_1;
    logic rx_data_arvalid_icmpEchoServer_echosys_snsys_1;
    logic CLK_icmpRecvParser_echosys_snsys_1;
    logic CLK_dummyio_echosys_snsys_1;
    logic [71:0] dummy72_1_dummyio_echosys_snsys_1;
    logic rx_icmp_info_ready_icmpEchoServer_echosys_snsys_1;
    logic ufp_ready_IcmpEchoMessageBlock_echosys_snsys_1;
    logic dummy1_2_dummyio_echosys_snsys_1;
    logic [15:0] tx_sequence_number_icmpEchoServer_echosys_snsys_1;
    logic RST_dummyio_echosys_snsys_1;
    logic CLK_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [31:0] rx_data_icmpEchoServer_echosys_snsys_1;
    logic CLK_randomReadAccessBuffer_echosys_snsys_1;
    logic ufp_misc_valid_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [15:0] identifier_IcmpEchoMessageBlock_echosys_snsys_1;
    logic dfp_ready_icmpRecvParser_echosys_snsys_1;
    logic [31:0] tx_dest_ipaddr_icmpEchoServer_echosys_snsys_1;
    logic [15:0] sequence_number_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [31:0] dest_addr_icmpRecvParser_echosys_snsys_1;
    logic [7:0] rx_type_icmpEchoServer_echosys_snsys_1;
    logic [31:0] ufp_data_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [15:0] identifier_icmpRecvParser_echosys_snsys_1;
    logic tx_hwaddr_valid_icmpEchoServer_echosys_snsys_1;
    logic dfp_arready_randomReadAccessBuffer_echosys_snsys_1;
    logic tx_hwaddr_ready_icmpEchoServer_echosys_snsys_1;
    logic dfp_flush_randomReadAccessBuffer_echosys_snsys_1;
    logic rx_icmp_last_icmpEchoServer_echosys_snsys_1;
    logic ufp_misc_ready_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [12:0] stored_length_randomReadAccessBuffer_echosys_snsys_1;
    logic ufp_wready_randomReadAccessBuffer_echosys_snsys_1;
    logic [15:0] ufp_total_length_data_icmpRecvParser_echosys_snsys_1;
    logic RST_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [7:0] dummy8_1_dummyio_echosys_snsys_1;
    logic RST_icmpRecvParser_echosys_snsys_1;
    logic dfp_wready_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [31:0] ufp_wdata_randomReadAccessBuffer_echosys_snsys_1;
    logic tx_icmp_data_last_icmpEchoServer_echosys_snsys_1;
    logic ufp_ready_icmpRecvParser_echosys_snsys_1;
    logic tx_icmp_misc_valid_icmpEchoServer_echosys_snsys_1;
    logic tx_ipaddr_ready_icmpEchoServer_echosys_snsys_1;
    logic dfp_valid_icmpRecvParser_echosys_snsys_1;
    logic ufp_valid_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [31:0] tx_icmp_data_icmpEchoServer_echosys_snsys_1;
    logic [15:0] checksum_data_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [15:0] tx_checksum_data_only_icmpEchoServer_echosys_snsys_1;
    logic dummy1_1_dummyio_echosys_snsys_1;
    logic ufp_last_icmpRecvParser_echosys_snsys_1;
    logic [47:0] rx_src_hwaddr_icmpEchoServer_echosys_snsys_1;
    logic [15:0] dummy16_1_dummyio_echosys_snsys_1;
    logic info_ready_icmpRecvParser_echosys_snsys_1;
    logic [15:0] tx_total_length_data_icmpEchoServer_echosys_snsys_1;
    logic [31:0] src_addr_icmpRecvParser_echosys_snsys_1;
    logic [31:0] rx_dest_ipaddr_icmpEchoServer_echosys_snsys_1;
    logic [71:0] debug_data_icmpEchoServer_echosys_snsys_1;
    logic [47:0] rx_dest_hwaddr_icmpEchoServer_echosys_snsys_1;
    logic ufp_last_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [47:0] destMacAddr_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [31:0] ufp_src_addr_icmpRecvParser_echosys_snsys_1;
    logic [7:0] tx_code_icmpEchoServer_echosys_snsys_1;
    logic [31:0] destAddr_IcmpEchoMessageBlock_echosys_snsys_1;
    logic [31:0] tx_src_ipaddr_icmpEchoServer_echosys_snsys_1;
    logic info_valid_icmpRecvParser_echosys_snsys_1;
    logic dfp_rinvalid_randomReadAccessBuffer_echosys_snsys_1;
    logic dfp_full_randomReadAccessBuffer_echosys_snsys_1;
    logic [7:0] _type_IcmpEchoMessageBlock_echosys_snsys_1;
    logic tx_icmp_data_valid_icmpEchoServer_echosys_snsys_1;
    logic [12:0] dfp_araddr_randomReadAccessBuffer_echosys_snsys_1;
    logic [15:0] sequence_number_icmpRecvParser_echosys_snsys_1;
    logic [31:0] dfp_rdata_randomReadAccessBuffer_echosys_snsys_1;
    logic [7:0] code_icmpRecvParser_echosys_snsys_1;
    logic [31:0] dfp_wdata_IcmpEchoMessageBlock_echosys_snsys_1;
    logic debug_valid_icmpEchoServer_echosys_snsys_1;
    logic ufp_addr_ready_IcmpEchoMessageBlock_echosys_snsys_1;

    icmpRecvParser_echosys_snsys_1 icmpRecvParser_echosys_snsys_1_inst (
        .CLK(CLK_icmpRecvParser_echosys_snsys_1),
        .RST(RST_icmpRecvParser_echosys_snsys_1),
        .ufp_valid(ufp_valid_icmpRecvParser_echosys_snsys_1),
        .ufp_last(ufp_last_icmpRecvParser_echosys_snsys_1),
        .ufp_ready(ufp_ready_icmpRecvParser_echosys_snsys_1),
        .ufp_data(ufp_data_icmpRecvParser_echosys_snsys_1),
        .ufp_src_addr(ufp_src_addr_icmpRecvParser_echosys_snsys_1),
        .ufp_dest_addr(ufp_dest_addr_icmpRecvParser_echosys_snsys_1),
        .ufp_total_length_data(ufp_total_length_data_icmpRecvParser_echosys_snsys_1),
        .dfp_valid(dfp_valid_icmpRecvParser_echosys_snsys_1),
        .dfp_last(dfp_last_icmpRecvParser_echosys_snsys_1),
        .dfp_data(dfp_data_icmpRecvParser_echosys_snsys_1),
        .dfp_ready(dfp_ready_icmpRecvParser_echosys_snsys_1),
        .total_length_data(total_length_data_icmpRecvParser_echosys_snsys_1),
        .src_addr(src_addr_icmpRecvParser_echosys_snsys_1),
        .dest_addr(dest_addr_icmpRecvParser_echosys_snsys_1),
        .no_data_payload(no_data_payload_icmpRecvParser_echosys_snsys_1),
        ._type(_type_icmpRecvParser_echosys_snsys_1),
        .code(code_icmpRecvParser_echosys_snsys_1),
        .checksum(checksum_icmpRecvParser_echosys_snsys_1),
        .identifier(identifier_icmpRecvParser_echosys_snsys_1),
        .sequence_number(sequence_number_icmpRecvParser_echosys_snsys_1),
        .checksum_data_only(checksum_data_only_icmpRecvParser_echosys_snsys_1),
        .info_core_valid(info_core_valid_icmpRecvParser_echosys_snsys_1),
        .info_valid(info_valid_icmpRecvParser_echosys_snsys_1),
        .info_ready(info_ready_icmpRecvParser_echosys_snsys_1)
    );
    dummyio_echosys_snsys_1 dummyio_echosys_snsys_1_inst (
        .dummy1_1(dummy1_1_dummyio_echosys_snsys_1),
        .dummy1_2(dummy1_2_dummyio_echosys_snsys_1),
        .dummy8_1(dummy8_1_dummyio_echosys_snsys_1),
        .dummy16_1(dummy16_1_dummyio_echosys_snsys_1),
        .dummy72_1(dummy72_1_dummyio_echosys_snsys_1),
        .CLK(CLK_dummyio_echosys_snsys_1),
        .RST(RST_dummyio_echosys_snsys_1)
    );
    randomReadAccessBuffer_echosys_snsys_1 randomReadAccessBuffer_echosys_snsys_1_inst (
        .CLK(CLK_randomReadAccessBuffer_echosys_snsys_1),
        .RST(RST_randomReadAccessBuffer_echosys_snsys_1),
        .ufp_wvalid(ufp_wvalid_randomReadAccessBuffer_echosys_snsys_1),
        .ufp_wlast(ufp_wlast_randomReadAccessBuffer_echosys_snsys_1),
        .ufp_wdata(ufp_wdata_randomReadAccessBuffer_echosys_snsys_1),
        .ufp_wready(ufp_wready_randomReadAccessBuffer_echosys_snsys_1),
        .dfp_araddr(dfp_araddr_randomReadAccessBuffer_echosys_snsys_1),
        .dfp_arvalid(dfp_arvalid_randomReadAccessBuffer_echosys_snsys_1),
        .dfp_arready(dfp_arready_randomReadAccessBuffer_echosys_snsys_1),
        .dfp_rvalid(dfp_rvalid_randomReadAccessBuffer_echosys_snsys_1),
        .dfp_rinvalid(dfp_rinvalid_randomReadAccessBuffer_echosys_snsys_1),
        .dfp_rdata(dfp_rdata_randomReadAccessBuffer_echosys_snsys_1),
        .dfp_flush(dfp_flush_randomReadAccessBuffer_echosys_snsys_1),
        .dfp_full(dfp_full_randomReadAccessBuffer_echosys_snsys_1),
        .stored_length(stored_length_randomReadAccessBuffer_echosys_snsys_1),
        .debug_valid(debug_valid_randomReadAccessBuffer_echosys_snsys_1),
        .debug_data(debug_data_randomReadAccessBuffer_echosys_snsys_1)
    );
    IcmpEchoMessageBlock_echosys_snsys_1 IcmpEchoMessageBlock_echosys_snsys_1_inst (
        .dfp_awvalid(dfp_awvalid_IcmpEchoMessageBlock_echosys_snsys_1),
        .dfp_wdata(dfp_wdata_IcmpEchoMessageBlock_echosys_snsys_1),
        .dfp_awlen(dfp_awlen_IcmpEchoMessageBlock_echosys_snsys_1),
        .dfp_wlast(dfp_wlast_IcmpEchoMessageBlock_echosys_snsys_1),
        .dfp_wvalid(dfp_wvalid_IcmpEchoMessageBlock_echosys_snsys_1),
        .dfp_awready(dfp_awready_IcmpEchoMessageBlock_echosys_snsys_1),
        .dfp_wready(dfp_wready_IcmpEchoMessageBlock_echosys_snsys_1),
        .ufp_addr_valid(ufp_addr_valid_IcmpEchoMessageBlock_echosys_snsys_1),
        .ufp_addr_ready(ufp_addr_ready_IcmpEchoMessageBlock_echosys_snsys_1),
        .sourceAddr(sourceAddr_IcmpEchoMessageBlock_echosys_snsys_1),
        .destAddr(destAddr_IcmpEchoMessageBlock_echosys_snsys_1),
        .identifier(identifier_IcmpEchoMessageBlock_echosys_snsys_1),
        .ufp_valid(ufp_valid_IcmpEchoMessageBlock_echosys_snsys_1),
        .ufp_last(ufp_last_IcmpEchoMessageBlock_echosys_snsys_1),
        .checksum_data(checksum_data_IcmpEchoMessageBlock_echosys_snsys_1),
        .ufp_data(ufp_data_IcmpEchoMessageBlock_echosys_snsys_1),
        .sequence_number(sequence_number_IcmpEchoMessageBlock_echosys_snsys_1),
        .ufp_ready(ufp_ready_IcmpEchoMessageBlock_echosys_snsys_1),
        .total_length_data(total_length_data_IcmpEchoMessageBlock_echosys_snsys_1),
        ._type(_type_IcmpEchoMessageBlock_echosys_snsys_1),
        .ufp_misc_ready(ufp_misc_ready_IcmpEchoMessageBlock_echosys_snsys_1),
        .code(code_IcmpEchoMessageBlock_echosys_snsys_1),
        .ufp_misc_valid(ufp_misc_valid_IcmpEchoMessageBlock_echosys_snsys_1),
        .commandValid(commandValid_IcmpEchoMessageBlock_echosys_snsys_1),
        .commandReady(commandReady_IcmpEchoMessageBlock_echosys_snsys_1),
        .destMacAddr(destMacAddr_IcmpEchoMessageBlock_echosys_snsys_1),
        .CLK(CLK_IcmpEchoMessageBlock_echosys_snsys_1),
        .RST(RST_IcmpEchoMessageBlock_echosys_snsys_1)
    );
    icmpEchoServer_echosys_snsys_1 icmpEchoServer_echosys_snsys_1_inst (
        .CLK(CLK_icmpEchoServer_echosys_snsys_1),
        .RST(RST_icmpEchoServer_echosys_snsys_1),
        .ip_addr_configured(ip_addr_configured_icmpEchoServer_echosys_snsys_1),
        .configured_ip_addr(configured_ip_addr_icmpEchoServer_echosys_snsys_1),
        .rx_type(rx_type_icmpEchoServer_echosys_snsys_1),
        .rx_sequence_number(rx_sequence_number_icmpEchoServer_echosys_snsys_1),
        .rx_identifier(rx_identifier_icmpEchoServer_echosys_snsys_1),
        .rx_checksum_data_only(rx_checksum_data_only_icmpEchoServer_echosys_snsys_1),
        .rx_no_data_payload(rx_no_data_payload_icmpEchoServer_echosys_snsys_1),
        .rx_icmp_info_valid(rx_icmp_info_valid_icmpEchoServer_echosys_snsys_1),
        .rx_icmp_info_ready(rx_icmp_info_ready_icmpEchoServer_echosys_snsys_1),
        .rx_src_ipaddr(rx_src_ipaddr_icmpEchoServer_echosys_snsys_1),
        .rx_dest_ipaddr(rx_dest_ipaddr_icmpEchoServer_echosys_snsys_1),
        .rx_total_length_data(rx_total_length_data_icmpEchoServer_echosys_snsys_1),
        .rx_data(rx_data_icmpEchoServer_echosys_snsys_1),
        .rx_data_valid(rx_data_valid_icmpEchoServer_echosys_snsys_1),
        .rx_data_invalid(rx_data_invalid_icmpEchoServer_echosys_snsys_1),
        .rx_data_full(rx_data_full_icmpEchoServer_echosys_snsys_1),
        .rx_data_count(rx_data_count_icmpEchoServer_echosys_snsys_1),
        .rx_data_flush(rx_data_flush_icmpEchoServer_echosys_snsys_1),
        .rx_data_araddr(rx_data_araddr_icmpEchoServer_echosys_snsys_1),
        .rx_data_arvalid(rx_data_arvalid_icmpEchoServer_echosys_snsys_1),
        .rx_data_arready(rx_data_arready_icmpEchoServer_echosys_snsys_1),
        .rx_src_hwaddr(rx_src_hwaddr_icmpEchoServer_echosys_snsys_1),
        .rx_dest_hwaddr(rx_dest_hwaddr_icmpEchoServer_echosys_snsys_1),
        .rx_icmp_last(rx_icmp_last_icmpEchoServer_echosys_snsys_1),
        .tx_type(tx_type_icmpEchoServer_echosys_snsys_1),
        .tx_code(tx_code_icmpEchoServer_echosys_snsys_1),
        .tx_total_length_data(tx_total_length_data_icmpEchoServer_echosys_snsys_1),
        .tx_sequence_number(tx_sequence_number_icmpEchoServer_echosys_snsys_1),
        .tx_identifier(tx_identifier_icmpEchoServer_echosys_snsys_1),
        .tx_checksum_data_only(tx_checksum_data_only_icmpEchoServer_echosys_snsys_1),
        .tx_icmp_misc_valid(tx_icmp_misc_valid_icmpEchoServer_echosys_snsys_1),
        .tx_icmp_misc_ready(tx_icmp_misc_ready_icmpEchoServer_echosys_snsys_1),
        .tx_icmp_data_valid(tx_icmp_data_valid_icmpEchoServer_echosys_snsys_1),
        .tx_icmp_data_last(tx_icmp_data_last_icmpEchoServer_echosys_snsys_1),
        .tx_icmp_data_ready(tx_icmp_data_ready_icmpEchoServer_echosys_snsys_1),
        .tx_icmp_data(tx_icmp_data_icmpEchoServer_echosys_snsys_1),
        .tx_src_ipaddr(tx_src_ipaddr_icmpEchoServer_echosys_snsys_1),
        .tx_dest_ipaddr(tx_dest_ipaddr_icmpEchoServer_echosys_snsys_1),
        .tx_ipaddr_valid(tx_ipaddr_valid_icmpEchoServer_echosys_snsys_1),
        .tx_ipaddr_ready(tx_ipaddr_ready_icmpEchoServer_echosys_snsys_1),
        .tx_dest_hwaddr(tx_dest_hwaddr_icmpEchoServer_echosys_snsys_1),
        .tx_hwaddr_valid(tx_hwaddr_valid_icmpEchoServer_echosys_snsys_1),
        .tx_hwaddr_ready(tx_hwaddr_ready_icmpEchoServer_echosys_snsys_1),
        .debug_valid(debug_valid_icmpEchoServer_echosys_snsys_1),
        .debug_data(debug_data_icmpEchoServer_echosys_snsys_1)
    );
    always_comb begin
        rx_data_arready_icmpEchoServer_echosys_snsys_1 = dfp_arready_randomReadAccessBuffer_echosys_snsys_1;
        rx_data_valid_icmpEchoServer_echosys_snsys_1 = dfp_rvalid_randomReadAccessBuffer_echosys_snsys_1;
        rx_data_invalid_icmpEchoServer_echosys_snsys_1 = dfp_rinvalid_randomReadAccessBuffer_echosys_snsys_1;
        rx_data_icmpEchoServer_echosys_snsys_1 = dfp_rdata_randomReadAccessBuffer_echosys_snsys_1;
        rx_data_full_icmpEchoServer_echosys_snsys_1 = dfp_full_randomReadAccessBuffer_echosys_snsys_1;
        rx_data_count_icmpEchoServer_echosys_snsys_1 = stored_length_randomReadAccessBuffer_echosys_snsys_1;
        _type_IcmpEchoMessageBlock_echosys_snsys_1 = tx_type_icmpEchoServer_echosys_snsys_1;
        code_IcmpEchoMessageBlock_echosys_snsys_1 = tx_code_icmpEchoServer_echosys_snsys_1;
        total_length_data_IcmpEchoMessageBlock_echosys_snsys_1 = tx_total_length_data_icmpEchoServer_echosys_snsys_1;
        sequence_number_IcmpEchoMessageBlock_echosys_snsys_1 = tx_sequence_number_icmpEchoServer_echosys_snsys_1;
        identifier_IcmpEchoMessageBlock_echosys_snsys_1 = tx_identifier_icmpEchoServer_echosys_snsys_1;
        checksum_data_IcmpEchoMessageBlock_echosys_snsys_1 = tx_checksum_data_only_icmpEchoServer_echosys_snsys_1;
        ufp_misc_valid_IcmpEchoMessageBlock_echosys_snsys_1 = tx_icmp_misc_valid_icmpEchoServer_echosys_snsys_1;
        ufp_valid_IcmpEchoMessageBlock_echosys_snsys_1 = tx_icmp_data_valid_icmpEchoServer_echosys_snsys_1;
        ufp_last_IcmpEchoMessageBlock_echosys_snsys_1 = tx_icmp_data_last_icmpEchoServer_echosys_snsys_1;
        ufp_data_IcmpEchoMessageBlock_echosys_snsys_1 = tx_icmp_data_icmpEchoServer_echosys_snsys_1;
        sourceAddr_IcmpEchoMessageBlock_echosys_snsys_1 = tx_src_ipaddr_icmpEchoServer_echosys_snsys_1;
        destAddr_IcmpEchoMessageBlock_echosys_snsys_1 = tx_dest_ipaddr_icmpEchoServer_echosys_snsys_1;
        ufp_addr_valid_IcmpEchoMessageBlock_echosys_snsys_1 = tx_ipaddr_valid_icmpEchoServer_echosys_snsys_1;
        destMacAddr_IcmpEchoMessageBlock_echosys_snsys_1 = tx_dest_hwaddr_icmpEchoServer_echosys_snsys_1;
        commandValid_IcmpEchoMessageBlock_echosys_snsys_1 = tx_hwaddr_valid_icmpEchoServer_echosys_snsys_1;
        info_ready_icmpRecvParser_echosys_snsys_1 = rx_icmp_info_ready_icmpEchoServer_echosys_snsys_1;
        rx_total_length_data_icmpEchoServer_echosys_snsys_1 = total_length_data_icmpRecvParser_echosys_snsys_1;
        rx_src_ipaddr_icmpEchoServer_echosys_snsys_1 = src_addr_icmpRecvParser_echosys_snsys_1;
        rx_dest_ipaddr_icmpEchoServer_echosys_snsys_1 = dest_addr_icmpRecvParser_echosys_snsys_1;
        rx_no_data_payload_icmpEchoServer_echosys_snsys_1 = no_data_payload_icmpRecvParser_echosys_snsys_1;
        rx_type_icmpEchoServer_echosys_snsys_1 = _type_icmpRecvParser_echosys_snsys_1;
        rx_identifier_icmpEchoServer_echosys_snsys_1 = identifier_icmpRecvParser_echosys_snsys_1;
        rx_sequence_number_icmpEchoServer_echosys_snsys_1 = sequence_number_icmpRecvParser_echosys_snsys_1;
        rx_checksum_data_only_icmpEchoServer_echosys_snsys_1 = checksum_data_only_icmpRecvParser_echosys_snsys_1;
        rx_icmp_info_valid_icmpEchoServer_echosys_snsys_1 = info_valid_icmpRecvParser_echosys_snsys_1;
        dfp_ready_icmpRecvParser_echosys_snsys_1 = ufp_wready_randomReadAccessBuffer_echosys_snsys_1;
        dummy1_2_dummyio_echosys_snsys_1 = debug_valid_randomReadAccessBuffer_echosys_snsys_1;
        dummy72_1_dummyio_echosys_snsys_1 = debug_data_randomReadAccessBuffer_echosys_snsys_1;
        tx_ipaddr_ready_icmpEchoServer_echosys_snsys_1 = ufp_addr_ready_IcmpEchoMessageBlock_echosys_snsys_1;
        tx_hwaddr_ready_icmpEchoServer_echosys_snsys_1 = commandReady_IcmpEchoMessageBlock_echosys_snsys_1;
        tx_icmp_data_ready_icmpEchoServer_echosys_snsys_1 = ufp_ready_IcmpEchoMessageBlock_echosys_snsys_1;
        tx_icmp_misc_ready_icmpEchoServer_echosys_snsys_1 = ufp_misc_ready_IcmpEchoMessageBlock_echosys_snsys_1;
        dummy8_1_dummyio_echosys_snsys_1 = code_icmpRecvParser_echosys_snsys_1;
        dummy16_1_dummyio_echosys_snsys_1 = checksum_icmpRecvParser_echosys_snsys_1;
        dummy1_1_dummyio_echosys_snsys_1 = info_core_valid_icmpRecvParser_echosys_snsys_1;
        ufp_wvalid_randomReadAccessBuffer_echosys_snsys_1 = dfp_valid_icmpRecvParser_echosys_snsys_1;
        ufp_wlast_randomReadAccessBuffer_echosys_snsys_1 = dfp_last_icmpRecvParser_echosys_snsys_1;
        ufp_wdata_randomReadAccessBuffer_echosys_snsys_1 = dfp_data_icmpRecvParser_echosys_snsys_1;
        dfp_araddr_randomReadAccessBuffer_echosys_snsys_1 = rx_data_araddr_icmpEchoServer_echosys_snsys_1;
        dfp_arvalid_randomReadAccessBuffer_echosys_snsys_1 = rx_data_arvalid_icmpEchoServer_echosys_snsys_1;
        dfp_flush_randomReadAccessBuffer_echosys_snsys_1 = rx_data_flush_icmpEchoServer_echosys_snsys_1;
    end
    always_comb begin
        ufp_dest_addr_icmpRecvParser_echosys_snsys_1 = ufp_dest_addr;
        ufp_ready = ufp_ready_icmpRecvParser_echosys_snsys_1;
        ufp_valid_icmpRecvParser_echosys_snsys_1 = ufp_valid;
        ufp_last_icmpRecvParser_echosys_snsys_1 = ufp_last;
        ufp_total_length_data_icmpRecvParser_echosys_snsys_1 = ufp_total_length_data;
        ufp_src_addr_icmpRecvParser_echosys_snsys_1 = ufp_src_addr;
        ufp_data_icmpRecvParser_echosys_snsys_1 = ufp_data;
        dfp_awvalid = dfp_awvalid_IcmpEchoMessageBlock_echosys_snsys_1;
        dfp_wdata = dfp_wdata_IcmpEchoMessageBlock_echosys_snsys_1;
        dfp_awlen = dfp_awlen_IcmpEchoMessageBlock_echosys_snsys_1;
        dfp_wlast = dfp_wlast_IcmpEchoMessageBlock_echosys_snsys_1;
        dfp_wvalid = dfp_wvalid_IcmpEchoMessageBlock_echosys_snsys_1;
        dfp_awready_IcmpEchoMessageBlock_echosys_snsys_1 = dfp_awready;
        dfp_wready_IcmpEchoMessageBlock_echosys_snsys_1 = dfp_wready;
        debug_data = debug_data_icmpEchoServer_echosys_snsys_1;
        debug_valid = debug_valid_icmpEchoServer_echosys_snsys_1;
        ip_addr_configured_icmpEchoServer_echosys_snsys_1 = ip_addr_configured;
        rx_src_hwaddr_icmpEchoServer_echosys_snsys_1 = rx_src_hwaddr;
        rx_dest_hwaddr_icmpEchoServer_echosys_snsys_1 = rx_dest_hwaddr;
        configured_ip_addr_icmpEchoServer_echosys_snsys_1 = configured_ip_addr;
        rx_icmp_last_icmpEchoServer_echosys_snsys_1 = rx_icmp_last;
    end
    always_comb begin
        CLK_icmpRecvParser_echosys_snsys_1 = CLK;
        RST_icmpRecvParser_echosys_snsys_1 = RST;
    end
    always_comb begin
        CLK_dummyio_echosys_snsys_1 = CLK;
        RST_dummyio_echosys_snsys_1 = RST;
    end
    always_comb begin
        CLK_randomReadAccessBuffer_echosys_snsys_1 = CLK;
        RST_randomReadAccessBuffer_echosys_snsys_1 = RST;
    end
    always_comb begin
        CLK_IcmpEchoMessageBlock_echosys_snsys_1 = CLK;
        RST_IcmpEchoMessageBlock_echosys_snsys_1 = RST;
    end
    always_comb begin
        CLK_icmpEchoServer_echosys_snsys_1 = CLK;
        RST_icmpEchoServer_echosys_snsys_1 = RST;
    end
endmodule
module TcpServerSystem_snsys_1 (
    input ufp_hwaddr_valid,
    input [47:0] ufp_hwaddr,
    input [31:0] ufp_tx_data,
    input [15:0] ufp_tx_total_length_data_only,
    input [31:0] config_src_addr,
    input dfp_rx_data_ready,
    output logic ufp_tx_data_ready,
    output logic debug_valid_srv,
    input config_valid,
    output logic [71:0] debug_data_srv,
    output logic dfp_rx_data_valid,
    input ufp_tx_data_valid,
    input ufp_tx_data_last,
    output logic [1:0] dfp_rx_data_strb,
    input [15:0] ufp_tx_checksum_data_only,
    output logic [31:0] dfp_rx_data,
    output logic [71:0] debug_data,
    output logic dfp_awvalid,
    output logic debug_valid,
    output logic [31:0] dfp_wdata,
    output logic [7:0] dfp_awlen,
    output logic dfp_wlast,
    output logic dfp_wvalid,
    input dfp_awready,
    input dfp_wready,
    input [31:0] ufp_dest_addr,
    output logic debug_valid_rcvparse,
    output logic ufp_ready,
    input ufp_valid,
    input ufp_last,
    input [15:0] ufp_total_length_data,
    input [31:0] ufp_src_addr,
    input [31:0] ufp_data,
    output logic [71:0] debug_data_rcvparse,
    input CLK,
    input RST
);
    logic config_valid_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic ufp_misc_valid_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [15:0] tx_window_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [31:0] ufp_src_addr_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [15:0] tx_urg_pointer_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic dfp_rx_data_ready_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic ufp_last_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [15:0] src_port_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [31:0] config_src_addr_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [47:0] destMacAddr_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [71:0] debug_data_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic tx_data_last_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic ufp_tx_data_last_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [47:0] dfp_hwaddr_macLoopBack_tcpsrvsys_snsys_1;
    logic [1:0] dfp_rx_data_strb_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic debug_valid_srv_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic rx_data_ready_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [15:0] ufp_total_length_data_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [31:0] rx_dest_addr_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [15:0] tx_checksum_data_only_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [7:0] dfp_awlen_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic CLK_macLoopBack_tcpsrvsys_snsys_1;
    logic [15:0] rx_checksum_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [15:0] rx_window_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [31:0] rx_seq_number_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [31:0] ack_number_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic RST_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic dfp_ready_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [15:0] window_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [15:0] checksum_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic dfp_no_data_payload_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [15:0] dest_port_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [15:0] config_src_port_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic ufp_tx_data_ready_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [15:0] window_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [15:0] dest_port_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [15:0] rx_dest_port_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [31:0] dfp_data_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic tx_data_ready_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic info_valid_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic tx_misc_valid_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic CLK_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [31:0] dfp_wdata_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [31:0] seq_number_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [31:0] dest_addr_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic ufp_data_ready_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [31:0] src_addr_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [31:0] tx_data_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [5:0] rx_flags_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic ufp_ready_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [31:0] rx_data_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [31:0] src_addr_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic RST_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [31:0] ufp_tx_data_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [15:0] urg_pointer_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic RST_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [31:0] ack_number_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [15:0] tx_total_length_data_only_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic dfp_awvalid_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic dfp_wlast_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic RST_macLoopBack_tcpsrvsys_snsys_1;
    logic [31:0] ufp_data_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic debug_valid_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic CLK_dummyio_tcpsrvsys_snsys_1;
    logic [31:0] tx_ack_number_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic RST_dummyio_tcpsrvsys_snsys_1;
    logic [15:0] urg_pointer_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [31:0] rx_src_addr_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic rx_misc_valid_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic tx_data_valid_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [15:0] checksum_data_only_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [15:0] ufp_tx_total_length_data_only_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic dfp_valid_macLoopBack_tcpsrvsys_snsys_1;
    logic [31:0] ufp_dest_addr_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [31:0] tx_src_addr_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [15:0] tx_dest_port_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic CLK_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic tx_misc_ready_macLoopBack_tcpsrvsys_snsys_1;
    logic [31:0] tx_seq_number_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic dfp_ready_macLoopBack_tcpsrvsys_snsys_1;
    logic ufp_hwaddr_valid_macLoopBack_tcpsrvsys_snsys_1;
    logic [71:0] debug_data_rcvparse_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic ufp_misc_ready_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic CLK_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [31:0] dfp_rx_data_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [15:0] payload_length_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic commandReady_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic info_ready_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [47:0] ufp_hwaddr_macLoopBack_tcpsrvsys_snsys_1;
    logic dfp_valid_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [5:0] flags_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [15:0] dummyout16_80_dummyio_tcpsrvsys_snsys_1;
    logic [31:0] tx_dest_addr_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [31:0] seq_number_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic ufp_valid_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [15:0] rx_urg_pointer_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [5:0] flags_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic rx_misc_ready_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [31:0] rx_ack_number_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic dfp_awready_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic tx_misc_valid_macLoopBack_tcpsrvsys_snsys_1;
    logic dfp_last_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic [15:0] rx_payload_length_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [15:0] rx_src_port_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic debug_valid_rcvparse_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic dfp_rx_data_valid_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic dfp_wready_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic ufp_data_valid_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic ufp_data_last_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [31:0] ufp_data_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic commandValid_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [15:0] src_port_TcpRecvParser_simTcpSrvSys_snsys_1;
    logic rx_data_valid_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic rx_no_data_payload_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [15:0] tx_src_port_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [71:0] debug_data_srv_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic rx_data_last_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic tx_misc_ready_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic ufp_tx_data_valid_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic [15:0] total_length_data_only_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [15:0] ufp_tx_checksum_data_only_SimpleTcpServer_simTcpSrvSys_snsys_1;
    logic dfp_wvalid_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [31:0] dest_addr_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    logic [5:0] tx_flags_SimpleTcpServer_simTcpSrvSys_snsys_1;

    macLoopBack_tcpsrvsys_snsys_1 macLoopBack_tcpsrvsys_snsys_1_inst (
        .CLK(CLK_macLoopBack_tcpsrvsys_snsys_1),
        .RST(RST_macLoopBack_tcpsrvsys_snsys_1),
        .ufp_hwaddr_valid(ufp_hwaddr_valid_macLoopBack_tcpsrvsys_snsys_1),
        .dfp_valid(dfp_valid_macLoopBack_tcpsrvsys_snsys_1),
        .dfp_ready(dfp_ready_macLoopBack_tcpsrvsys_snsys_1),
        .ufp_hwaddr(ufp_hwaddr_macLoopBack_tcpsrvsys_snsys_1),
        .dfp_hwaddr(dfp_hwaddr_macLoopBack_tcpsrvsys_snsys_1),
        .tx_misc_valid(tx_misc_valid_macLoopBack_tcpsrvsys_snsys_1),
        .tx_misc_ready(tx_misc_ready_macLoopBack_tcpsrvsys_snsys_1)
    );
    dummyio_tcpsrvsys_snsys_1 dummyio_tcpsrvsys_snsys_1_inst (
        .dummyout16_80(dummyout16_80_dummyio_tcpsrvsys_snsys_1),
        .CLK(CLK_dummyio_tcpsrvsys_snsys_1),
        .RST(RST_dummyio_tcpsrvsys_snsys_1)
    );
    SimpleTcpServer_simTcpSrvSys_snsys_1 SimpleTcpServer_simTcpSrvSys_snsys_1_inst (
        .CLK(CLK_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .RST(RST_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .config_valid(config_valid_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .config_src_port(config_src_port_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .config_src_addr(config_src_addr_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_src_addr(rx_src_addr_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_dest_addr(rx_dest_addr_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_no_data_payload(rx_no_data_payload_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_src_port(rx_src_port_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_dest_port(rx_dest_port_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_seq_number(rx_seq_number_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_ack_number(rx_ack_number_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_flags(rx_flags_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_window(rx_window_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_checksum(rx_checksum_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_urg_pointer(rx_urg_pointer_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_payload_length(rx_payload_length_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_misc_valid(rx_misc_valid_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_misc_ready(rx_misc_ready_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_data_valid(rx_data_valid_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_data_last(rx_data_last_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_data_ready(rx_data_ready_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .rx_data(rx_data_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .dfp_rx_data(dfp_rx_data_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .dfp_rx_data_strb(dfp_rx_data_strb_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .dfp_rx_data_valid(dfp_rx_data_valid_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .dfp_rx_data_ready(dfp_rx_data_ready_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .ufp_tx_data(ufp_tx_data_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .ufp_tx_data_valid(ufp_tx_data_valid_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .ufp_tx_data_last(ufp_tx_data_last_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .ufp_tx_data_ready(ufp_tx_data_ready_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .ufp_tx_checksum_data_only(ufp_tx_checksum_data_only_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .ufp_tx_total_length_data_only(ufp_tx_total_length_data_only_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_misc_valid(tx_misc_valid_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_misc_ready(tx_misc_ready_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_src_addr(tx_src_addr_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_dest_addr(tx_dest_addr_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_src_port(tx_src_port_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_dest_port(tx_dest_port_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_seq_number(tx_seq_number_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_ack_number(tx_ack_number_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_flags(tx_flags_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_window(tx_window_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_urg_pointer(tx_urg_pointer_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_checksum_data_only(tx_checksum_data_only_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_total_length_data_only(tx_total_length_data_only_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_data_valid(tx_data_valid_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_data_last(tx_data_last_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_data(tx_data_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .tx_data_ready(tx_data_ready_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .debug_valid_srv(debug_valid_srv_SimpleTcpServer_simTcpSrvSys_snsys_1),
        .debug_data_srv(debug_data_srv_SimpleTcpServer_simTcpSrvSys_snsys_1)
    );
    TcpPacketSendBlock_simTcpSrvSys_snsys_1 TcpPacketSendBlock_simTcpSrvSys_snsys_1_inst (
        .commandValid(commandValid_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .commandReady(commandReady_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .destMacAddr(destMacAddr_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .debug_data(debug_data_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .ufp_data_valid(ufp_data_valid_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .src_addr(src_addr_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .dest_addr(dest_addr_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .ufp_data(ufp_data_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .window(window_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .ack_number(ack_number_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .urg_pointer(urg_pointer_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .src_port(src_port_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .debug_valid(debug_valid_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .flags(flags_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .seq_number(seq_number_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .total_length_data_only(total_length_data_only_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .ufp_data_last(ufp_data_last_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .checksum_data_only(checksum_data_only_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .dest_port(dest_port_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .ufp_misc_ready(ufp_misc_ready_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .ufp_data_ready(ufp_data_ready_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .ufp_misc_valid(ufp_misc_valid_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .dfp_awvalid(dfp_awvalid_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .dfp_wdata(dfp_wdata_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .dfp_awlen(dfp_awlen_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .dfp_wlast(dfp_wlast_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .dfp_wvalid(dfp_wvalid_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .dfp_awready(dfp_awready_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .dfp_wready(dfp_wready_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .CLK(CLK_TcpPacketSendBlock_simTcpSrvSys_snsys_1),
        .RST(RST_TcpPacketSendBlock_simTcpSrvSys_snsys_1)
    );
    TcpRecvParser_simTcpSrvSys_snsys_1 TcpRecvParser_simTcpSrvSys_snsys_1_inst (
        .CLK(CLK_TcpRecvParser_simTcpSrvSys_snsys_1),
        .RST(RST_TcpRecvParser_simTcpSrvSys_snsys_1),
        .ufp_valid(ufp_valid_TcpRecvParser_simTcpSrvSys_snsys_1),
        .ufp_last(ufp_last_TcpRecvParser_simTcpSrvSys_snsys_1),
        .ufp_ready(ufp_ready_TcpRecvParser_simTcpSrvSys_snsys_1),
        .ufp_data(ufp_data_TcpRecvParser_simTcpSrvSys_snsys_1),
        .ufp_src_addr(ufp_src_addr_TcpRecvParser_simTcpSrvSys_snsys_1),
        .ufp_dest_addr(ufp_dest_addr_TcpRecvParser_simTcpSrvSys_snsys_1),
        .ufp_total_length_data(ufp_total_length_data_TcpRecvParser_simTcpSrvSys_snsys_1),
        .dfp_valid(dfp_valid_TcpRecvParser_simTcpSrvSys_snsys_1),
        .dfp_last(dfp_last_TcpRecvParser_simTcpSrvSys_snsys_1),
        .dfp_data(dfp_data_TcpRecvParser_simTcpSrvSys_snsys_1),
        .dfp_ready(dfp_ready_TcpRecvParser_simTcpSrvSys_snsys_1),
        .src_addr(src_addr_TcpRecvParser_simTcpSrvSys_snsys_1),
        .dest_addr(dest_addr_TcpRecvParser_simTcpSrvSys_snsys_1),
        .dfp_no_data_payload(dfp_no_data_payload_TcpRecvParser_simTcpSrvSys_snsys_1),
        .src_port(src_port_TcpRecvParser_simTcpSrvSys_snsys_1),
        .dest_port(dest_port_TcpRecvParser_simTcpSrvSys_snsys_1),
        .seq_number(seq_number_TcpRecvParser_simTcpSrvSys_snsys_1),
        .ack_number(ack_number_TcpRecvParser_simTcpSrvSys_snsys_1),
        .flags(flags_TcpRecvParser_simTcpSrvSys_snsys_1),
        .window(window_TcpRecvParser_simTcpSrvSys_snsys_1),
        .checksum(checksum_TcpRecvParser_simTcpSrvSys_snsys_1),
        .urg_pointer(urg_pointer_TcpRecvParser_simTcpSrvSys_snsys_1),
        .payload_length(payload_length_TcpRecvParser_simTcpSrvSys_snsys_1),
        .info_ready(info_ready_TcpRecvParser_simTcpSrvSys_snsys_1),
        .info_valid(info_valid_TcpRecvParser_simTcpSrvSys_snsys_1),
        .debug_valid_rcvparse(debug_valid_rcvparse_TcpRecvParser_simTcpSrvSys_snsys_1),
        .debug_data_rcvparse(debug_data_rcvparse_TcpRecvParser_simTcpSrvSys_snsys_1)
    );
    always_comb begin
        info_ready_TcpRecvParser_simTcpSrvSys_snsys_1 = rx_misc_ready_SimpleTcpServer_simTcpSrvSys_snsys_1;
        dfp_ready_TcpRecvParser_simTcpSrvSys_snsys_1 = rx_data_ready_SimpleTcpServer_simTcpSrvSys_snsys_1;
        commandValid_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = dfp_valid_macLoopBack_tcpsrvsys_snsys_1;
        destMacAddr_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = dfp_hwaddr_macLoopBack_tcpsrvsys_snsys_1;
        tx_misc_valid_macLoopBack_tcpsrvsys_snsys_1 = tx_misc_valid_SimpleTcpServer_simTcpSrvSys_snsys_1;
        rx_data_valid_SimpleTcpServer_simTcpSrvSys_snsys_1 = dfp_valid_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_data_last_SimpleTcpServer_simTcpSrvSys_snsys_1 = dfp_last_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_data_SimpleTcpServer_simTcpSrvSys_snsys_1 = dfp_data_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_src_addr_SimpleTcpServer_simTcpSrvSys_snsys_1 = src_addr_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_dest_addr_SimpleTcpServer_simTcpSrvSys_snsys_1 = dest_addr_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_no_data_payload_SimpleTcpServer_simTcpSrvSys_snsys_1 = dfp_no_data_payload_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_src_port_SimpleTcpServer_simTcpSrvSys_snsys_1 = src_port_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_dest_port_SimpleTcpServer_simTcpSrvSys_snsys_1 = dest_port_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_seq_number_SimpleTcpServer_simTcpSrvSys_snsys_1 = seq_number_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_ack_number_SimpleTcpServer_simTcpSrvSys_snsys_1 = ack_number_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_flags_SimpleTcpServer_simTcpSrvSys_snsys_1 = flags_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_window_SimpleTcpServer_simTcpSrvSys_snsys_1 = window_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_checksum_SimpleTcpServer_simTcpSrvSys_snsys_1 = checksum_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_urg_pointer_SimpleTcpServer_simTcpSrvSys_snsys_1 = urg_pointer_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_payload_length_SimpleTcpServer_simTcpSrvSys_snsys_1 = payload_length_TcpRecvParser_simTcpSrvSys_snsys_1;
        rx_misc_valid_SimpleTcpServer_simTcpSrvSys_snsys_1 = info_valid_TcpRecvParser_simTcpSrvSys_snsys_1;
        ufp_misc_valid_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_misc_valid_SimpleTcpServer_simTcpSrvSys_snsys_1;
        src_addr_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_src_addr_SimpleTcpServer_simTcpSrvSys_snsys_1;
        dest_addr_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_dest_addr_SimpleTcpServer_simTcpSrvSys_snsys_1;
        src_port_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_src_port_SimpleTcpServer_simTcpSrvSys_snsys_1;
        dest_port_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_dest_port_SimpleTcpServer_simTcpSrvSys_snsys_1;
        seq_number_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_seq_number_SimpleTcpServer_simTcpSrvSys_snsys_1;
        ack_number_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_ack_number_SimpleTcpServer_simTcpSrvSys_snsys_1;
        flags_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_flags_SimpleTcpServer_simTcpSrvSys_snsys_1;
        window_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_window_SimpleTcpServer_simTcpSrvSys_snsys_1;
        urg_pointer_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_urg_pointer_SimpleTcpServer_simTcpSrvSys_snsys_1;
        checksum_data_only_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_checksum_data_only_SimpleTcpServer_simTcpSrvSys_snsys_1;
        total_length_data_only_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_total_length_data_only_SimpleTcpServer_simTcpSrvSys_snsys_1;
        ufp_data_valid_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_data_valid_SimpleTcpServer_simTcpSrvSys_snsys_1;
        ufp_data_last_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_data_last_SimpleTcpServer_simTcpSrvSys_snsys_1;
        ufp_data_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = tx_data_SimpleTcpServer_simTcpSrvSys_snsys_1;
        tx_misc_ready_SimpleTcpServer_simTcpSrvSys_snsys_1 = ufp_misc_ready_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
        tx_data_ready_SimpleTcpServer_simTcpSrvSys_snsys_1 = ufp_data_ready_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
        config_src_port_SimpleTcpServer_simTcpSrvSys_snsys_1 = dummyout16_80_dummyio_tcpsrvsys_snsys_1;
        dfp_ready_macLoopBack_tcpsrvsys_snsys_1 = commandReady_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
        tx_misc_ready_macLoopBack_tcpsrvsys_snsys_1 = ufp_misc_ready_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
    end
    always_comb begin
        ufp_hwaddr_valid_macLoopBack_tcpsrvsys_snsys_1 = ufp_hwaddr_valid;
        ufp_hwaddr_macLoopBack_tcpsrvsys_snsys_1 = ufp_hwaddr;
        ufp_tx_data_SimpleTcpServer_simTcpSrvSys_snsys_1 = ufp_tx_data;
        ufp_tx_total_length_data_only_SimpleTcpServer_simTcpSrvSys_snsys_1 = ufp_tx_total_length_data_only;
        config_src_addr_SimpleTcpServer_simTcpSrvSys_snsys_1 = config_src_addr;
        dfp_rx_data_ready_SimpleTcpServer_simTcpSrvSys_snsys_1 = dfp_rx_data_ready;
        ufp_tx_data_ready = ufp_tx_data_ready_SimpleTcpServer_simTcpSrvSys_snsys_1;
        debug_valid_srv = debug_valid_srv_SimpleTcpServer_simTcpSrvSys_snsys_1;
        config_valid_SimpleTcpServer_simTcpSrvSys_snsys_1 = config_valid;
        debug_data_srv = debug_data_srv_SimpleTcpServer_simTcpSrvSys_snsys_1;
        dfp_rx_data_valid = dfp_rx_data_valid_SimpleTcpServer_simTcpSrvSys_snsys_1;
        ufp_tx_data_valid_SimpleTcpServer_simTcpSrvSys_snsys_1 = ufp_tx_data_valid;
        ufp_tx_data_last_SimpleTcpServer_simTcpSrvSys_snsys_1 = ufp_tx_data_last;
        dfp_rx_data_strb = dfp_rx_data_strb_SimpleTcpServer_simTcpSrvSys_snsys_1;
        ufp_tx_checksum_data_only_SimpleTcpServer_simTcpSrvSys_snsys_1 = ufp_tx_checksum_data_only;
        dfp_rx_data = dfp_rx_data_SimpleTcpServer_simTcpSrvSys_snsys_1;
        debug_data = debug_data_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
        dfp_awvalid = dfp_awvalid_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
        debug_valid = debug_valid_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
        dfp_wdata = dfp_wdata_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
        dfp_awlen = dfp_awlen_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
        dfp_wlast = dfp_wlast_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
        dfp_wvalid = dfp_wvalid_TcpPacketSendBlock_simTcpSrvSys_snsys_1;
        dfp_awready_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = dfp_awready;
        dfp_wready_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = dfp_wready;
        ufp_dest_addr_TcpRecvParser_simTcpSrvSys_snsys_1 = ufp_dest_addr;
        debug_valid_rcvparse = debug_valid_rcvparse_TcpRecvParser_simTcpSrvSys_snsys_1;
        ufp_ready = ufp_ready_TcpRecvParser_simTcpSrvSys_snsys_1;
        ufp_valid_TcpRecvParser_simTcpSrvSys_snsys_1 = ufp_valid;
        ufp_last_TcpRecvParser_simTcpSrvSys_snsys_1 = ufp_last;
        ufp_total_length_data_TcpRecvParser_simTcpSrvSys_snsys_1 = ufp_total_length_data;
        ufp_src_addr_TcpRecvParser_simTcpSrvSys_snsys_1 = ufp_src_addr;
        ufp_data_TcpRecvParser_simTcpSrvSys_snsys_1 = ufp_data;
        debug_data_rcvparse = debug_data_rcvparse_TcpRecvParser_simTcpSrvSys_snsys_1;
    end
    always_comb begin
        CLK_macLoopBack_tcpsrvsys_snsys_1 = CLK;
        RST_macLoopBack_tcpsrvsys_snsys_1 = RST;
    end
    always_comb begin
        CLK_dummyio_tcpsrvsys_snsys_1 = CLK;
        RST_dummyio_tcpsrvsys_snsys_1 = RST;
    end
    always_comb begin
        CLK_SimpleTcpServer_simTcpSrvSys_snsys_1 = CLK;
        RST_SimpleTcpServer_simTcpSrvSys_snsys_1 = RST;
    end
    always_comb begin
        CLK_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = CLK;
        RST_TcpPacketSendBlock_simTcpSrvSys_snsys_1 = RST;
    end
    always_comb begin
        CLK_TcpRecvParser_simTcpSrvSys_snsys_1 = CLK;
        RST_TcpRecvParser_simTcpSrvSys_snsys_1 = RST;
    end
endmodule
module linkLocalIpClaimerSystem_snsys_1 (
    output logic ufp_wready,
    input ufp_wvalid,
    input [31:0] ufp_wdata,
    input ufp_wlast,
    output logic dfp_awvalid,
    output logic [31:0] dfp_wdata,
    output logic [7:0] dfp_awlen,
    output logic dfp_wlast,
    output logic dfp_wvalid,
    input dfp_awready,
    input dfp_wready,
    input start,
    output logic [31:0] ip_addr,
    output logic ip_addr_valid,
    input CLK,
    input RST
);
    logic rx_full_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic commandReady_ArpMessageBlock_llipv4sys_snsys_1;
    logic [7:0] dfp_awlen_ArpMessageBlock_llipv4sys_snsys_1;
    logic tx_etherFrameCommandValid_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic rx_arvalid_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic [31:0] ufp_wdata_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic [15:0] tx_etherType_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic [12:0] stored_length_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic RST_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic rx_arready_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic [47:0] tx_destMacAddr_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic dfp_awvalid_ArpMessageBlock_llipv4sys_snsys_1;
    logic ufp_wvalid_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic [12:0] rx_araddr_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic [47:0] destMacAddr_ArpMessageBlock_llipv4sys_snsys_1;
    logic [12:0] dfp_araddr_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic rx_rvalid_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic [71:0] dummy72_2_dummyio_llipv4sys_snsys_1;
    logic dfp_rinvalid_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic dfp_wlast_ArpMessageBlock_llipv4sys_snsys_1;
    logic [15:0] etherType_ArpMessageBlock_llipv4sys_snsys_1;
    logic dfp_wvalid_ArpMessageBlock_llipv4sys_snsys_1;
    logic ufp_wready_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic tx_etherFrameCommandReady_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic [31:0] senderProtAddr_ArpMessageBlock_llipv4sys_snsys_1;
    logic dfp_arready_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic dfp_awready_ArpMessageBlock_llipv4sys_snsys_1;
    logic RST_ArpMessageBlock_llipv4sys_snsys_1;
    logic [31:0] tx_senderIpAddr_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic tx_arpReqCommandReady_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic start_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic CLK_dummyio_llipv4sys_snsys_1;
    logic arp_command_valid_ArpMessageBlock_llipv4sys_snsys_1;
    logic dummy1_2_dummyio_llipv4sys_snsys_1;
    logic ufp_wlast_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic CLK_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic rx_flush_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic [12:0] dummy13_1_dummyio_llipv4sys_snsys_1;
    logic rx_rinvalid_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic dummy1_1_dummyio_llipv4sys_snsys_1;
    logic ip_addr_valid_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic [71:0] debug_data_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic dfp_wready_ArpMessageBlock_llipv4sys_snsys_1;
    logic [31:0] dfp_wdata_ArpMessageBlock_llipv4sys_snsys_1;
    logic dfp_rvalid_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic [31:0] targetProtAddr_ArpMessageBlock_llipv4sys_snsys_1;
    logic dfp_full_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic tx_arpReqCommandValid_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic [31:0] tx_targetIpAddr_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic debug_valid_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic RST_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic [71:0] dummy72_1_dummyio_llipv4sys_snsys_1;
    logic CLK_ArpMessageBlock_llipv4sys_snsys_1;
    logic [71:0] debug_data_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic dfp_arvalid_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic [31:0] dfp_rdata_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic debug_valid_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic commandValid_ArpMessageBlock_llipv4sys_snsys_1;
    logic [15:0] opcode_ArpMessageBlock_llipv4sys_snsys_1;
    logic arp_command_ready_ArpMessageBlock_llipv4sys_snsys_1;
    logic [31:0] rx_rdata_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic [31:0] ip_addr_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic RST_dummyio_llipv4sys_snsys_1;
    logic CLK_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic [15:0] tx_opcode_LinkLocalIpClaimer_llipv4sys_snsys_1;
    logic dfp_flush_randomReadAccessBuffer_llipv4sys_snsys_1;

    randomReadAccessBuffer_llipv4sys_snsys_1 randomReadAccessBuffer_llipv4sys_snsys_1_inst (
        .CLK(CLK_randomReadAccessBuffer_llipv4sys_snsys_1),
        .RST(RST_randomReadAccessBuffer_llipv4sys_snsys_1),
        .ufp_wvalid(ufp_wvalid_randomReadAccessBuffer_llipv4sys_snsys_1),
        .ufp_wlast(ufp_wlast_randomReadAccessBuffer_llipv4sys_snsys_1),
        .ufp_wdata(ufp_wdata_randomReadAccessBuffer_llipv4sys_snsys_1),
        .ufp_wready(ufp_wready_randomReadAccessBuffer_llipv4sys_snsys_1),
        .dfp_araddr(dfp_araddr_randomReadAccessBuffer_llipv4sys_snsys_1),
        .dfp_arvalid(dfp_arvalid_randomReadAccessBuffer_llipv4sys_snsys_1),
        .dfp_arready(dfp_arready_randomReadAccessBuffer_llipv4sys_snsys_1),
        .dfp_rvalid(dfp_rvalid_randomReadAccessBuffer_llipv4sys_snsys_1),
        .dfp_rinvalid(dfp_rinvalid_randomReadAccessBuffer_llipv4sys_snsys_1),
        .dfp_rdata(dfp_rdata_randomReadAccessBuffer_llipv4sys_snsys_1),
        .dfp_flush(dfp_flush_randomReadAccessBuffer_llipv4sys_snsys_1),
        .dfp_full(dfp_full_randomReadAccessBuffer_llipv4sys_snsys_1),
        .stored_length(stored_length_randomReadAccessBuffer_llipv4sys_snsys_1),
        .debug_valid(debug_valid_randomReadAccessBuffer_llipv4sys_snsys_1),
        .debug_data(debug_data_randomReadAccessBuffer_llipv4sys_snsys_1)
    );
    ArpMessageBlock_llipv4sys_snsys_1 ArpMessageBlock_llipv4sys_snsys_1_inst (
        .arp_command_valid(arp_command_valid_ArpMessageBlock_llipv4sys_snsys_1),
        .arp_command_ready(arp_command_ready_ArpMessageBlock_llipv4sys_snsys_1),
        .opcode(opcode_ArpMessageBlock_llipv4sys_snsys_1),
        .senderProtAddr(senderProtAddr_ArpMessageBlock_llipv4sys_snsys_1),
        .targetProtAddr(targetProtAddr_ArpMessageBlock_llipv4sys_snsys_1),
        .dfp_awvalid(dfp_awvalid_ArpMessageBlock_llipv4sys_snsys_1),
        .dfp_wdata(dfp_wdata_ArpMessageBlock_llipv4sys_snsys_1),
        .dfp_awlen(dfp_awlen_ArpMessageBlock_llipv4sys_snsys_1),
        .dfp_wlast(dfp_wlast_ArpMessageBlock_llipv4sys_snsys_1),
        .dfp_wvalid(dfp_wvalid_ArpMessageBlock_llipv4sys_snsys_1),
        .dfp_awready(dfp_awready_ArpMessageBlock_llipv4sys_snsys_1),
        .dfp_wready(dfp_wready_ArpMessageBlock_llipv4sys_snsys_1),
        .commandValid(commandValid_ArpMessageBlock_llipv4sys_snsys_1),
        .etherType(etherType_ArpMessageBlock_llipv4sys_snsys_1),
        .commandReady(commandReady_ArpMessageBlock_llipv4sys_snsys_1),
        .destMacAddr(destMacAddr_ArpMessageBlock_llipv4sys_snsys_1),
        .CLK(CLK_ArpMessageBlock_llipv4sys_snsys_1),
        .RST(RST_ArpMessageBlock_llipv4sys_snsys_1)
    );
    dummyio_llipv4sys_snsys_1 dummyio_llipv4sys_snsys_1_inst (
        .dummy1_1(dummy1_1_dummyio_llipv4sys_snsys_1),
        .dummy1_2(dummy1_2_dummyio_llipv4sys_snsys_1),
        .dummy13_1(dummy13_1_dummyio_llipv4sys_snsys_1),
        .dummy72_1(dummy72_1_dummyio_llipv4sys_snsys_1),
        .dummy72_2(dummy72_2_dummyio_llipv4sys_snsys_1),
        .CLK(CLK_dummyio_llipv4sys_snsys_1),
        .RST(RST_dummyio_llipv4sys_snsys_1)
    );
    LinkLocalIpClaimer_llipv4sys_snsys_1 LinkLocalIpClaimer_llipv4sys_snsys_1_inst (
        .CLK(CLK_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .RST(RST_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .start(start_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .tx_destMacAddr(tx_destMacAddr_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .tx_etherType(tx_etherType_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .tx_opcode(tx_opcode_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .tx_senderIpAddr(tx_senderIpAddr_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .tx_targetIpAddr(tx_targetIpAddr_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .tx_etherFrameCommandValid(tx_etherFrameCommandValid_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .tx_arpReqCommandValid(tx_arpReqCommandValid_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .tx_etherFrameCommandReady(tx_etherFrameCommandReady_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .tx_arpReqCommandReady(tx_arpReqCommandReady_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .rx_araddr(rx_araddr_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .rx_arvalid(rx_arvalid_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .rx_arready(rx_arready_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .rx_rvalid(rx_rvalid_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .rx_rinvalid(rx_rinvalid_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .rx_rdata(rx_rdata_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .rx_flush(rx_flush_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .rx_full(rx_full_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .debug_valid(debug_valid_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .debug_data(debug_data_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .ip_addr_valid(ip_addr_valid_LinkLocalIpClaimer_llipv4sys_snsys_1),
        .ip_addr(ip_addr_LinkLocalIpClaimer_llipv4sys_snsys_1)
    );
    always_comb begin
        tx_etherFrameCommandReady_LinkLocalIpClaimer_llipv4sys_snsys_1 = commandReady_ArpMessageBlock_llipv4sys_snsys_1;
        tx_arpReqCommandReady_LinkLocalIpClaimer_llipv4sys_snsys_1 = arp_command_ready_ArpMessageBlock_llipv4sys_snsys_1;
        dummy72_2_dummyio_llipv4sys_snsys_1 = debug_data_LinkLocalIpClaimer_llipv4sys_snsys_1;
        dummy1_2_dummyio_llipv4sys_snsys_1 = debug_valid_LinkLocalIpClaimer_llipv4sys_snsys_1;
        destMacAddr_ArpMessageBlock_llipv4sys_snsys_1 = tx_destMacAddr_LinkLocalIpClaimer_llipv4sys_snsys_1;
        etherType_ArpMessageBlock_llipv4sys_snsys_1 = tx_etherType_LinkLocalIpClaimer_llipv4sys_snsys_1;
        opcode_ArpMessageBlock_llipv4sys_snsys_1 = tx_opcode_LinkLocalIpClaimer_llipv4sys_snsys_1;
        senderProtAddr_ArpMessageBlock_llipv4sys_snsys_1 = tx_senderIpAddr_LinkLocalIpClaimer_llipv4sys_snsys_1;
        targetProtAddr_ArpMessageBlock_llipv4sys_snsys_1 = tx_targetIpAddr_LinkLocalIpClaimer_llipv4sys_snsys_1;
        commandValid_ArpMessageBlock_llipv4sys_snsys_1 = tx_etherFrameCommandValid_LinkLocalIpClaimer_llipv4sys_snsys_1;
        arp_command_valid_ArpMessageBlock_llipv4sys_snsys_1 = tx_arpReqCommandValid_LinkLocalIpClaimer_llipv4sys_snsys_1;
        dfp_araddr_randomReadAccessBuffer_llipv4sys_snsys_1 = rx_araddr_LinkLocalIpClaimer_llipv4sys_snsys_1;
        dfp_flush_randomReadAccessBuffer_llipv4sys_snsys_1 = rx_flush_LinkLocalIpClaimer_llipv4sys_snsys_1;
        dfp_arvalid_randomReadAccessBuffer_llipv4sys_snsys_1 = rx_arvalid_LinkLocalIpClaimer_llipv4sys_snsys_1;
        rx_arready_LinkLocalIpClaimer_llipv4sys_snsys_1 = dfp_arready_randomReadAccessBuffer_llipv4sys_snsys_1;
        rx_rvalid_LinkLocalIpClaimer_llipv4sys_snsys_1 = dfp_rvalid_randomReadAccessBuffer_llipv4sys_snsys_1;
        rx_rinvalid_LinkLocalIpClaimer_llipv4sys_snsys_1 = dfp_rinvalid_randomReadAccessBuffer_llipv4sys_snsys_1;
        rx_rdata_LinkLocalIpClaimer_llipv4sys_snsys_1 = dfp_rdata_randomReadAccessBuffer_llipv4sys_snsys_1;
        rx_full_LinkLocalIpClaimer_llipv4sys_snsys_1 = dfp_full_randomReadAccessBuffer_llipv4sys_snsys_1;
        dummy72_1_dummyio_llipv4sys_snsys_1 = debug_data_randomReadAccessBuffer_llipv4sys_snsys_1;
        dummy1_1_dummyio_llipv4sys_snsys_1 = debug_valid_randomReadAccessBuffer_llipv4sys_snsys_1;
        dummy13_1_dummyio_llipv4sys_snsys_1 = stored_length_randomReadAccessBuffer_llipv4sys_snsys_1;
    end
    always_comb begin
        ufp_wready = ufp_wready_randomReadAccessBuffer_llipv4sys_snsys_1;
        ufp_wvalid_randomReadAccessBuffer_llipv4sys_snsys_1 = ufp_wvalid;
        ufp_wdata_randomReadAccessBuffer_llipv4sys_snsys_1 = ufp_wdata;
        ufp_wlast_randomReadAccessBuffer_llipv4sys_snsys_1 = ufp_wlast;
        dfp_awvalid = dfp_awvalid_ArpMessageBlock_llipv4sys_snsys_1;
        dfp_wdata = dfp_wdata_ArpMessageBlock_llipv4sys_snsys_1;
        dfp_awlen = dfp_awlen_ArpMessageBlock_llipv4sys_snsys_1;
        dfp_wlast = dfp_wlast_ArpMessageBlock_llipv4sys_snsys_1;
        dfp_wvalid = dfp_wvalid_ArpMessageBlock_llipv4sys_snsys_1;
        dfp_awready_ArpMessageBlock_llipv4sys_snsys_1 = dfp_awready;
        dfp_wready_ArpMessageBlock_llipv4sys_snsys_1 = dfp_wready;
        start_LinkLocalIpClaimer_llipv4sys_snsys_1 = start;
        ip_addr = ip_addr_LinkLocalIpClaimer_llipv4sys_snsys_1;
        ip_addr_valid = ip_addr_valid_LinkLocalIpClaimer_llipv4sys_snsys_1;
    end
    always_comb begin
        CLK_randomReadAccessBuffer_llipv4sys_snsys_1 = CLK;
        RST_randomReadAccessBuffer_llipv4sys_snsys_1 = RST;
    end
    always_comb begin
        CLK_ArpMessageBlock_llipv4sys_snsys_1 = CLK;
        RST_ArpMessageBlock_llipv4sys_snsys_1 = RST;
    end
    always_comb begin
        CLK_dummyio_llipv4sys_snsys_1 = CLK;
        RST_dummyio_llipv4sys_snsys_1 = RST;
    end
    always_comb begin
        CLK_LinkLocalIpClaimer_llipv4sys_snsys_1 = CLK;
        RST_LinkLocalIpClaimer_llipv4sys_snsys_1 = RST;
    end
endmodule
module SampleHttpResponseGenerator_snsys_1 (
    input CLK,
    input RST,
    input rx_valid,
    output logic rx_ready,
    input [31:0] rx_data,
    input [1:0] rx_strb,
    output logic tx_valid,
    output logic tx_last,
    input tx_ready,
    output logic [31:0] tx_data,
    output logic [15:0] tx_checksum,
    output logic [15:0] tx_total_length
);
    localparam init = 0;
    localparam sending = 1;

    reg state;
    logic prev_rx_valid;
    logic [31:0] counter;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                init: begin
                    if ((prev_rx_valid & (~rx_valid))) begin
                        state <= sending;
                    end
                end
                sending: begin
                    if ((tx_ready & tx_last)) begin
                        state <= init;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        tx_checksum = 16'd36710;
        tx_total_length = 16'd273;
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            counter <= 0;
            prev_rx_valid <= 0;
        end else begin
            prev_rx_valid <= rx_valid;
            if ((state == init)) begin
                counter <= 32'd0;
            end else begin
                if ((tx_valid & tx_ready)) begin
                    counter <= (counter + 1);
                end
            end
        end
    end
    always_comb begin
        tx_valid = (state == sending);
        tx_last = (counter == 68);
        rx_ready = 1;
    end
    always_comb begin
        if ((counter == 0)) begin
            tx_data = 32'd1347703880;
        end else if ((counter == 1)) begin
            tx_data = 32'd825110831;
        end else if ((counter == 2)) begin
            tx_data = 32'd808464928;
        end else if ((counter == 3)) begin
            tx_data = 32'd1866664461;
        end else if ((counter == 4)) begin
            tx_data = 32'd1852142702;
        end else if ((counter == 5)) begin
            tx_data = 32'd2035559796;
        end else if ((counter == 6)) begin
            tx_data = 32'd540697968;
        end else if ((counter == 7)) begin
            tx_data = 32'd1954047348;
        end else if ((counter == 8)) begin
            tx_data = 32'd1836345391;
        end else if ((counter == 9)) begin
            tx_data = 32'd540745836;
        end else if ((counter == 10)) begin
            tx_data = 32'd1918986339;
        end else if ((counter == 11)) begin
            tx_data = 32'd1031038323;
        end else if ((counter == 12)) begin
            tx_data = 32'd1093489493;
        end else if ((counter == 13)) begin
            tx_data = 32'd1229538131;
        end else if ((counter == 14)) begin
            tx_data = 32'd1866664461;
        end else if ((counter == 15)) begin
            tx_data = 32'd1852142702;
        end else if ((counter == 16)) begin
            tx_data = 32'd1699491188;
        end else if ((counter == 17)) begin
            tx_data = 32'd1752459118;
        end else if ((counter == 18)) begin
            tx_data = 32'd959520826;
        end else if ((counter == 19)) begin
            tx_data = 32'd218762546;
        end else if ((counter == 20)) begin
            tx_data = 32'd1143028746;
        end else if ((counter == 21)) begin
            tx_data = 32'd1498694479;
        end else if ((counter == 22)) begin
            tx_data = 32'd1746945360;
        end else if ((counter == 23)) begin
            tx_data = 32'd1047293300;
        end else if ((counter == 24)) begin
            tx_data = 32'd1748765197;
        end else if ((counter == 25)) begin
            tx_data = 32'd1047293300;
        end else if ((counter == 26)) begin
            tx_data = 32'd168626701;
        end else if ((counter == 27)) begin
            tx_data = 32'd1634035772;
        end else if ((counter == 28)) begin
            tx_data = 32'd168640100;
        end else if ((counter == 29)) begin
            tx_data = 32'd538976288;
        end else if ((counter == 30)) begin
            tx_data = 32'd1953068092;
        end else if ((counter == 31)) begin
            tx_data = 32'd1396598124;
        end else if ((counter == 32)) begin
            tx_data = 32'd1819307361;
        end else if ((counter == 33)) begin
            tx_data = 32'd1949252709;
        end else if ((counter == 34)) begin
            tx_data = 32'd1701606505;
        end else if ((counter == 35)) begin
            tx_data = 32'd1007291710;
        end else if ((counter == 36)) begin
            tx_data = 32'd1634035759;
        end else if ((counter == 37)) begin
            tx_data = 32'd168640100;
        end else if ((counter == 38)) begin
            tx_data = 32'd1648101901;
        end else if ((counter == 39)) begin
            tx_data = 32'd1048142959;
        end else if ((counter == 40)) begin
            tx_data = 32'd538970637;
        end else if ((counter == 41)) begin
            tx_data = 32'd1748770848;
        end else if ((counter == 42)) begin
            tx_data = 32'd1699233329;
        end else if ((counter == 43)) begin
            tx_data = 32'd544173164;
        end else if ((counter == 44)) begin
            tx_data = 32'd1836020326;
        end else if ((counter == 45)) begin
            tx_data = 32'd1196443168;
        end else if ((counter == 46)) begin
            tx_data = 32'd1747926081;
        end else if ((counter == 47)) begin
            tx_data = 32'd168640049;
        end else if ((counter == 48)) begin
            tx_data = 32'd538976288;
        end else if ((counter == 49)) begin
            tx_data = 32'd1886216563;
        end else if ((counter == 50)) begin
            tx_data = 32'd1746953580;
        end else if ((counter == 51)) begin
            tx_data = 32'd543976820;
        end else if ((counter == 52)) begin
            tx_data = 32'd544370534;
        end else if ((counter == 53)) begin
            tx_data = 32'd1347703880;
        end else if ((counter == 54)) begin
            tx_data = 32'd1919251232;
        end else if ((counter == 55)) begin
            tx_data = 32'd544367990;
        end else if ((counter == 56)) begin
            tx_data = 32'd1701733735;
        end else if ((counter == 57)) begin
            tx_data = 32'd1702125938;
        end else if ((counter == 58)) begin
            tx_data = 32'd2036473956;
        end else if ((counter == 59)) begin
            tx_data = 32'd1919243808;
        end else if ((counter == 60)) begin
            tx_data = 32'd1735355497;
        end else if ((counter == 61)) begin
            tx_data = 32'd1953067607;
        end else if ((counter == 62)) begin
            tx_data = 32'd1781428837;
        end else if ((counter == 63)) begin
            tx_data = 32'd1007291756;
        end else if ((counter == 64)) begin
            tx_data = 32'd1685021231;
        end else if ((counter == 65)) begin
            tx_data = 32'd168640121;
        end else if ((counter == 66)) begin
            tx_data = 32'd792463885;
        end else if ((counter == 67)) begin
            tx_data = 32'd1819112552;
        end else if ((counter == 68)) begin
            tx_data = 32'd62;
        end else begin
            tx_data = 0;
        end
    end
endmodule
module fifoOnBram_icmp_snsys_1 (
    input CLK,
    input RST,
    input wvalid,
    input wlast,
    output logic wready,
    input [31:0] wdata,
    output logic rvalid,
    output logic rlast,
    input rready,
    output logic [31:0] rdata
);
    logic rincr;
    logic full;
    logic enread;
    logic empty;
    logic [32:0] din;
    logic [7:0] rptrincr;
    logic [7:0] ptrincr;
    logic [7:0] addrout;
    logic wincr;
    logic [7:0] raddr;
    logic enwrite;
    logic [7:0] addrin;
    logic [7:0] wptr;
    logic [7:0] prevwptr;
    logic [32:0] dout_ramSdpRfInst_;
    logic [7:0] rptr;

    ram_sdp_rf #(
        .addrlen(8),
        .datawid(33)
    ) _instramSdpRfInst_ (
        .clk(CLK),
        .enread(enread),
        .enwrite(enwrite),
        .addrin(addrin),
        .addrout(addrout),
        .din(din),
        .dout(dout_ramSdpRfInst_)
    );
    always_comb begin
        ptrincr = 8'd1;
    end
    always_comb begin
        rincr = rready;
        rvalid = (~empty);
        wincr = wvalid;
        wready = (~full);
    end
    always_comb begin
        empty = (prevwptr == rptr);
        full = ((wptr + ptrincr) == rptr);
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            rptrincr <= 1;
        end else begin
            if ((rincr & (~empty))) begin
                rptrincr <= (rptrincr + ptrincr);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            prevwptr <= 0;
            rptr <= 0;
            wptr <= 0;
        end else begin
            prevwptr <= wptr;
            if ((wincr & (~full))) begin
                wptr <= (wptr + ptrincr);
            end
            if ((rincr & (~empty))) begin
                rptr <= (rptr + ptrincr);
            end
        end
    end
    always_comb begin
        if ((rincr & (~empty))) begin
            raddr = rptrincr;
        end else begin
            raddr = rptr;
        end
    end
    always_comb begin
        enread = 1'd1;
        enwrite = (wvalid & wready);
        addrin = wptr;
        addrout = raddr;
        din = ({ wdata, wlast } | 33'd0);
        { rdata, rlast } = (dout_ramSdpRfInst_ | 33'd0);
    end
endmodule
module dummyio_snsys_1 (
    input dummy1_1,
    input dummy1_2,
    input dummy1_3,
    input dummy1_4,
    input dummy1_5,
    input dummy1_6,
    input [71:0] dummy72_1,
    input [71:0] dummy72_2,
    input [71:0] dummy72_3,
    input [71:0] dummy72_4,
    input [71:0] dummy72_5,
    input [71:0] dummy72_6,
    input CLK,
    input RST
);

endmodule
module TxBufferSelector3_snsys_1 (
    input CLK,
    input RST,
    output logic debug_valid,
    output logic [71:0] debug_data,
    output logic ufp_wready_1,
    input ufp_wvalid_1,
    input [31:0] ufp_wdata_1,
    input ufp_wlast_1,
    input [7:0] ufp_awlen_1,
    input ufp_awvalid_1,
    output logic ufp_awready_1,
    output logic ufp_wready_2,
    input ufp_wvalid_2,
    input [31:0] ufp_wdata_2,
    input ufp_wlast_2,
    input [7:0] ufp_awlen_2,
    input ufp_awvalid_2,
    output logic ufp_awready_2,
    output logic ufp_wready_3,
    input ufp_wvalid_3,
    input [31:0] ufp_wdata_3,
    input ufp_wlast_3,
    input [7:0] ufp_awlen_3,
    input ufp_awvalid_3,
    output logic ufp_awready_3,
    input dfp_wready,
    output logic dfp_wvalid,
    output logic [31:0] dfp_wdata,
    output logic dfp_wlast,
    output logic [7:0] dfp_awlen,
    output logic dfp_awvalid,
    input dfp_awready
);
    logic wdone;
    logic awdonebuf;
    logic wdonebuf;
    logic awdone;
    logic [1:0] selectorIndex;
    logic [71:0] prev_debug_data;

    always_comb begin
        dfp_wvalid = 0;
        dfp_wdata = 0;
        dfp_wlast = 0;
        dfp_awlen = 0;
        dfp_awvalid = 0;
        ufp_wready_1 = 0;
        ufp_awready_1 = 0;
        ufp_wready_2 = 0;
        ufp_awready_2 = 0;
        ufp_wready_3 = 0;
        ufp_awready_3 = 0;
        if ((selectorIndex == 1)) begin
            if ((~wdonebuf)) begin
                ufp_wready_1 = dfp_wready;
                dfp_wvalid = ufp_wvalid_1;
                dfp_wdata = ufp_wdata_1;
                dfp_wlast = ufp_wlast_1;
            end
            if ((~awdonebuf)) begin
                dfp_awlen = ufp_awlen_1;
                dfp_awvalid = ufp_awvalid_1;
                ufp_awready_1 = dfp_awready;
            end
        end else if ((selectorIndex == 2)) begin
            if ((~wdonebuf)) begin
                ufp_wready_2 = dfp_wready;
                dfp_wvalid = ufp_wvalid_2;
                dfp_wdata = ufp_wdata_2;
                dfp_wlast = ufp_wlast_2;
            end
            if ((~awdonebuf)) begin
                dfp_awlen = ufp_awlen_2;
                dfp_awvalid = ufp_awvalid_2;
                ufp_awready_2 = dfp_awready;
            end
        end else if ((selectorIndex == 3)) begin
            if ((~wdonebuf)) begin
                ufp_wready_3 = dfp_wready;
                dfp_wvalid = ufp_wvalid_3;
                dfp_wdata = ufp_wdata_3;
                dfp_wlast = ufp_wlast_3;
            end
            if ((~awdonebuf)) begin
                dfp_awlen = ufp_awlen_3;
                dfp_awvalid = ufp_awvalid_3;
                ufp_awready_3 = dfp_awready;
            end
        end
    end
    always_comb begin
        { awdone, wdone } = 0;
        if ((~(selectorIndex == 2'd0))) begin
            wdone = (wdonebuf | ((dfp_wready & dfp_wvalid) & dfp_wlast));
            awdone = (awdonebuf | (dfp_awready & dfp_awvalid));
            if ((awdone & wdone)) begin
                
            end
        end else begin
            if ((ufp_wvalid_1 | ufp_awvalid_1)) begin
                
            end else if ((ufp_wvalid_2 | ufp_awvalid_2)) begin
                
            end else if ((ufp_wvalid_3 | ufp_awvalid_3)) begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            awdonebuf <= 0;
            selectorIndex <= 0;
            wdonebuf <= 0;
        end else begin
            if ((~(selectorIndex == 2'd0))) begin
                wdonebuf <= wdone;
                awdonebuf <= awdone;
                if ((awdone & wdone)) begin
                    selectorIndex <= 0;
                end
            end else begin
                awdonebuf <= 0;
                wdonebuf <= 0;
                if ((ufp_wvalid_1 | ufp_awvalid_1)) begin
                    selectorIndex <= 1;
                end else if ((ufp_wvalid_2 | ufp_awvalid_2)) begin
                    selectorIndex <= 2;
                end else if ((ufp_wvalid_3 | ufp_awvalid_3)) begin
                    selectorIndex <= 3;
                end
            end
        end
    end
    always_comb begin
        debug_data = 0;
        debug_valid = (~(prev_debug_data == debug_data));
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            prev_debug_data <= 0;
        end else begin
            prev_debug_data <= debug_data;
        end
    end
endmodule
module randomReadAccessBuffer_llipv4sys_snsys_1 (
    input CLK,
    input RST,
    input ufp_wvalid,
    input ufp_wlast,
    input [31:0] ufp_wdata,
    output logic ufp_wready,
    input [12:0] dfp_araddr,
    input dfp_arvalid,
    output logic dfp_arready,
    output logic dfp_rvalid,
    output logic dfp_rinvalid,
    output logic [31:0] dfp_rdata,
    input dfp_flush,
    output logic dfp_full,
    output logic [12:0] stored_length,
    output logic debug_valid,
    output logic [71:0] debug_data
);
    logic [31:0] dout_ramSdpRfInst_randomReadAccessBuffer_llipv4sys_snsys_1;
    logic full;
    logic enread;
    logic [31:0] din;
    logic [12:0] addrout;
    logic [12:0] dfp_araddr_buf;
    logic prev_read_stalling;
    logic enwrite;
    logic [12:0] addrin;
    logic [12:0] wptr;
    logic read_stalling;

    ram_sdp_rf #(
        .addrlen(13),
        .datawid(32)
    ) _instramSdpRfInst_randomReadAccessBuffer_llipv4sys_snsys_1 (
        .clk(CLK),
        .enread(enread),
        .enwrite(enwrite),
        .addrin(addrin),
        .addrout(addrout),
        .din(din),
        .dout(dout_ramSdpRfInst_randomReadAccessBuffer_llipv4sys_snsys_1)
    );
    always_comb begin
        dfp_full = full;
        ufp_wready = (~full);
        stored_length = wptr;
        debug_data = 0;
        debug_valid = 0;
        if ((dfp_full & dfp_flush)) begin
            
        end else begin
            if ((ufp_wvalid & ufp_wready)) begin
                debug_valid = 1;
                debug_data = { 15'd0, ufp_wlast, 3'd0, wptr, 8'd0, ufp_wdata };
                if (ufp_wlast) begin
                    
                end
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            full <= 0;
            wptr <= 0;
        end else begin
            if ((dfp_full & dfp_flush)) begin
                full <= 0;
                wptr <= 0;
            end else begin
                if ((ufp_wvalid & ufp_wready)) begin
                    wptr <= (wptr + 13'd1);
                    if (ufp_wlast) begin
                        full <= 1'd1;
                    end
                end
            end
        end
    end
    always_comb begin
        dfp_arready = (~prev_read_stalling);
        if (prev_read_stalling) begin
            addrout = dfp_araddr_buf;
        end else begin
            addrout = dfp_araddr;
        end
        if ((read_stalling & (~prev_read_stalling))) begin
            
        end
        if ((dfp_full & dfp_flush)) begin
            
        end else begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            dfp_araddr_buf <= 0;
            prev_read_stalling <= 0;
        end else begin
            if (prev_read_stalling) begin
                
            end else begin
                
            end
            if ((read_stalling & (~prev_read_stalling))) begin
                dfp_araddr_buf <= dfp_araddr;
            end
            if ((dfp_full & dfp_flush)) begin
                prev_read_stalling <= 0;
            end else begin
                prev_read_stalling <= read_stalling;
            end
        end
    end
    always_comb begin
        dfp_rdata = dout_ramSdpRfInst_randomReadAccessBuffer_llipv4sys_snsys_1;
        enread = 1'd1;
        if (((dfp_arvalid & dfp_arready) | prev_read_stalling)) begin
            if ((addrout < wptr)) begin
                read_stalling = 0;
            end else begin
                if (full) begin
                    read_stalling = 0;
                end else begin
                    read_stalling = 1;
                end
            end
        end else begin
            read_stalling = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            dfp_rinvalid <= 0;
            dfp_rvalid <= 0;
        end else begin
            if (((dfp_arvalid & dfp_arready) | prev_read_stalling)) begin
                if ((addrout < wptr)) begin
                    dfp_rvalid <= 1;
                    dfp_rinvalid <= 0;
                end else begin
                    if (full) begin
                        dfp_rvalid <= 0;
                        dfp_rinvalid <= 1;
                    end else begin
                        dfp_rvalid <= 0;
                        dfp_rinvalid <= 0;
                    end
                end
            end else begin
                dfp_rvalid <= 0;
                dfp_rinvalid <= 0;
            end
        end
    end
    always_comb begin
        din = ufp_wdata;
        addrin = wptr;
        enwrite = (((~full) & ufp_wvalid) & ufp_wready);
    end
endmodule
module ArpMessageBlock_llipv4sys_snsys_1 (
    input arp_command_valid,
    output logic arp_command_ready,
    input [15:0] opcode,
    input [31:0] senderProtAddr,
    input [31:0] targetProtAddr,
    output logic dfp_awvalid,
    output logic [31:0] dfp_wdata,
    output logic [7:0] dfp_awlen,
    output logic dfp_wlast,
    output logic dfp_wvalid,
    input dfp_awready,
    input dfp_wready,
    input commandValid,
    input [15:0] etherType,
    output logic commandReady,
    input [47:0] destMacAddr,
    input CLK,
    input RST
);
    logic dfp_wlast_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
    logic [31:0] wdata_ArpMessageGenerator_arp_llipv4sys_snsys_1;
    logic RST_ArpMessageGenerator_arp_llipv4sys_snsys_1;
    logic arp_command_valid_ArpMessageGenerator_arp_llipv4sys_snsys_1;
    logic ufp_last_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
    logic [15:0] opcode_ArpMessageGenerator_arp_llipv4sys_snsys_1;
    logic ufp_ready_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
    logic dfp_awvalid_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
    logic ufp_valid_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
    logic arp_command_ready_ArpMessageGenerator_arp_llipv4sys_snsys_1;
    logic commandReady_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic wready_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic [7:0] dfp_awlen_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
    logic wvalid_in_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic wvalid_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic [31:0] wdata_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic wlast_in_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic wlast_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic wready_ArpMessageGenerator_arp_llipv4sys_snsys_1;
    logic CLK_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic dfp_wvalid_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
    logic [31:0] senderProtAddr_ArpMessageGenerator_arp_llipv4sys_snsys_1;
    logic [47:0] destMacAddr_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic [31:0] targetProtAddr_ArpMessageGenerator_arp_llipv4sys_snsys_1;
    logic [15:0] etherType_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic [31:0] wdata_in_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic wready_out_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic RST_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
    logic dfp_awready_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
    logic CLK_ArpMessageGenerator_arp_llipv4sys_snsys_1;
    logic dfp_wready_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
    logic wvalid_ArpMessageGenerator_arp_llipv4sys_snsys_1;
    logic commandValid_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic RST_etherFrameGenerator_arp_llipv4sys_snsys_1;
    logic [31:0] ufp_data_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
    logic [31:0] dfp_wdata_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
    logic wlast_ArpMessageGenerator_arp_llipv4sys_snsys_1;
    logic CLK_etherFrameTxBuffers_arp_llipv4sys_snsys_1;

    ArpMessageGenerator_arp_llipv4sys_snsys_1 ArpMessageGenerator_arp_llipv4sys_snsys_1_inst (
        .CLK(CLK_ArpMessageGenerator_arp_llipv4sys_snsys_1),
        .RST(RST_ArpMessageGenerator_arp_llipv4sys_snsys_1),
        .senderProtAddr(senderProtAddr_ArpMessageGenerator_arp_llipv4sys_snsys_1),
        .targetProtAddr(targetProtAddr_ArpMessageGenerator_arp_llipv4sys_snsys_1),
        .opcode(opcode_ArpMessageGenerator_arp_llipv4sys_snsys_1),
        .arp_command_valid(arp_command_valid_ArpMessageGenerator_arp_llipv4sys_snsys_1),
        .arp_command_ready(arp_command_ready_ArpMessageGenerator_arp_llipv4sys_snsys_1),
        .wdata(wdata_ArpMessageGenerator_arp_llipv4sys_snsys_1),
        .wlast(wlast_ArpMessageGenerator_arp_llipv4sys_snsys_1),
        .wvalid(wvalid_ArpMessageGenerator_arp_llipv4sys_snsys_1),
        .wready(wready_ArpMessageGenerator_arp_llipv4sys_snsys_1)
    );
    etherFrameTxBuffers_arp_llipv4sys_snsys_1 etherFrameTxBuffers_arp_llipv4sys_snsys_1_inst (
        .CLK(CLK_etherFrameTxBuffers_arp_llipv4sys_snsys_1),
        .RST(RST_etherFrameTxBuffers_arp_llipv4sys_snsys_1),
        .ufp_valid(ufp_valid_etherFrameTxBuffers_arp_llipv4sys_snsys_1),
        .ufp_data(ufp_data_etherFrameTxBuffers_arp_llipv4sys_snsys_1),
        .ufp_last(ufp_last_etherFrameTxBuffers_arp_llipv4sys_snsys_1),
        .ufp_ready(ufp_ready_etherFrameTxBuffers_arp_llipv4sys_snsys_1),
        .dfp_wready(dfp_wready_etherFrameTxBuffers_arp_llipv4sys_snsys_1),
        .dfp_wvalid(dfp_wvalid_etherFrameTxBuffers_arp_llipv4sys_snsys_1),
        .dfp_wdata(dfp_wdata_etherFrameTxBuffers_arp_llipv4sys_snsys_1),
        .dfp_wlast(dfp_wlast_etherFrameTxBuffers_arp_llipv4sys_snsys_1),
        .dfp_awlen(dfp_awlen_etherFrameTxBuffers_arp_llipv4sys_snsys_1),
        .dfp_awvalid(dfp_awvalid_etherFrameTxBuffers_arp_llipv4sys_snsys_1),
        .dfp_awready(dfp_awready_etherFrameTxBuffers_arp_llipv4sys_snsys_1)
    );
    etherFrameGenerator_arp_llipv4sys_snsys_1 etherFrameGenerator_arp_llipv4sys_snsys_1_inst (
        .CLK(CLK_etherFrameGenerator_arp_llipv4sys_snsys_1),
        .RST(RST_etherFrameGenerator_arp_llipv4sys_snsys_1),
        .destMacAddr(destMacAddr_etherFrameGenerator_arp_llipv4sys_snsys_1),
        .etherType(etherType_etherFrameGenerator_arp_llipv4sys_snsys_1),
        .commandValid(commandValid_etherFrameGenerator_arp_llipv4sys_snsys_1),
        .commandReady(commandReady_etherFrameGenerator_arp_llipv4sys_snsys_1),
        .wdata(wdata_etherFrameGenerator_arp_llipv4sys_snsys_1),
        .wvalid(wvalid_etherFrameGenerator_arp_llipv4sys_snsys_1),
        .wlast(wlast_etherFrameGenerator_arp_llipv4sys_snsys_1),
        .wready(wready_etherFrameGenerator_arp_llipv4sys_snsys_1),
        .wvalid_in(wvalid_in_etherFrameGenerator_arp_llipv4sys_snsys_1),
        .wdata_in(wdata_in_etherFrameGenerator_arp_llipv4sys_snsys_1),
        .wlast_in(wlast_in_etherFrameGenerator_arp_llipv4sys_snsys_1),
        .wready_out(wready_out_etherFrameGenerator_arp_llipv4sys_snsys_1)
    );
    always_comb begin
        wready_ArpMessageGenerator_arp_llipv4sys_snsys_1 = wready_out_etherFrameGenerator_arp_llipv4sys_snsys_1;
        ufp_valid_etherFrameTxBuffers_arp_llipv4sys_snsys_1 = wvalid_etherFrameGenerator_arp_llipv4sys_snsys_1;
        ufp_data_etherFrameTxBuffers_arp_llipv4sys_snsys_1 = wdata_etherFrameGenerator_arp_llipv4sys_snsys_1;
        ufp_last_etherFrameTxBuffers_arp_llipv4sys_snsys_1 = wlast_etherFrameGenerator_arp_llipv4sys_snsys_1;
        wready_etherFrameGenerator_arp_llipv4sys_snsys_1 = ufp_ready_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
        wdata_in_etherFrameGenerator_arp_llipv4sys_snsys_1 = wdata_ArpMessageGenerator_arp_llipv4sys_snsys_1;
        wvalid_in_etherFrameGenerator_arp_llipv4sys_snsys_1 = wvalid_ArpMessageGenerator_arp_llipv4sys_snsys_1;
        wlast_in_etherFrameGenerator_arp_llipv4sys_snsys_1 = wlast_ArpMessageGenerator_arp_llipv4sys_snsys_1;
    end
    always_comb begin
        arp_command_valid_ArpMessageGenerator_arp_llipv4sys_snsys_1 = arp_command_valid;
        arp_command_ready = arp_command_ready_ArpMessageGenerator_arp_llipv4sys_snsys_1;
        opcode_ArpMessageGenerator_arp_llipv4sys_snsys_1 = opcode;
        senderProtAddr_ArpMessageGenerator_arp_llipv4sys_snsys_1 = senderProtAddr;
        targetProtAddr_ArpMessageGenerator_arp_llipv4sys_snsys_1 = targetProtAddr;
        dfp_awvalid = dfp_awvalid_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
        dfp_wdata = dfp_wdata_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
        dfp_awlen = dfp_awlen_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
        dfp_wlast = dfp_wlast_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
        dfp_wvalid = dfp_wvalid_etherFrameTxBuffers_arp_llipv4sys_snsys_1;
        dfp_awready_etherFrameTxBuffers_arp_llipv4sys_snsys_1 = dfp_awready;
        dfp_wready_etherFrameTxBuffers_arp_llipv4sys_snsys_1 = dfp_wready;
        commandValid_etherFrameGenerator_arp_llipv4sys_snsys_1 = commandValid;
        etherType_etherFrameGenerator_arp_llipv4sys_snsys_1 = etherType;
        commandReady = commandReady_etherFrameGenerator_arp_llipv4sys_snsys_1;
        destMacAddr_etherFrameGenerator_arp_llipv4sys_snsys_1 = destMacAddr;
    end
    always_comb begin
        CLK_ArpMessageGenerator_arp_llipv4sys_snsys_1 = CLK;
        RST_ArpMessageGenerator_arp_llipv4sys_snsys_1 = RST;
    end
    always_comb begin
        CLK_etherFrameTxBuffers_arp_llipv4sys_snsys_1 = CLK;
        RST_etherFrameTxBuffers_arp_llipv4sys_snsys_1 = RST;
    end
    always_comb begin
        CLK_etherFrameGenerator_arp_llipv4sys_snsys_1 = CLK;
        RST_etherFrameGenerator_arp_llipv4sys_snsys_1 = RST;
    end
endmodule
module dummyio_llipv4sys_snsys_1 (
    input dummy1_1,
    input dummy1_2,
    input [12:0] dummy13_1,
    input [71:0] dummy72_1,
    input [71:0] dummy72_2,
    input CLK,
    input RST
);

endmodule
module LinkLocalIpClaimer_llipv4sys_snsys_1 (
    input CLK,
    input RST,
    input start,
    output logic [47:0] tx_destMacAddr,
    output logic [15:0] tx_etherType,
    output logic [15:0] tx_opcode,
    output logic [31:0] tx_senderIpAddr,
    output logic [31:0] tx_targetIpAddr,
    output logic tx_etherFrameCommandValid,
    output logic tx_arpReqCommandValid,
    input tx_etherFrameCommandReady,
    input tx_arpReqCommandReady,
    output logic [12:0] rx_araddr,
    output logic rx_arvalid,
    input rx_arready,
    input rx_rvalid,
    input rx_rinvalid,
    input [31:0] rx_rdata,
    output logic rx_flush,
    input rx_full,
    output logic debug_valid,
    output logic [71:0] debug_data,
    output logic ip_addr_valid,
    output logic [31:0] ip_addr
);
    localparam idle = 0;
    localparam probing = 1;
    localparam announcing1 = 2;
    localparam configured = 3;
    localparam announcing2 = 4;
    localparam responding = 5;
    localparam defending = 6;
    localparam rx_hold_frame_now = 0;
    localparam rx_flush_frame_now = 1;
    localparam probe_idle = 0;
    localparam probe_initial_wait = 1;
    localparam trigger_probe = 2;
    localparam probe_interval = 3;

    reg [2:0] txfsm;
    logic [31:0] rx_sender_ip;
    logic [31:0] rx_target_ip;
    logic [47:0] rx_sender_mac;
    reg rx_flush_state;
    reg [1:0] tx_probe_timeout_state;
    logic second_announce_timer_start;
    logic [47:0] second_announce_timer;
    logic rx_sender_ip_conflict;
    logic [31:0] claiming_ip;
    logic tx_etherFrameDone_buf;
    logic tx_etherFrameDone;
    logic probe_all_done;
    logic rx_read_frame_done;
    logic tx_arpReqCommandDone_buf;
    logic rx_rinvalid_buf;
    logic tx_arpReqCommandDone;
    logic end_probe_interval;
    logic probe_done;
    logic [7:0] rx_rcounter;
    logic rx_target_ip_is_self;
    logic [47:0] probe_initial_wait_counter;
    logic rx_arp_response_needed;
    logic [7:0] rx_arcounter;
    logic probe_conflict;
    logic rx_hardware_addr_is_self;
    logic [47:0] self_mac;
    logic [47:0] probe_timeout_counter;
    logic probe_initial_wait_done;
    logic probe_triggered;
    logic rx_arp_defense_needed;
    logic [7:0] probe_counter;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            txfsm <= 0;
        end else begin
            case (txfsm)
                idle: begin
                    if ((start & (rx_flush_state == rx_hold_frame_now))) begin
                        txfsm <= probing;
                    end
                end
                probing: begin
                    if (probe_conflict) begin
                        txfsm <= idle;
                    end else if (probe_done) begin
                        txfsm <= announcing1;
                    end
                end
                announcing1: begin
                    if ((tx_etherFrameDone & tx_arpReqCommandDone)) begin
                        txfsm <= configured;
                    end
                end
                configured: begin
                    if ((second_announce_timer == 48'd117440512)) begin
                        txfsm <= announcing2;
                    end else if (rx_arp_response_needed) begin
                        txfsm <= responding;
                    end else if (rx_arp_defense_needed) begin
                        txfsm <= defending;
                    end
                end
                announcing2: begin
                    if ((tx_etherFrameDone & tx_arpReqCommandDone)) begin
                        txfsm <= configured;
                    end
                end
                responding: begin
                    if ((tx_etherFrameDone & tx_arpReqCommandDone)) begin
                        txfsm <= configured;
                    end
                end
                defending: begin
                    if ((tx_etherFrameDone & tx_arpReqCommandDone)) begin
                        txfsm <= configured;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        { tx_destMacAddr, tx_etherType, tx_senderIpAddr, tx_targetIpAddr } = 0;
        tx_etherFrameCommandValid = 0;
        tx_arpReqCommandValid = 0;
        tx_opcode = 0;
        tx_etherType = 2054;
        if ((txfsm == probing)) begin
            tx_destMacAddr = (~0);
            tx_opcode = 1;
            tx_senderIpAddr = 0;
            tx_targetIpAddr = claiming_ip;
            if ((tx_probe_timeout_state == trigger_probe)) begin
                tx_etherFrameCommandValid = (~tx_etherFrameDone_buf);
                tx_arpReqCommandValid = (~tx_arpReqCommandDone_buf);
            end
        end else if (((txfsm == announcing1) || ((txfsm == announcing2) || (txfsm == defending)))) begin
            tx_destMacAddr = (~0);
            tx_opcode = 1;
            tx_senderIpAddr = claiming_ip;
            tx_targetIpAddr = claiming_ip;
            tx_etherFrameCommandValid = (~tx_etherFrameDone_buf);
            tx_arpReqCommandValid = (~tx_arpReqCommandDone_buf);
        end else if ((txfsm == responding)) begin
            tx_destMacAddr = rx_sender_mac;
            tx_opcode = 2;
            tx_senderIpAddr = claiming_ip;
            tx_targetIpAddr = rx_sender_ip;
            tx_etherFrameCommandValid = (~tx_etherFrameDone_buf);
            tx_arpReqCommandValid = (~tx_arpReqCommandDone_buf);
        end
    end
    always_comb begin
        if (((txfsm == probing) & (rx_rcounter == 4))) begin
            rx_sender_ip_conflict = (rx_sender_ip == claiming_ip);
            rx_hardware_addr_is_self = (rx_sender_mac == self_mac);
            rx_target_ip_is_self = (rx_target_ip == claiming_ip);
            probe_conflict = (rx_sender_ip_conflict | (((rx_sender_ip == 0) & rx_target_ip_is_self) & (~rx_hardware_addr_is_self)));
        end else begin
            rx_sender_ip_conflict = 0;
            rx_hardware_addr_is_self = 0;
            rx_target_ip_is_self = 0;
            probe_conflict = 0;
        end
        if (((txfsm == configured) & (rx_rcounter == 4))) begin
            rx_arp_response_needed = ((rx_target_ip == claiming_ip) & (~(rx_sender_mac == self_mac)));
            rx_arp_defense_needed = ((rx_sender_ip == claiming_ip) & (~(rx_sender_mac == self_mac)));
        end else begin
            rx_arp_response_needed = 0;
            rx_arp_defense_needed = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            second_announce_timer <= 0;
            second_announce_timer_start <= 0;
        end else begin
            if (((txfsm == announcing1) && (tx_etherFrameDone & tx_arpReqCommandDone))) begin
                second_announce_timer_start <= 1'd1;
            end else if (((txfsm == announcing2) && (tx_etherFrameDone & tx_arpReqCommandDone))) begin
                second_announce_timer_start <= 0;
            end
            if (((txfsm == announcing2) && (tx_etherFrameDone & tx_arpReqCommandDone))) begin
                second_announce_timer <= 0;
            end else if (second_announce_timer_start) begin
                if ((~(second_announce_timer == 48'd117440512))) begin
                    second_announce_timer <= (second_announce_timer + 1);
                end
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            rx_arcounter <= 0;
            rx_rcounter <= 0;
            rx_rinvalid_buf <= 0;
            rx_sender_ip <= 0;
            rx_sender_mac <= 0;
            rx_target_ip <= 0;
        end else begin
            if ((~(txfsm == idle))) begin
                if (((rx_flush_state == rx_hold_frame_now) && rx_read_frame_done)) begin
                    rx_arcounter <= 0;
                    rx_rcounter <= 0;
                    rx_rinvalid_buf <= 0;
                    rx_sender_mac <= 0;
                    rx_sender_ip <= 0;
                    rx_target_ip <= 0;
                end else if ((rx_flush_state == rx_hold_frame_now)) begin
                    if (rx_rvalid) begin
                        rx_rcounter <= (rx_rcounter + 8'd1);
                        if ((rx_rcounter == 0)) begin
                            rx_sender_mac[47:16] <= { rx_rdata[7:0], rx_rdata[15:8], rx_rdata[23:16], rx_rdata[31:24] };
                        end else if ((rx_rcounter == 1)) begin
                            rx_sender_mac[15:0] <= { rx_rdata[7:0], rx_rdata[15:8] };
                            rx_sender_ip[31:16] <= { rx_rdata[23:16], rx_rdata[31:24] };
                        end else if ((rx_rcounter == 2)) begin
                            rx_sender_ip[15:0] <= { rx_rdata[7:0], rx_rdata[15:8] };
                        end else if ((rx_rcounter == 3)) begin
                            rx_target_ip <= { rx_rdata[7:0], rx_rdata[15:8], rx_rdata[23:16], rx_rdata[31:24] };
                        end
                    end
                    if ((rx_arvalid & rx_arready)) begin
                        rx_arcounter <= (rx_arcounter + 8'd1);
                    end
                    if (rx_rinvalid) begin
                        rx_rinvalid_buf <= 1'd1;
                    end
                end
            end else begin
                rx_arcounter <= 0;
                rx_rcounter <= 0;
                rx_rinvalid_buf <= 0;
                rx_sender_mac <= 0;
                rx_sender_ip <= 0;
                rx_target_ip <= 0;
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            rx_flush_state <= 0;
        end else begin
            case (rx_flush_state)
                rx_hold_frame_now: begin
                    if (rx_read_frame_done) begin
                        rx_flush_state <= rx_flush_frame_now;
                    end
                end
                rx_flush_frame_now: begin
                    if ((rx_flush & rx_full)) begin
                        rx_flush_state <= rx_hold_frame_now;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        if ((txfsm == probing)) begin
            rx_read_frame_done = ((rx_rcounter == 3) & rx_rvalid);
        end else if (((((txfsm == configured) & (~((txfsm == configured) && (second_announce_timer == 48'd117440512)))) & (~((txfsm == configured) && rx_arp_response_needed))) & (~((txfsm == configured) && rx_arp_defense_needed)))) begin
            rx_read_frame_done = (rx_rcounter == 4);
        end else if ((((txfsm == responding) && (tx_etherFrameDone & tx_arpReqCommandDone)) || ((txfsm == defending) && (tx_etherFrameDone & tx_arpReqCommandDone)))) begin
            rx_read_frame_done = 1;
        end else begin
            rx_read_frame_done = 0;
        end
    end
    always_comb begin
        rx_flush = 0;
        rx_araddr = 0;
        rx_arvalid = 0;
        if ((txfsm == idle)) begin
            rx_flush = 1;
        end else begin
            if ((rx_flush_state == rx_hold_frame_now)) begin
                rx_arvalid = (~(rx_arcounter == 4));
                if ((rx_arcounter == 0)) begin
                    rx_araddr = 2;
                end else if ((rx_arcounter == 1)) begin
                    rx_araddr = 3;
                end else if ((rx_arcounter == 2)) begin
                    rx_araddr = 4;
                end else if ((rx_arcounter == 3)) begin
                    rx_araddr = 6;
                end
            end else if ((rx_flush_state == rx_flush_frame_now)) begin
                rx_flush = 1;
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            tx_probe_timeout_state <= 0;
        end else begin
            case (tx_probe_timeout_state)
                probe_idle: begin
                    if (((txfsm == idle) && (start & (rx_flush_state == rx_hold_frame_now)))) begin
                        tx_probe_timeout_state <= probe_initial_wait;
                    end
                end
                probe_initial_wait: begin
                    if (probe_conflict) begin
                        tx_probe_timeout_state <= probe_idle;
                    end else if (probe_initial_wait_done) begin
                        tx_probe_timeout_state <= trigger_probe;
                    end
                end
                trigger_probe: begin
                    if (probe_conflict) begin
                        tx_probe_timeout_state <= probe_idle;
                    end else if (probe_triggered) begin
                        tx_probe_timeout_state <= probe_interval;
                    end
                end
                probe_interval: begin
                    if (((end_probe_interval & probe_all_done) | probe_conflict)) begin
                        tx_probe_timeout_state <= probe_idle;
                    end else if ((end_probe_interval & (~probe_all_done))) begin
                        tx_probe_timeout_state <= trigger_probe;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        probe_triggered = (tx_etherFrameDone & tx_arpReqCommandDone);
        end_probe_interval = (probe_timeout_counter == 48'd109051904);
        probe_all_done = (probe_counter == 3);
    end
    always_comb begin
        if ((tx_probe_timeout_state == probe_initial_wait)) begin
            probe_initial_wait_done = (probe_initial_wait_counter == 48'd117440512);
        end else begin
            probe_initial_wait_done = 0;
        end
        if (((tx_probe_timeout_state == trigger_probe) || ((txfsm == announcing1) || ((txfsm == announcing2) || ((txfsm == responding) || (txfsm == defending)))))) begin
            tx_etherFrameDone = (tx_etherFrameDone_buf | (tx_etherFrameCommandReady & tx_etherFrameCommandValid));
            tx_arpReqCommandDone = (tx_arpReqCommandDone_buf | (tx_arpReqCommandReady & tx_arpReqCommandValid));
        end else begin
            tx_etherFrameDone = 0;
            tx_arpReqCommandDone = 0;
        end
        if ((tx_probe_timeout_state == probe_interval)) begin
            
        end else begin
            
        end
        if ((tx_probe_timeout_state == trigger_probe)) begin
            if ((tx_etherFrameDone & tx_arpReqCommandDone)) begin
                
            end
        end else if ((tx_probe_timeout_state == probe_interval)) begin
            
        end else begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            probe_counter <= 0;
            probe_initial_wait_counter <= 0;
            probe_timeout_counter <= 0;
            tx_arpReqCommandDone_buf <= 0;
            tx_etherFrameDone_buf <= 0;
        end else begin
            if ((tx_probe_timeout_state == probe_initial_wait)) begin
                probe_initial_wait_counter <= (probe_initial_wait_counter + 48'd1);
            end else begin
                probe_initial_wait_counter <= 0;
            end
            if (((tx_probe_timeout_state == trigger_probe) || ((txfsm == announcing1) || ((txfsm == announcing2) || ((txfsm == responding) || (txfsm == defending)))))) begin
                tx_etherFrameDone_buf <= tx_etherFrameDone;
                tx_arpReqCommandDone_buf <= tx_arpReqCommandDone;
            end else begin
                tx_etherFrameDone_buf <= 0;
                tx_arpReqCommandDone_buf <= 0;
            end
            if ((tx_probe_timeout_state == probe_interval)) begin
                probe_timeout_counter <= (probe_timeout_counter + 48'd1);
            end else begin
                probe_timeout_counter <= 0;
            end
            if ((tx_probe_timeout_state == trigger_probe)) begin
                if ((tx_etherFrameDone & tx_arpReqCommandDone)) begin
                    probe_counter <= (probe_counter + 8'd1);
                end
            end else if ((tx_probe_timeout_state == probe_interval)) begin
                
            end else begin
                probe_counter <= 0;
            end
        end
    end
    always_comb begin
        claiming_ip = 32'd2851998226;
        self_mac = 48'd1577122510;
        probe_done = ((tx_probe_timeout_state == probe_interval) && ((end_probe_interval & probe_all_done) | probe_conflict));
    end
    always_comb begin
        ip_addr = claiming_ip;
        if (((txfsm == announcing1) && (tx_etherFrameDone & tx_arpReqCommandDone))) begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            ip_addr_valid <= 0;
        end else begin
            if (((txfsm == announcing1) && (tx_etherFrameDone & tx_arpReqCommandDone))) begin
                ip_addr_valid <= 1;
            end
        end
    end
    always_comb begin
        debug_valid = 0;
        debug_data = 0;
        if ((txfsm == probing)) begin
            if ((probe_timeout_counter == 48'd109051903)) begin
                debug_data = { 24'd0, { 6'd0, tx_etherFrameDone, tx_etherFrameDone }, probe_counter, tx_targetIpAddr };
                debug_valid = 1;
            end
        end
    end
endmodule
module ArpMessageGenerator_arp_llipv4sys_snsys_1 (
    input CLK,
    input RST,
    input [31:0] senderProtAddr,
    input [31:0] targetProtAddr,
    input [15:0] opcode,
    input arp_command_valid,
    output logic arp_command_ready,
    output logic [31:0] wdata,
    output logic wlast,
    output logic wvalid,
    input wready
);
    localparam idle = 0;
    localparam busy = 1;

    reg state;
    logic [31:0] targetProtAddrBuf;
    logic [31:0] senderProtAddrBuf;
    logic [15:0] opcodeBuf;
    logic [3:0] wcounter;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                idle: begin
                    if ((arp_command_ready & arp_command_valid)) begin
                        state <= busy;
                    end
                end
                busy: begin
                    if (((wlast & wvalid) & wready)) begin
                        state <= idle;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        { wvalid, wdata, wlast } = 0;
        if ((state == busy)) begin
            wvalid = 1;
            if ((wcounter == 0)) begin
                wdata = 524544;
            end else if ((wcounter == 1)) begin
                wdata = { opcodeBuf[7:0], opcodeBuf[15:8], 16'd1030 };
            end else if ((wcounter == 2)) begin
                wdata = 6160384;
            end else if ((wcounter == 3)) begin
                wdata = { senderProtAddrBuf[23:16], senderProtAddrBuf[31:24], 16'd52986 };
            end else if ((wcounter == 4)) begin
                wdata = { 16'd0, senderProtAddrBuf[7:0], senderProtAddrBuf[15:8] };
            end else if ((wcounter == 5)) begin
                wdata = 0;
            end else if ((wcounter == 6)) begin
                wdata = { targetProtAddrBuf[7:0], targetProtAddrBuf[15:8], targetProtAddrBuf[23:16], targetProtAddrBuf[31:24] };
                wlast = 1;
            end
        end
    end
    always_comb begin
        arp_command_ready = (state == idle);
        if ((state == idle)) begin
            
        end else if ((state == busy)) begin
            if ((wvalid & wready)) begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            opcodeBuf <= 0;
            senderProtAddrBuf <= 0;
            targetProtAddrBuf <= 0;
            wcounter <= 0;
        end else begin
            if ((state == idle)) begin
                wcounter <= 4'd0;
                senderProtAddrBuf <= senderProtAddr;
                targetProtAddrBuf <= targetProtAddr;
                opcodeBuf <= opcode;
            end else if ((state == busy)) begin
                if ((wvalid & wready)) begin
                    wcounter <= (wcounter + 1);
                end
            end
        end
    end
endmodule
module etherFrameTxBuffers_arp_llipv4sys_snsys_1 (
    input CLK,
    input RST,
    input ufp_valid,
    input [31:0] ufp_data,
    input ufp_last,
    output logic ufp_ready,
    input dfp_wready,
    output logic dfp_wvalid,
    output logic [31:0] dfp_wdata,
    output logic dfp_wlast,
    output logic [7:0] dfp_awlen,
    output logic dfp_awvalid,
    input dfp_awready
);
    logic [7:0] prev_wptr;
    logic full;
    logic enread;
    logic [31:0] din;
    logic [7:0] addrout;
    logic [7:0] awlen_buf;
    logic awdone;
    logic enwrite;
    logic [7:0] addrin;
    logic [7:0] wptr;
    logic [31:0] dout_ramSdpRfInst_;
    logic [7:0] rptr;

    ram_sdp_rf #(
        .addrlen(8),
        .datawid(32)
    ) _instramSdpRfInst_ (
        .clk(CLK),
        .enread(enread),
        .enwrite(enwrite),
        .addrin(addrin),
        .addrout(addrout),
        .din(din),
        .dout(dout_ramSdpRfInst_)
    );
    always_comb begin
        addrin = wptr;
        addrout = rptr;
        din = ufp_data;
        enread = 1'd1;
        enwrite = 0;
        ufp_ready = (~full);
        dfp_wlast = (full & (wptr == (rptr + 1)));
        dfp_wvalid = (~(prev_wptr == rptr));
        dfp_wdata = dout_ramSdpRfInst_;
        dfp_awvalid = (full & (~awdone));
        dfp_awlen = awlen_buf;
        if (((full & (wptr == rptr)) & awdone)) begin
            
        end else begin
            if ((~full)) begin
                if (ufp_valid) begin
                    enwrite = 1'd1;
                    if (ufp_last) begin
                        
                    end
                end
            end
            if ((dfp_wvalid & dfp_wready)) begin
                addrout = (rptr + 8'd1);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            awdone <= 0;
            awlen_buf <= 0;
            full <= 0;
            prev_wptr <= 0;
            rptr <= 0;
            wptr <= 0;
        end else begin
            if (((full & (wptr == rptr)) & awdone)) begin
                wptr <= 0;
                rptr <= 0;
                awlen_buf <= 0;
                full <= 0;
                prev_wptr <= 0;
                awdone <= 0;
            end else begin
                prev_wptr <= wptr;
                awdone <= (awdone | (dfp_awvalid & dfp_awready));
                if ((~full)) begin
                    if (ufp_valid) begin
                        wptr <= (wptr + 8'd1);
                        if (ufp_last) begin
                            awlen_buf <= wptr;
                            full <= 1;
                        end
                    end
                end
                if ((dfp_wvalid & dfp_wready)) begin
                    rptr <= (rptr + 8'd1);
                end
            end
        end
    end
endmodule
module etherFrameGenerator_arp_llipv4sys_snsys_1 (
    input CLK,
    input RST,
    input [47:0] destMacAddr,
    input [15:0] etherType,
    input commandValid,
    output logic commandReady,
    output logic [31:0] wdata,
    output logic wvalid,
    output logic wlast,
    input wready,
    input wvalid_in,
    input [31:0] wdata_in,
    input wlast_in,
    output logic wready_out
);
    localparam idle = 0;
    localparam header = 1;
    localparam payload = 2;
    localparam lastpayload = 3;

    reg [1:0] state;
    logic [2:0] headerCounter;
    logic [47:0] destMacAddrBuf;
    logic [47:0] sourceMacAddr;
    logic [15:0] wdataHalfWordBuf;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                idle: begin
                    if ((commandValid & commandReady)) begin
                        state <= header;
                    end
                end
                header: begin
                    if ((((headerCounter == 2) & wvalid) & wready)) begin
                        state <= payload;
                    end
                end
                payload: begin
                    if (((wlast_in & wvalid) & wready)) begin
                        state <= lastpayload;
                    end
                end
                lastpayload: begin
                    if ((wvalid & wready)) begin
                        state <= idle;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        commandReady = 0;
        { wdata, wvalid, wlast } = 0;
        wready_out = 0;
        if ((state == idle)) begin
            commandReady = 1;
        end else if ((state == header)) begin
            wvalid = 1;
            if ((headerCounter == 0)) begin
                wdata = { destMacAddrBuf[23:16], destMacAddrBuf[31:24], destMacAddrBuf[39:32], destMacAddrBuf[47:40] };
            end else if ((headerCounter == 1)) begin
                wdata = { sourceMacAddr[39:32], sourceMacAddr[47:40], destMacAddrBuf[7:0], destMacAddrBuf[15:8] };
            end else if ((headerCounter == 2)) begin
                wdata = { sourceMacAddr[7:0], sourceMacAddr[15:8], sourceMacAddr[23:16], sourceMacAddr[31:24] };
            end
        end else if ((state == payload)) begin
            wvalid = wvalid_in;
            wready_out = wready;
            wdata = { wdata_in[15:0], wdataHalfWordBuf };
        end else if ((state == lastpayload)) begin
            wlast = 1;
            wdata = { 16'd0, wdataHalfWordBuf };
            wvalid = 1;
        end
    end
    always_comb begin
        sourceMacAddr = 48'd1577122510;
        if ((state == idle)) begin
            
        end
        if ((state == header)) begin
            if ((wvalid & wready)) begin
                
            end
        end else begin
            
        end
        if ((state == idle)) begin
            
        end else if ((state == payload)) begin
            if ((wvalid & wready)) begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            destMacAddrBuf <= 0;
            headerCounter <= 0;
            wdataHalfWordBuf <= 0;
        end else begin
            if ((state == idle)) begin
                destMacAddrBuf <= destMacAddr;
            end
            if ((state == header)) begin
                if ((wvalid & wready)) begin
                    headerCounter <= (headerCounter + 3'd1);
                end
            end else begin
                headerCounter <= 0;
            end
            if ((state == idle)) begin
                wdataHalfWordBuf <= { etherType[7:0], etherType[15:8] };
            end else if ((state == payload)) begin
                if ((wvalid & wready)) begin
                    wdataHalfWordBuf <= wdata_in[31:16];
                end
            end
        end
    end
endmodule
module icmpRecvParser_echosys_snsys_1 (
    input CLK,
    input RST,
    input ufp_valid,
    input ufp_last,
    output logic ufp_ready,
    input [31:0] ufp_data,
    input [31:0] ufp_src_addr,
    input [31:0] ufp_dest_addr,
    input [15:0] ufp_total_length_data,
    output logic dfp_valid,
    output logic dfp_last,
    output logic [31:0] dfp_data,
    input dfp_ready,
    output logic [15:0] total_length_data,
    output logic [31:0] src_addr,
    output logic [31:0] dest_addr,
    output logic no_data_payload,
    output logic [7:0] _type,
    output logic [7:0] code,
    output logic [15:0] checksum,
    output logic [15:0] identifier,
    output logic [15:0] sequence_number,
    output logic [15:0] checksum_data_only,
    output logic info_core_valid,
    output logic info_valid,
    input info_ready
);
    localparam init = 0;
    localparam busy = 1;
    localparam unknownError = 2;

    reg [1:0] state;
    logic prev_ufp_last;
    logic busy_trans_done;
    logic [7:0] header_read_counter;
    logic header_read_done;
    logic [16:0] checksum_with_carry_last;
    logic [17:0] checksum_with_carry;
    logic info_done;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                init: begin
                    if (header_read_done) begin
                        state <= busy;
                    end else if ((((ufp_last & ufp_valid) & ufp_ready) & (~header_read_done))) begin
                        state <= unknownError;
                    end
                end
                busy: begin
                    if (((prev_ufp_last | busy_trans_done) & ((info_valid & info_ready) | info_done))) begin
                        state <= init;
                    end
                end
                unknownError: begin
                    if (1) begin
                        state <= init;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        header_read_done = ((header_read_counter == 1) & (ufp_valid & ufp_ready));
        if ((state == busy)) begin
            info_valid = ((prev_ufp_last | busy_trans_done) & (~info_done));
        end else begin
            info_valid = 0;
        end
    end
    always_comb begin
        if ((state == busy)) begin
            if ((ufp_ready & ufp_valid)) begin
                checksum_with_carry = ((({ 2'd0, checksum_data_only } + { 2'd0, ufp_data[23:16], ufp_data[31:24] }) + { 2'd0, ufp_data[7:0], ufp_data[15:8] }) | 18'd0);
                checksum_with_carry_last = (({ 1'd0, checksum_with_carry[15:0] } + { 15'd0, checksum_with_carry[17:16] }) | 17'd0);
            end else begin
                checksum_with_carry = 0;
                checksum_with_carry_last = 0;
            end
        end else begin
            checksum_with_carry = 0;
            checksum_with_carry_last = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            checksum_data_only <= 0;
        end else begin
            if ((state == busy)) begin
                if ((ufp_ready & ufp_valid)) begin
                    checksum_data_only <= (checksum_with_carry_last[15:0] + { 15'd0, checksum_with_carry_last[16] });
                end else begin
                    
                end
            end else begin
                checksum_data_only <= 0;
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _type <= 0;
            busy_trans_done <= 0;
            checksum <= 0;
            code <= 0;
            dest_addr <= 0;
            header_read_counter <= 0;
            identifier <= 0;
            prev_ufp_last <= 0;
            sequence_number <= 0;
            src_addr <= 0;
            total_length_data <= 0;
        end else begin
            if ((state == init)) begin
                if ((ufp_valid & ufp_ready)) begin
                    src_addr <= ufp_src_addr;
                    dest_addr <= ufp_dest_addr;
                    total_length_data <= ((ufp_total_length_data + 1) + (~16'd8));
                    header_read_counter <= (header_read_counter + 8'd1);
                    if ((header_read_counter == 0)) begin
                        _type <= ufp_data[7:0];
                        code <= ufp_data[15:8];
                        checksum <= { ufp_data[23:16], ufp_data[31:24] };
                    end else if ((header_read_counter == 1)) begin
                        identifier <= { ufp_data[7:0], ufp_data[15:8] };
                        sequence_number <= { ufp_data[23:16], ufp_data[31:24] };
                    end
                end
            end else begin
                header_read_counter <= 0;
            end
            if (((state == init) && header_read_done)) begin
                prev_ufp_last <= ufp_last;
            end else if (((state == busy) && ((prev_ufp_last | busy_trans_done) & ((info_valid & info_ready) | info_done)))) begin
                prev_ufp_last <= 0;
            end
            if ((state == busy)) begin
                if (((ufp_valid & ufp_ready) & ufp_last)) begin
                    busy_trans_done <= 1'd1;
                end
            end else begin
                busy_trans_done <= 0;
            end
        end
    end
    always_comb begin
        no_data_payload = prev_ufp_last;
        info_core_valid = (state == busy);
        if (((state == busy) & (~busy_trans_done))) begin
            dfp_valid = ufp_valid;
            dfp_last = ufp_last;
            dfp_data = ufp_data;
        end else begin
            dfp_valid = 0;
            dfp_last = 0;
            dfp_data = 0;
        end
        if ((state == init)) begin
            ufp_ready = 1;
        end else if (((state == busy) & (~busy_trans_done))) begin
            ufp_ready = dfp_ready;
        end else begin
            ufp_ready = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            info_done <= 0;
        end else begin
            if ((state == busy)) begin
                if ((info_valid & info_ready)) begin
                    info_done <= 1;
                end
            end else begin
                info_done <= 0;
            end
        end
    end
endmodule
module dummyio_echosys_snsys_1 (
    input dummy1_1,
    input dummy1_2,
    input [7:0] dummy8_1,
    input [15:0] dummy16_1,
    input [71:0] dummy72_1,
    input CLK,
    input RST
);

endmodule
module randomReadAccessBuffer_echosys_snsys_1 (
    input CLK,
    input RST,
    input ufp_wvalid,
    input ufp_wlast,
    input [31:0] ufp_wdata,
    output logic ufp_wready,
    input [12:0] dfp_araddr,
    input dfp_arvalid,
    output logic dfp_arready,
    output logic dfp_rvalid,
    output logic dfp_rinvalid,
    output logic [31:0] dfp_rdata,
    input dfp_flush,
    output logic dfp_full,
    output logic [12:0] stored_length,
    output logic debug_valid,
    output logic [71:0] debug_data
);
    logic full;
    logic enread;
    logic [31:0] din;
    logic [12:0] addrout;
    logic [12:0] dfp_araddr_buf;
    logic [31:0] dout_ramSdpRfInst_randomReadAccessBuffer_echosys_snsys_1;
    logic prev_read_stalling;
    logic enwrite;
    logic [12:0] addrin;
    logic [12:0] wptr;
    logic read_stalling;

    ram_sdp_rf #(
        .addrlen(13),
        .datawid(32)
    ) _instramSdpRfInst_randomReadAccessBuffer_echosys_snsys_1 (
        .clk(CLK),
        .enread(enread),
        .enwrite(enwrite),
        .addrin(addrin),
        .addrout(addrout),
        .din(din),
        .dout(dout_ramSdpRfInst_randomReadAccessBuffer_echosys_snsys_1)
    );
    always_comb begin
        dfp_full = full;
        ufp_wready = (~full);
        stored_length = wptr;
        debug_data = 0;
        debug_valid = 0;
        if ((dfp_full & dfp_flush)) begin
            
        end else begin
            if ((ufp_wvalid & ufp_wready)) begin
                debug_valid = 1;
                debug_data = { 15'd0, ufp_wlast, 3'd0, wptr, 8'd0, ufp_wdata };
                if (ufp_wlast) begin
                    
                end
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            full <= 0;
            wptr <= 0;
        end else begin
            if ((dfp_full & dfp_flush)) begin
                full <= 0;
                wptr <= 0;
            end else begin
                if ((ufp_wvalid & ufp_wready)) begin
                    wptr <= (wptr + 13'd1);
                    if (ufp_wlast) begin
                        full <= 1'd1;
                    end
                end
            end
        end
    end
    always_comb begin
        dfp_arready = (~prev_read_stalling);
        if (prev_read_stalling) begin
            addrout = dfp_araddr_buf;
        end else begin
            addrout = dfp_araddr;
        end
        if ((read_stalling & (~prev_read_stalling))) begin
            
        end
        if ((dfp_full & dfp_flush)) begin
            
        end else begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            dfp_araddr_buf <= 0;
            prev_read_stalling <= 0;
        end else begin
            if (prev_read_stalling) begin
                
            end else begin
                
            end
            if ((read_stalling & (~prev_read_stalling))) begin
                dfp_araddr_buf <= dfp_araddr;
            end
            if ((dfp_full & dfp_flush)) begin
                prev_read_stalling <= 0;
            end else begin
                prev_read_stalling <= read_stalling;
            end
        end
    end
    always_comb begin
        dfp_rdata = dout_ramSdpRfInst_randomReadAccessBuffer_echosys_snsys_1;
        enread = 1'd1;
        if (((dfp_arvalid & dfp_arready) | prev_read_stalling)) begin
            if ((addrout < wptr)) begin
                read_stalling = 0;
            end else begin
                if (full) begin
                    read_stalling = 0;
                end else begin
                    read_stalling = 1;
                end
            end
        end else begin
            read_stalling = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            dfp_rinvalid <= 0;
            dfp_rvalid <= 0;
        end else begin
            if (((dfp_arvalid & dfp_arready) | prev_read_stalling)) begin
                if ((addrout < wptr)) begin
                    dfp_rvalid <= 1;
                    dfp_rinvalid <= 0;
                end else begin
                    if (full) begin
                        dfp_rvalid <= 0;
                        dfp_rinvalid <= 1;
                    end else begin
                        dfp_rvalid <= 0;
                        dfp_rinvalid <= 0;
                    end
                end
            end else begin
                dfp_rvalid <= 0;
                dfp_rinvalid <= 0;
            end
        end
    end
    always_comb begin
        din = ufp_wdata;
        addrin = wptr;
        enwrite = (((~full) & ufp_wvalid) & ufp_wready);
    end
endmodule
module IcmpEchoMessageBlock_echosys_snsys_1 (
    output logic dfp_awvalid,
    output logic [31:0] dfp_wdata,
    output logic [7:0] dfp_awlen,
    output logic dfp_wlast,
    output logic dfp_wvalid,
    input dfp_awready,
    input dfp_wready,
    input ufp_addr_valid,
    output logic ufp_addr_ready,
    input [31:0] sourceAddr,
    input [31:0] destAddr,
    input [15:0] identifier,
    input ufp_valid,
    input ufp_last,
    input [15:0] checksum_data,
    input [31:0] ufp_data,
    input [15:0] sequence_number,
    output logic ufp_ready,
    input [15:0] total_length_data,
    input [7:0] _type,
    output logic ufp_misc_ready,
    input [7:0] code,
    input ufp_misc_valid,
    input commandValid,
    output logic commandReady,
    input [47:0] destMacAddr,
    input CLK,
    input RST
);
    logic commandValid_etherFrameGenerator_echo_echosys_snsys_1;
    logic [31:0] ufp_data_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic dfp_ready_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic CLK_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic [31:0] sourceAddr_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic RST_etherFrameTxBuffers_echo_echosys_snsys_1;
    logic dfp_valid_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic [31:0] dfp_data_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic [31:0] ufp_data_etherFrameTxBuffers_echo_echosys_snsys_1;
    logic dfp_awready_etherFrameTxBuffers_echo_echosys_snsys_1;
    logic CLK_etherFrameTxBuffers_echo_echosys_snsys_1;
    logic wvalid_etherFrameGenerator_echo_echosys_snsys_1;
    logic [15:0] total_length_data_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic [15:0] sequence_number_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic dfp_wlast_etherFrameTxBuffers_echo_echosys_snsys_1;
    logic [31:0] destAddr_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic [31:0] wdata_in_etherFrameGenerator_echo_echosys_snsys_1;
    logic wlast_in_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic wlast_in_etherFrameGenerator_echo_echosys_snsys_1;
    logic [31:0] wdata_in_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic commandReady_etherFrameGenerator_echo_echosys_snsys_1;
    logic wvalid_in_etherFrameGenerator_echo_echosys_snsys_1;
    logic [47:0] destMacAddr_etherFrameGenerator_echo_echosys_snsys_1;
    logic ufp_misc_ready_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic [31:0] dfp_wdata_etherFrameTxBuffers_echo_echosys_snsys_1;
    logic wlast_etherFrameGenerator_echo_echosys_snsys_1;
    logic dfp_last_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic wlast_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic ufp_valid_etherFrameTxBuffers_echo_echosys_snsys_1;
    logic dfp_wready_etherFrameTxBuffers_echo_echosys_snsys_1;
    logic RST_etherFrameGenerator_echo_echosys_snsys_1;
    logic [7:0] dfp_awlen_etherFrameTxBuffers_echo_echosys_snsys_1;
    logic dfp_misc_ready_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic ufp_ready_etherFrameTxBuffers_echo_echosys_snsys_1;
    logic dfp_awvalid_etherFrameTxBuffers_echo_echosys_snsys_1;
    logic CLK_etherFrameGenerator_echo_echosys_snsys_1;
    logic wvalid_in_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic ufp_misc_valid_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic [15:0] total_length_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic wready_out_etherFrameGenerator_echo_echosys_snsys_1;
    logic [15:0] etherType_etherFrameGenerator_echo_echosys_snsys_1;
    logic ufp_misc_ready_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic [31:0] wdata_etherFrameGenerator_echo_echosys_snsys_1;
    logic [7:0] _type_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic [15:0] totalLengthData_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic RST_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic ufp_last_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic [31:0] wdata_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic dfp_wvalid_etherFrameTxBuffers_echo_echosys_snsys_1;
    logic ufp_last_etherFrameTxBuffers_echo_echosys_snsys_1;
    logic [7:0] protocol_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic ufp_misc_valid_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic ufp_ready_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic [7:0] code_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic wready_etherFrameGenerator_echo_echosys_snsys_1;
    logic [15:0] identifier_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic [7:0] protocol_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic ufp_addr_ready_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic wready_out_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic ufp_valid_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic RST_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic wvalid_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic CLK_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic ufp_addr_valid_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic [15:0] etherType_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    logic [15:0] checksum_data_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic dfp_misc_valid_icmpEchoMessageGenerator_echo_echosys_snsys_1;
    logic wready_IpPacketSimpleGenerator_echo_echosys_snsys_1;

    etherFrameTxBuffers_echo_echosys_snsys_1 etherFrameTxBuffers_echo_echosys_snsys_1_inst (
        .CLK(CLK_etherFrameTxBuffers_echo_echosys_snsys_1),
        .RST(RST_etherFrameTxBuffers_echo_echosys_snsys_1),
        .ufp_valid(ufp_valid_etherFrameTxBuffers_echo_echosys_snsys_1),
        .ufp_data(ufp_data_etherFrameTxBuffers_echo_echosys_snsys_1),
        .ufp_last(ufp_last_etherFrameTxBuffers_echo_echosys_snsys_1),
        .ufp_ready(ufp_ready_etherFrameTxBuffers_echo_echosys_snsys_1),
        .dfp_wready(dfp_wready_etherFrameTxBuffers_echo_echosys_snsys_1),
        .dfp_wvalid(dfp_wvalid_etherFrameTxBuffers_echo_echosys_snsys_1),
        .dfp_wdata(dfp_wdata_etherFrameTxBuffers_echo_echosys_snsys_1),
        .dfp_wlast(dfp_wlast_etherFrameTxBuffers_echo_echosys_snsys_1),
        .dfp_awlen(dfp_awlen_etherFrameTxBuffers_echo_echosys_snsys_1),
        .dfp_awvalid(dfp_awvalid_etherFrameTxBuffers_echo_echosys_snsys_1),
        .dfp_awready(dfp_awready_etherFrameTxBuffers_echo_echosys_snsys_1)
    );
    IpPacketSimpleGenerator_echo_echosys_snsys_1 IpPacketSimpleGenerator_echo_echosys_snsys_1_inst (
        .CLK(CLK_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .RST(RST_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .wvalid(wvalid_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .wdata(wdata_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .wlast(wlast_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .wready(wready_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .wdata_in(wdata_in_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .wvalid_in(wvalid_in_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .wlast_in(wlast_in_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .wready_out(wready_out_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .ufp_addr_valid(ufp_addr_valid_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .ufp_misc_valid(ufp_misc_valid_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .ufp_addr_ready(ufp_addr_ready_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .ufp_misc_ready(ufp_misc_ready_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .totalLengthData(totalLengthData_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .sourceAddr(sourceAddr_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .destAddr(destAddr_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .protocol(protocol_IpPacketSimpleGenerator_echo_echosys_snsys_1),
        .etherType(etherType_IpPacketSimpleGenerator_echo_echosys_snsys_1)
    );
    icmpEchoMessageGenerator_echo_echosys_snsys_1 icmpEchoMessageGenerator_echo_echosys_snsys_1_inst (
        .CLK(CLK_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .RST(RST_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .dfp_data(dfp_data_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .dfp_valid(dfp_valid_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .dfp_last(dfp_last_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .dfp_ready(dfp_ready_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .dfp_misc_valid(dfp_misc_valid_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .dfp_misc_ready(dfp_misc_ready_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .total_length(total_length_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .protocol(protocol_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .ufp_misc_valid(ufp_misc_valid_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .ufp_misc_ready(ufp_misc_ready_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        ._type(_type_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .code(code_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .identifier(identifier_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .sequence_number(sequence_number_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .total_length_data(total_length_data_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .checksum_data(checksum_data_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .ufp_valid(ufp_valid_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .ufp_last(ufp_last_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .ufp_data(ufp_data_icmpEchoMessageGenerator_echo_echosys_snsys_1),
        .ufp_ready(ufp_ready_icmpEchoMessageGenerator_echo_echosys_snsys_1)
    );
    etherFrameGenerator_echo_echosys_snsys_1 etherFrameGenerator_echo_echosys_snsys_1_inst (
        .CLK(CLK_etherFrameGenerator_echo_echosys_snsys_1),
        .RST(RST_etherFrameGenerator_echo_echosys_snsys_1),
        .destMacAddr(destMacAddr_etherFrameGenerator_echo_echosys_snsys_1),
        .etherType(etherType_etherFrameGenerator_echo_echosys_snsys_1),
        .commandValid(commandValid_etherFrameGenerator_echo_echosys_snsys_1),
        .commandReady(commandReady_etherFrameGenerator_echo_echosys_snsys_1),
        .wdata(wdata_etherFrameGenerator_echo_echosys_snsys_1),
        .wvalid(wvalid_etherFrameGenerator_echo_echosys_snsys_1),
        .wlast(wlast_etherFrameGenerator_echo_echosys_snsys_1),
        .wready(wready_etherFrameGenerator_echo_echosys_snsys_1),
        .wvalid_in(wvalid_in_etherFrameGenerator_echo_echosys_snsys_1),
        .wdata_in(wdata_in_etherFrameGenerator_echo_echosys_snsys_1),
        .wlast_in(wlast_in_etherFrameGenerator_echo_echosys_snsys_1),
        .wready_out(wready_out_etherFrameGenerator_echo_echosys_snsys_1)
    );
    always_comb begin
        wdata_in_IpPacketSimpleGenerator_echo_echosys_snsys_1 = dfp_data_icmpEchoMessageGenerator_echo_echosys_snsys_1;
        wvalid_in_IpPacketSimpleGenerator_echo_echosys_snsys_1 = dfp_valid_icmpEchoMessageGenerator_echo_echosys_snsys_1;
        wlast_in_IpPacketSimpleGenerator_echo_echosys_snsys_1 = dfp_last_icmpEchoMessageGenerator_echo_echosys_snsys_1;
        ufp_misc_valid_IpPacketSimpleGenerator_echo_echosys_snsys_1 = dfp_misc_valid_icmpEchoMessageGenerator_echo_echosys_snsys_1;
        protocol_IpPacketSimpleGenerator_echo_echosys_snsys_1 = protocol_icmpEchoMessageGenerator_echo_echosys_snsys_1;
        totalLengthData_IpPacketSimpleGenerator_echo_echosys_snsys_1 = total_length_icmpEchoMessageGenerator_echo_echosys_snsys_1;
        wready_IpPacketSimpleGenerator_echo_echosys_snsys_1 = wready_out_etherFrameGenerator_echo_echosys_snsys_1;
        wready_etherFrameGenerator_echo_echosys_snsys_1 = ufp_ready_etherFrameTxBuffers_echo_echosys_snsys_1;
        ufp_valid_etherFrameTxBuffers_echo_echosys_snsys_1 = wvalid_etherFrameGenerator_echo_echosys_snsys_1;
        ufp_data_etherFrameTxBuffers_echo_echosys_snsys_1 = wdata_etherFrameGenerator_echo_echosys_snsys_1;
        ufp_last_etherFrameTxBuffers_echo_echosys_snsys_1 = wlast_etherFrameGenerator_echo_echosys_snsys_1;
        wdata_in_etherFrameGenerator_echo_echosys_snsys_1 = wdata_IpPacketSimpleGenerator_echo_echosys_snsys_1;
        wvalid_in_etherFrameGenerator_echo_echosys_snsys_1 = wvalid_IpPacketSimpleGenerator_echo_echosys_snsys_1;
        wlast_in_etherFrameGenerator_echo_echosys_snsys_1 = wlast_IpPacketSimpleGenerator_echo_echosys_snsys_1;
        etherType_etherFrameGenerator_echo_echosys_snsys_1 = etherType_IpPacketSimpleGenerator_echo_echosys_snsys_1;
        dfp_ready_icmpEchoMessageGenerator_echo_echosys_snsys_1 = wready_out_IpPacketSimpleGenerator_echo_echosys_snsys_1;
        dfp_misc_ready_icmpEchoMessageGenerator_echo_echosys_snsys_1 = ufp_misc_ready_IpPacketSimpleGenerator_echo_echosys_snsys_1;
    end
    always_comb begin
        dfp_awvalid = dfp_awvalid_etherFrameTxBuffers_echo_echosys_snsys_1;
        dfp_wdata = dfp_wdata_etherFrameTxBuffers_echo_echosys_snsys_1;
        dfp_awlen = dfp_awlen_etherFrameTxBuffers_echo_echosys_snsys_1;
        dfp_wlast = dfp_wlast_etherFrameTxBuffers_echo_echosys_snsys_1;
        dfp_wvalid = dfp_wvalid_etherFrameTxBuffers_echo_echosys_snsys_1;
        dfp_awready_etherFrameTxBuffers_echo_echosys_snsys_1 = dfp_awready;
        dfp_wready_etherFrameTxBuffers_echo_echosys_snsys_1 = dfp_wready;
        ufp_addr_valid_IpPacketSimpleGenerator_echo_echosys_snsys_1 = ufp_addr_valid;
        ufp_addr_ready = ufp_addr_ready_IpPacketSimpleGenerator_echo_echosys_snsys_1;
        sourceAddr_IpPacketSimpleGenerator_echo_echosys_snsys_1 = sourceAddr;
        destAddr_IpPacketSimpleGenerator_echo_echosys_snsys_1 = destAddr;
        identifier_icmpEchoMessageGenerator_echo_echosys_snsys_1 = identifier;
        ufp_valid_icmpEchoMessageGenerator_echo_echosys_snsys_1 = ufp_valid;
        ufp_last_icmpEchoMessageGenerator_echo_echosys_snsys_1 = ufp_last;
        checksum_data_icmpEchoMessageGenerator_echo_echosys_snsys_1 = checksum_data;
        ufp_data_icmpEchoMessageGenerator_echo_echosys_snsys_1 = ufp_data;
        sequence_number_icmpEchoMessageGenerator_echo_echosys_snsys_1 = sequence_number;
        ufp_ready = ufp_ready_icmpEchoMessageGenerator_echo_echosys_snsys_1;
        total_length_data_icmpEchoMessageGenerator_echo_echosys_snsys_1 = total_length_data;
        _type_icmpEchoMessageGenerator_echo_echosys_snsys_1 = _type;
        ufp_misc_ready = ufp_misc_ready_icmpEchoMessageGenerator_echo_echosys_snsys_1;
        code_icmpEchoMessageGenerator_echo_echosys_snsys_1 = code;
        ufp_misc_valid_icmpEchoMessageGenerator_echo_echosys_snsys_1 = ufp_misc_valid;
        commandValid_etherFrameGenerator_echo_echosys_snsys_1 = commandValid;
        commandReady = commandReady_etherFrameGenerator_echo_echosys_snsys_1;
        destMacAddr_etherFrameGenerator_echo_echosys_snsys_1 = destMacAddr;
    end
    always_comb begin
        CLK_etherFrameTxBuffers_echo_echosys_snsys_1 = CLK;
        RST_etherFrameTxBuffers_echo_echosys_snsys_1 = RST;
    end
    always_comb begin
        CLK_IpPacketSimpleGenerator_echo_echosys_snsys_1 = CLK;
        RST_IpPacketSimpleGenerator_echo_echosys_snsys_1 = RST;
    end
    always_comb begin
        CLK_icmpEchoMessageGenerator_echo_echosys_snsys_1 = CLK;
        RST_icmpEchoMessageGenerator_echo_echosys_snsys_1 = RST;
    end
    always_comb begin
        CLK_etherFrameGenerator_echo_echosys_snsys_1 = CLK;
        RST_etherFrameGenerator_echo_echosys_snsys_1 = RST;
    end
endmodule
module icmpEchoServer_echosys_snsys_1 (
    input CLK,
    input RST,
    input ip_addr_configured,
    input [31:0] configured_ip_addr,
    input [7:0] rx_type,
    input [15:0] rx_sequence_number,
    input [15:0] rx_identifier,
    input [15:0] rx_checksum_data_only,
    input rx_no_data_payload,
    input rx_icmp_info_valid,
    output logic rx_icmp_info_ready,
    input [31:0] rx_src_ipaddr,
    input [31:0] rx_dest_ipaddr,
    input [15:0] rx_total_length_data,
    input [31:0] rx_data,
    input rx_data_valid,
    input rx_data_invalid,
    input rx_data_full,
    input [12:0] rx_data_count,
    output logic rx_data_flush,
    output logic [12:0] rx_data_araddr,
    output logic rx_data_arvalid,
    input rx_data_arready,
    input [47:0] rx_src_hwaddr,
    input [47:0] rx_dest_hwaddr,
    input rx_icmp_last,
    output logic [7:0] tx_type,
    output logic [7:0] tx_code,
    output logic [15:0] tx_total_length_data,
    output logic [15:0] tx_sequence_number,
    output logic [15:0] tx_identifier,
    output logic [15:0] tx_checksum_data_only,
    output logic tx_icmp_misc_valid,
    input tx_icmp_misc_ready,
    output logic tx_icmp_data_valid,
    output logic tx_icmp_data_last,
    input tx_icmp_data_ready,
    output logic [31:0] tx_icmp_data,
    output logic [31:0] tx_src_ipaddr,
    output logic [31:0] tx_dest_ipaddr,
    output logic tx_ipaddr_valid,
    input tx_ipaddr_ready,
    output logic [47:0] tx_dest_hwaddr,
    output logic tx_hwaddr_valid,
    input tx_hwaddr_ready,
    output logic debug_valid,
    output logic [71:0] debug_data
);
    localparam idle = 0;
    localparam force_flush = 1;
    localparam replying = 2;
    localparam bufempty = 0;
    localparam bufreading = 1;

    reg [1:0] state;
    reg buffer_state;
    logic [31:0] rx_src_ipaddr_buf;
    logic [15:0] rx_identifier_buf;
    logic [12:0] buffer_read_done_counter;
    logic tx_hwaddr_done;
    logic [47:0] rx_src_hwaddr_buf;
    logic prevrx_data_arready;
    logic [1:0] prevstate;
    logic tx_icmp_data_valid_carry;
    logic noreply_flush;
    logic [15:0] rx_checksum_data_only_buf;
    logic rx_no_data_payload_buf;
    logic noreply;
    logic [12:0] addr_minusone;
    logic reply_all_done;
    logic tx_icmp_misc_done;
    logic [15:0] rx_sequence_number_buf;
    logic doreply;
    logic [12:0] buffer_read_addr;
    logic [15:0] rx_total_length_data_buf;
    logic tx_ipaddr_done;
    logic prevrx_data_arvalid;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                idle: begin
                    if (((rx_icmp_info_ready & rx_icmp_info_valid) & noreply_flush)) begin
                        state <= force_flush;
                    end else if (((rx_icmp_info_ready & rx_icmp_info_valid) & doreply)) begin
                        state <= replying;
                    end
                end
                force_flush: begin
                    if ((rx_data_flush & rx_data_full)) begin
                        state <= idle;
                    end
                end
                replying: begin
                    if (reply_all_done) begin
                        state <= force_flush;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        addr_minusone = (~13'd0);
    end
    always_comb begin
        noreply = ((~ip_addr_configured) | (~(configured_ip_addr == rx_dest_ipaddr)));
        doreply = (ip_addr_configured & (configured_ip_addr == rx_dest_ipaddr));
        noreply_flush = (noreply & (~rx_no_data_payload));
        reply_all_done = (((tx_icmp_misc_done & tx_ipaddr_done) & tx_hwaddr_done) & (buffer_read_done_counter == rx_data_count));
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            rx_src_hwaddr_buf <= 0;
        end else begin
            if ((state == idle)) begin
                if (rx_icmp_last) begin
                    rx_src_hwaddr_buf <= rx_src_hwaddr;
                end
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            rx_checksum_data_only_buf <= 0;
            rx_identifier_buf <= 0;
            rx_no_data_payload_buf <= 0;
            rx_sequence_number_buf <= 0;
            rx_src_ipaddr_buf <= 0;
            rx_total_length_data_buf <= 0;
        end else begin
            if ((state == idle)) begin
                rx_no_data_payload_buf <= rx_no_data_payload;
                if (((rx_icmp_info_ready & rx_icmp_info_valid) & doreply)) begin
                    rx_sequence_number_buf <= rx_sequence_number;
                    rx_identifier_buf <= rx_identifier;
                    rx_checksum_data_only_buf <= rx_checksum_data_only;
                    rx_src_ipaddr_buf <= rx_src_ipaddr;
                    rx_total_length_data_buf <= rx_total_length_data;
                end
            end
        end
    end
    always_comb begin
        tx_dest_hwaddr = rx_src_hwaddr_buf;
        tx_type = 0;
        tx_code = 0;
        tx_sequence_number = rx_sequence_number_buf;
        tx_identifier = rx_identifier_buf;
        tx_checksum_data_only = rx_checksum_data_only_buf;
        tx_total_length_data = rx_total_length_data_buf;
        tx_src_ipaddr = configured_ip_addr;
        if ((state == replying)) begin
            tx_icmp_misc_valid = (~tx_icmp_misc_done);
            tx_ipaddr_valid = (~tx_ipaddr_done);
            tx_dest_ipaddr = rx_src_ipaddr_buf;
            tx_hwaddr_valid = (~tx_hwaddr_done);
            if (rx_no_data_payload_buf) begin
                tx_icmp_data_valid = 0;
                tx_icmp_data_last = 0;
                tx_icmp_data = 0;
            end else begin
                tx_icmp_data_valid = ((buffer_read_addr == (buffer_read_done_counter + 1)) & (rx_data_valid | tx_icmp_data_valid_carry));
                tx_icmp_data_last = ((buffer_read_done_counter + 1) == rx_data_count);
                tx_icmp_data = rx_data;
            end
        end else begin
            tx_icmp_misc_valid = 0;
            tx_ipaddr_valid = 0;
            tx_dest_ipaddr = 0;
            tx_icmp_data_valid = 0;
            tx_icmp_data_last = 0;
            tx_icmp_data = 0;
            tx_hwaddr_valid = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            tx_hwaddr_done <= 0;
            tx_icmp_data_valid_carry <= 0;
            tx_icmp_misc_done <= 0;
            tx_ipaddr_done <= 0;
        end else begin
            if ((state == replying)) begin
                if ((tx_icmp_data_valid | tx_icmp_data_valid_carry)) begin
                    if (tx_icmp_data_ready) begin
                        tx_icmp_data_valid_carry <= 0;
                    end else begin
                        tx_icmp_data_valid_carry <= 1;
                    end
                end
                if ((tx_icmp_misc_valid & tx_icmp_misc_ready)) begin
                    tx_icmp_misc_done <= 1;
                end
                if ((tx_ipaddr_valid & tx_ipaddr_ready)) begin
                    tx_ipaddr_done <= 1;
                end
                if ((tx_hwaddr_valid & tx_hwaddr_ready)) begin
                    tx_hwaddr_done <= 1;
                end
            end else begin
                tx_icmp_misc_done <= 0;
                tx_ipaddr_done <= 0;
                tx_hwaddr_done <= 0;
            end
        end
    end
    always_comb begin
        if ((state == idle)) begin
            rx_icmp_info_ready = 1;
        end else begin
            rx_icmp_info_ready = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            buffer_state <= 0;
        end else begin
            case (buffer_state)
                bufempty: begin
                    if (rx_data_full) begin
                        buffer_state <= bufreading;
                    end
                end
                bufreading: begin
                    if ((rx_data_flush & rx_data_full)) begin
                        buffer_state <= bufempty;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        if ((state == force_flush)) begin
            rx_data_flush = 1;
        end else begin
            rx_data_flush = 0;
        end
        if ((state == replying)) begin
            if ((buffer_state == bufreading)) begin
                if (((buffer_read_addr == buffer_read_done_counter) | (tx_icmp_data_valid & tx_icmp_data_ready))) begin
                    rx_data_araddr = buffer_read_addr;
                end else begin
                    rx_data_araddr = (buffer_read_addr + addr_minusone);
                end
                if ((buffer_read_addr == rx_data_count)) begin
                    rx_data_arvalid = 0;
                end else begin
                    rx_data_arvalid = ((buffer_read_addr == buffer_read_done_counter) | (tx_icmp_data_valid & tx_icmp_data_ready));
                end
            end else begin
                rx_data_araddr = 0;
                rx_data_arvalid = 0;
            end
        end else begin
            rx_data_araddr = 0;
            rx_data_arvalid = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            buffer_read_addr <= 0;
            buffer_read_done_counter <= 0;
        end else begin
            if ((state == replying)) begin
                if ((rx_data_arvalid & rx_data_arready)) begin
                    buffer_read_addr <= (buffer_read_addr + 1);
                end
                if ((tx_icmp_data_valid & tx_icmp_data_ready)) begin
                    buffer_read_done_counter <= (buffer_read_done_counter + 1);
                end
            end else begin
                buffer_read_addr <= 0;
                buffer_read_done_counter <= 0;
            end
        end
    end
    always_comb begin
        debug_data = ({ 2'd0, state, rx_data_count[3:0], { rx_data_araddr[3:0], buffer_read_done_counter[3:0], buffer_read_addr[3:0], 2'd0, rx_no_data_payload_buf, tx_icmp_data_ready }, { tx_icmp_data_ready, tx_icmp_data_valid, rx_data_arready, rx_data_arvalid, buffer_state, rx_data_valid, rx_data_invalid, rx_data_full }, rx_data, 8'd0 } >> 8);
        if ((~(prevstate == state))) begin
            debug_valid = 1;
        end else if ((rx_data_valid | rx_data_invalid)) begin
            debug_valid = 1;
        end else if (((~(prevrx_data_arready == rx_data_arready)) | (~(prevrx_data_arvalid == rx_data_arvalid)))) begin
            debug_valid = 1;
        end else if ((rx_data_arvalid & rx_data_arready)) begin
            debug_valid = 1;
        end else begin
            debug_valid = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            prevrx_data_arready <= 0;
            prevrx_data_arvalid <= 0;
            prevstate <= 0;
        end else begin
            prevstate <= state;
            prevrx_data_arvalid <= rx_data_arvalid;
            prevrx_data_arready <= rx_data_arready;
            if ((~(prevstate == state))) begin
                
            end else if ((rx_data_valid | rx_data_invalid)) begin
                
            end else if (((~(prevrx_data_arready == rx_data_arready)) | (~(prevrx_data_arvalid == rx_data_arvalid)))) begin
                
            end else if ((rx_data_arvalid & rx_data_arready)) begin
                
            end else begin
                
            end
        end
    end
endmodule
module etherFrameTxBuffers_echo_echosys_snsys_1 (
    input CLK,
    input RST,
    input ufp_valid,
    input [31:0] ufp_data,
    input ufp_last,
    output logic ufp_ready,
    input dfp_wready,
    output logic dfp_wvalid,
    output logic [31:0] dfp_wdata,
    output logic dfp_wlast,
    output logic [7:0] dfp_awlen,
    output logic dfp_awvalid,
    input dfp_awready
);
    logic [7:0] prev_wptr;
    logic full;
    logic enread;
    logic [31:0] din;
    logic [7:0] addrout;
    logic [7:0] awlen_buf;
    logic awdone;
    logic enwrite;
    logic [7:0] addrin;
    logic [7:0] wptr;
    logic [31:0] dout_ramSdpRfInst_;
    logic [7:0] rptr;

    ram_sdp_rf #(
        .addrlen(8),
        .datawid(32)
    ) _instramSdpRfInst_ (
        .clk(CLK),
        .enread(enread),
        .enwrite(enwrite),
        .addrin(addrin),
        .addrout(addrout),
        .din(din),
        .dout(dout_ramSdpRfInst_)
    );
    always_comb begin
        addrin = wptr;
        addrout = rptr;
        din = ufp_data;
        enread = 1'd1;
        enwrite = 0;
        ufp_ready = (~full);
        dfp_wlast = (full & (wptr == (rptr + 1)));
        dfp_wvalid = (~(prev_wptr == rptr));
        dfp_wdata = dout_ramSdpRfInst_;
        dfp_awvalid = (full & (~awdone));
        dfp_awlen = awlen_buf;
        if (((full & (wptr == rptr)) & awdone)) begin
            
        end else begin
            if ((~full)) begin
                if (ufp_valid) begin
                    enwrite = 1'd1;
                    if (ufp_last) begin
                        
                    end
                end
            end
            if ((dfp_wvalid & dfp_wready)) begin
                addrout = (rptr + 8'd1);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            awdone <= 0;
            awlen_buf <= 0;
            full <= 0;
            prev_wptr <= 0;
            rptr <= 0;
            wptr <= 0;
        end else begin
            if (((full & (wptr == rptr)) & awdone)) begin
                wptr <= 0;
                rptr <= 0;
                awlen_buf <= 0;
                full <= 0;
                prev_wptr <= 0;
                awdone <= 0;
            end else begin
                prev_wptr <= wptr;
                awdone <= (awdone | (dfp_awvalid & dfp_awready));
                if ((~full)) begin
                    if (ufp_valid) begin
                        wptr <= (wptr + 8'd1);
                        if (ufp_last) begin
                            awlen_buf <= wptr;
                            full <= 1;
                        end
                    end
                end
                if ((dfp_wvalid & dfp_wready)) begin
                    rptr <= (rptr + 8'd1);
                end
            end
        end
    end
endmodule
module IpPacketSimpleGenerator_echo_echosys_snsys_1 (
    input CLK,
    input RST,
    output logic wvalid,
    output logic [31:0] wdata,
    output logic wlast,
    input wready,
    input [31:0] wdata_in,
    input wvalid_in,
    input wlast_in,
    output logic wready_out,
    input ufp_addr_valid,
    input ufp_misc_valid,
    output logic ufp_addr_ready,
    output logic ufp_misc_ready,
    input [15:0] totalLengthData,
    input [31:0] sourceAddr,
    input [31:0] destAddr,
    input [7:0] protocol,
    output logic [15:0] etherType
);
    localparam idle = 0;
    localparam header = 1;
    localparam payload = 2;

    reg [1:0] state;
    logic [7:0] protocolBuf;
    logic [3:0] headerCounter;
    logic [15:0] identification;
    logic [19:0] sumh1;
    logic [15:0] checksum;
    logic [19:0] sum_first;
    logic [19:0] sumh2;
    logic [7:0] ttl;
    logic [19:0] sumh1_2;
    logic [19:0] sumh4;
    logic [19:0] sumh5;
    logic ufp_addr_done;
    logic [15:0] totalLengthIp;
    logic [31:0] sourceAddrBuf;
    logic ufp_misc_done;
    logic [15:0] sum_third;
    logic [15:0] totalLengthDataBuf;
    logic [19:0] sumh4_5;
    logic [31:0] destAddrBuf;
    logic [16:0] sum_second;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                idle: begin
                    if ((((ufp_addr_ready & ufp_addr_valid) | ufp_addr_done) & ((ufp_misc_valid & ufp_misc_ready) | ufp_misc_done))) begin
                        state <= header;
                    end
                end
                header: begin
                    if ((((headerCounter == 4) & wvalid) & wready)) begin
                        state <= payload;
                    end
                end
                payload: begin
                    if (((wvalid & wready) & wlast)) begin
                        state <= idle;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        if ((state == header)) begin
            wvalid = 1;
            wready_out = 0;
            wlast = 0;
            if ((headerCounter == 0)) begin
                wdata = { totalLengthIp[7:0], totalLengthIp[15:8], 16'd69 };
            end else if ((headerCounter == 1)) begin
                wdata = { 16'd0, identification[7:0], identification[15:8] };
            end else if ((headerCounter == 2)) begin
                wdata = { checksum[7:0], checksum[15:8], protocolBuf, ttl };
            end else if ((headerCounter == 3)) begin
                wdata = { sourceAddrBuf[7:0], sourceAddrBuf[15:8], sourceAddrBuf[23:16], sourceAddrBuf[31:24] };
            end else begin
                wdata = { destAddrBuf[7:0], destAddrBuf[15:8], destAddrBuf[23:16], destAddrBuf[31:24] };
            end
        end else if ((state == payload)) begin
            wvalid = wvalid_in;
            wdata = wdata_in;
            wlast = wlast_in;
            wready_out = wready;
        end else begin
            wvalid = 0;
            wdata = 0;
            wlast = 0;
            wready_out = 0;
        end
    end
    always_comb begin
        etherType = 2048;
        totalLengthIp = (totalLengthDataBuf + 20);
        ttl = 8'd128;
        sumh1 = ({ 4'd0, 16'd17664 } + { 4'd0, totalLengthIp });
        sumh2 = ({ 4'd0, identification } + { 4'd0, ttl, protocolBuf });
        sumh4 = ({ 4'd0, sourceAddrBuf[31:16] } + { 4'd0, sourceAddrBuf[15:0] });
        sumh5 = ({ 4'd0, destAddrBuf[31:16] } + { 4'd0, destAddrBuf[15:0] });
        sum_first = ((sumh1_2 + sumh4_5) | 20'd0);
        sum_second = (({ 1'd0, sum_first[15:0] } + { 13'd0, sum_first[19:16] }) | 17'd0);
        checksum = 0;
        if ((state == header)) begin
            if ((headerCounter == 0)) begin
                
            end else if ((headerCounter == 1)) begin
                
            end else if ((headerCounter == 2)) begin
                checksum = (~sum_third);
            end
        end
        if ((state == idle)) begin
            ufp_addr_ready = (~ufp_addr_done);
            ufp_misc_ready = (~ufp_misc_done);
            if ((ufp_addr_ready & ufp_addr_valid)) begin
                
            end
            if ((ufp_misc_ready & ufp_misc_valid)) begin
                
            end
        end else begin
            ufp_addr_ready = 0;
            ufp_misc_ready = 0;
        end
        if ((state == header)) begin
            if ((wvalid & wready)) begin
                
            end
        end else begin
            
        end
        if (((state == payload) && ((wvalid & wready) & wlast))) begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            destAddrBuf <= 0;
            headerCounter <= 0;
            identification <= 0;
            protocolBuf <= 0;
            sourceAddrBuf <= 0;
            sum_third <= 0;
            sumh1_2 <= 0;
            sumh4_5 <= 0;
            totalLengthDataBuf <= 0;
            ufp_addr_done <= 0;
            ufp_misc_done <= 0;
        end else begin
            if ((state == header)) begin
                if ((headerCounter == 0)) begin
                    sumh1_2 <= (sumh1 + sumh2);
                    sumh4_5 <= (sumh4 + sumh5);
                end else if ((headerCounter == 1)) begin
                    sum_third <= (sum_second[15:0] + { 15'd0, sum_second[16] });
                end else if ((headerCounter == 2)) begin
                    
                end
            end
            if ((state == idle)) begin
                if ((ufp_addr_ready & ufp_addr_valid)) begin
                    sourceAddrBuf <= sourceAddr;
                    destAddrBuf <= destAddr;
                    ufp_addr_done <= 1'd1;
                end
                if ((ufp_misc_ready & ufp_misc_valid)) begin
                    ufp_misc_done <= 1'd1;
                    protocolBuf <= protocol;
                    totalLengthDataBuf <= totalLengthData;
                end
            end else begin
                ufp_addr_done <= 0;
                ufp_misc_done <= 0;
            end
            if ((state == header)) begin
                if ((wvalid & wready)) begin
                    headerCounter <= (headerCounter + 4'd1);
                end
            end else begin
                headerCounter <= 0;
            end
            if (((state == payload) && ((wvalid & wready) & wlast))) begin
                identification <= (identification + 16'd1);
            end
        end
    end
endmodule
module icmpEchoMessageGenerator_echo_echosys_snsys_1 (
    input CLK,
    input RST,
    output logic [31:0] dfp_data,
    output logic dfp_valid,
    output logic dfp_last,
    input dfp_ready,
    output logic dfp_misc_valid,
    input dfp_misc_ready,
    output logic [15:0] total_length,
    output logic [7:0] protocol,
    input ufp_misc_valid,
    output logic ufp_misc_ready,
    input [7:0] _type,
    input [7:0] code,
    input [15:0] identifier,
    input [15:0] sequence_number,
    input [15:0] total_length_data,
    input [15:0] checksum_data,
    input ufp_valid,
    input ufp_last,
    input [31:0] ufp_data,
    output logic ufp_ready
);
    localparam read_misc = 0;
    localparam send_header = 1;
    localparam send_data_body = 2;

    reg [1:0] state;
    logic header_send_done;
    logic [7:0] type_buf;
    logic dfp_misc_done;
    logic [15:0] identifier_buf;
    logic [7:0] header_send_count;
    logic [17:0] checksum_with_carry2;
    logic [7:0] code_buf;
    logic [16:0] checksum_total_pre;
    logic [15:0] sequence_number_buf;
    logic [17:0] checksum_with_carry_all;
    logic [15:0] total_length_data_buf;
    logic [15:0] checksum_total;
    logic [17:0] checksum_with_carry1;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                read_misc: begin
                    if ((ufp_misc_ready & ufp_misc_valid)) begin
                        state <= send_header;
                    end
                end
                send_header: begin
                    if ((header_send_done & dfp_last)) begin
                        state <= read_misc;
                    end else if ((header_send_done & (~dfp_last))) begin
                        state <= send_data_body;
                    end
                end
                send_data_body: begin
                    if (((dfp_valid & dfp_ready) & dfp_last)) begin
                        state <= read_misc;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        if ((state == send_header)) begin
            header_send_done = (((header_send_count == 1) & dfp_valid) & dfp_ready);
        end else begin
            header_send_done = 0;
        end
    end
    always_comb begin
        if ((state == read_misc)) begin
            ufp_misc_ready = 1;
        end else begin
            ufp_misc_ready = 0;
        end
        if ((state == send_data_body)) begin
            ufp_ready = dfp_ready;
        end else begin
            ufp_ready = 0;
        end
    end
    always_comb begin
        protocol = 1;
        total_length = (total_length_data_buf + 8);
        if (((state == send_header) | (state == send_data_body))) begin
            dfp_misc_valid = (~dfp_misc_done);
        end else begin
            dfp_misc_valid = 0;
        end
        if ((state == send_header)) begin
            dfp_valid = 1;
            if ((header_send_count == 0)) begin
                dfp_last = 0;
                dfp_data = { checksum_total[7:0], checksum_total[15:8], code_buf, type_buf };
            end else if ((header_send_count == 1)) begin
                dfp_last = (total_length_data_buf == 0);
                dfp_data = { sequence_number_buf[7:0], sequence_number_buf[15:8], identifier_buf[7:0], identifier_buf[15:8] };
            end else begin
                dfp_last = 0;
                dfp_data = 0;
            end
        end else if ((state == send_data_body)) begin
            dfp_valid = ufp_valid;
            dfp_last = ufp_last;
            dfp_data = ufp_data;
        end else begin
            dfp_valid = 0;
            dfp_last = 0;
            dfp_data = 0;
        end
    end
    always_comb begin
        if ((state == read_misc)) begin
            checksum_with_carry1 = (({ 2'd0, identifier } + { 2'd0, sequence_number }) | 18'd0);
            checksum_with_carry2 = ({ 2'd0, code, _type } + { 2'd0, checksum_data });
            checksum_with_carry_all = (checksum_with_carry1 + checksum_with_carry2);
            checksum_total_pre = (({ 1'd0, checksum_with_carry_all[15:0] } + { 15'd0, checksum_with_carry_all[17:16] }) | 17'd0);
        end else begin
            checksum_with_carry1 = 0;
            checksum_with_carry2 = 0;
            checksum_with_carry_all = 0;
            checksum_total_pre = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            checksum_total <= 0;
        end else begin
            if ((state == read_misc)) begin
                checksum_total <= (~(checksum_total_pre[15:0] + { 15'd0, checksum_total_pre[16] }));
            end else begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            header_send_count <= 0;
        end else begin
            if ((state == send_header)) begin
                if ((dfp_valid & dfp_ready)) begin
                    header_send_count <= (header_send_count + 8'd1);
                end
            end else begin
                header_send_count <= 0;
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            code_buf <= 0;
            dfp_misc_done <= 0;
            identifier_buf <= 0;
            sequence_number_buf <= 0;
            total_length_data_buf <= 0;
            type_buf <= 0;
        end else begin
            if ((state == read_misc)) begin
                identifier_buf <= identifier;
                sequence_number_buf <= sequence_number;
                total_length_data_buf <= total_length_data;
                type_buf <= _type;
                code_buf <= code;
            end
            if ((state == read_misc)) begin
                dfp_misc_done <= 0;
            end else if (((state == send_header) | (state == send_data_body))) begin
                if ((dfp_misc_valid & dfp_misc_ready)) begin
                    dfp_misc_done <= 1'd1;
                end
            end
        end
    end
endmodule
module etherFrameGenerator_echo_echosys_snsys_1 (
    input CLK,
    input RST,
    input [47:0] destMacAddr,
    input [15:0] etherType,
    input commandValid,
    output logic commandReady,
    output logic [31:0] wdata,
    output logic wvalid,
    output logic wlast,
    input wready,
    input wvalid_in,
    input [31:0] wdata_in,
    input wlast_in,
    output logic wready_out
);
    localparam idle = 0;
    localparam header = 1;
    localparam payload = 2;
    localparam lastpayload = 3;

    reg [1:0] state;
    logic [2:0] headerCounter;
    logic [47:0] destMacAddrBuf;
    logic [47:0] sourceMacAddr;
    logic [15:0] wdataHalfWordBuf;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                idle: begin
                    if ((commandValid & commandReady)) begin
                        state <= header;
                    end
                end
                header: begin
                    if ((((headerCounter == 2) & wvalid) & wready)) begin
                        state <= payload;
                    end
                end
                payload: begin
                    if (((wlast_in & wvalid) & wready)) begin
                        state <= lastpayload;
                    end
                end
                lastpayload: begin
                    if ((wvalid & wready)) begin
                        state <= idle;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        commandReady = 0;
        { wdata, wvalid, wlast } = 0;
        wready_out = 0;
        if ((state == idle)) begin
            commandReady = 1;
        end else if ((state == header)) begin
            wvalid = 1;
            if ((headerCounter == 0)) begin
                wdata = { destMacAddrBuf[23:16], destMacAddrBuf[31:24], destMacAddrBuf[39:32], destMacAddrBuf[47:40] };
            end else if ((headerCounter == 1)) begin
                wdata = { sourceMacAddr[39:32], sourceMacAddr[47:40], destMacAddrBuf[7:0], destMacAddrBuf[15:8] };
            end else if ((headerCounter == 2)) begin
                wdata = { sourceMacAddr[7:0], sourceMacAddr[15:8], sourceMacAddr[23:16], sourceMacAddr[31:24] };
            end
        end else if ((state == payload)) begin
            wvalid = wvalid_in;
            wready_out = wready;
            wdata = { wdata_in[15:0], wdataHalfWordBuf };
        end else if ((state == lastpayload)) begin
            wlast = 1;
            wdata = { 16'd0, wdataHalfWordBuf };
            wvalid = 1;
        end
    end
    always_comb begin
        sourceMacAddr = 48'd1577122510;
        if ((state == idle)) begin
            
        end
        if ((state == header)) begin
            if ((wvalid & wready)) begin
                
            end
        end else begin
            
        end
        if ((state == idle)) begin
            
        end else if ((state == payload)) begin
            if ((wvalid & wready)) begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            destMacAddrBuf <= 0;
            headerCounter <= 0;
            wdataHalfWordBuf <= 0;
        end else begin
            if ((state == idle)) begin
                destMacAddrBuf <= destMacAddr;
            end
            if ((state == header)) begin
                if ((wvalid & wready)) begin
                    headerCounter <= (headerCounter + 3'd1);
                end
            end else begin
                headerCounter <= 0;
            end
            if ((state == idle)) begin
                wdataHalfWordBuf <= { etherType[7:0], etherType[15:8] };
            end else if ((state == payload)) begin
                if ((wvalid & wready)) begin
                    wdataHalfWordBuf <= wdata_in[31:16];
                end
            end
        end
    end
endmodule
module macLoopBack_tcpsrvsys_snsys_1 (
    input CLK,
    input RST,
    input ufp_hwaddr_valid,
    output logic dfp_valid,
    input dfp_ready,
    input [47:0] ufp_hwaddr,
    output logic [47:0] dfp_hwaddr,
    input tx_misc_valid,
    input tx_misc_ready
);
    logic [31:0] tx_trans_count;
    logic [31:0] ether_trans_count;

    always_comb begin
        dfp_valid = (~(tx_trans_count == ether_trans_count));
        if ((tx_misc_valid & tx_misc_ready)) begin
            
        end
        if ((dfp_ready & dfp_valid)) begin
            
        end
        if (ufp_hwaddr_valid) begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            dfp_hwaddr <= 0;
            ether_trans_count <= 0;
            tx_trans_count <= 0;
        end else begin
            if ((tx_misc_valid & tx_misc_ready)) begin
                tx_trans_count <= (32'd1 + tx_trans_count);
            end
            if ((dfp_ready & dfp_valid)) begin
                ether_trans_count <= (ether_trans_count + 32'd1);
            end
            if (ufp_hwaddr_valid) begin
                dfp_hwaddr <= ufp_hwaddr;
            end
        end
    end
endmodule
module dummyio_tcpsrvsys_snsys_1 (
    output logic [15:0] dummyout16_80,
    input CLK,
    input RST
);
    always_comb begin
        dummyout16_80 = 80;
    end
endmodule
module SimpleTcpServer_simTcpSrvSys_snsys_1 (
    input CLK,
    input RST,
    input config_valid,
    input [15:0] config_src_port,
    input [31:0] config_src_addr,
    input [31:0] rx_src_addr,
    input [31:0] rx_dest_addr,
    input rx_no_data_payload,
    input [15:0] rx_src_port,
    input [15:0] rx_dest_port,
    input [31:0] rx_seq_number,
    input [31:0] rx_ack_number,
    input [5:0] rx_flags,
    input [15:0] rx_window,
    input [15:0] rx_checksum,
    input [15:0] rx_urg_pointer,
    input [15:0] rx_payload_length,
    input rx_misc_valid,
    output logic rx_misc_ready,
    input rx_data_valid,
    input rx_data_last,
    output logic rx_data_ready,
    input [31:0] rx_data,
    output logic [31:0] dfp_rx_data,
    output logic [1:0] dfp_rx_data_strb,
    output logic dfp_rx_data_valid,
    input dfp_rx_data_ready,
    input [31:0] ufp_tx_data,
    input ufp_tx_data_valid,
    input ufp_tx_data_last,
    output logic ufp_tx_data_ready,
    input [15:0] ufp_tx_checksum_data_only,
    input [15:0] ufp_tx_total_length_data_only,
    output logic tx_misc_valid,
    input tx_misc_ready,
    output logic [31:0] tx_src_addr,
    output logic [31:0] tx_dest_addr,
    output logic [15:0] tx_src_port,
    output logic [15:0] tx_dest_port,
    output logic [31:0] tx_seq_number,
    output logic [31:0] tx_ack_number,
    output logic [5:0] tx_flags,
    output logic [15:0] tx_window,
    output logic [15:0] tx_urg_pointer,
    output logic [15:0] tx_checksum_data_only,
    output logic [15:0] tx_total_length_data_only,
    output logic tx_data_valid,
    output logic tx_data_last,
    output logic [31:0] tx_data,
    input tx_data_ready,
    output logic debug_valid_srv,
    output logic [71:0] debug_data_srv
);
    localparam closed = 0;
    localparam listen = 1;
    localparam syn_rcvd = 2;
    localparam estab = 3;
    localparam close_wait = 4;
    localparam last_ack = 5;
    localparam close_wait_init = 0;
    localparam close_wait_flush_tx = 1;
    localparam close_wait_send_ack = 2;
    localparam close_wait_send_fin = 3;
    localparam rx_read_header = 0;
    localparam rx_idle = 1;
    localparam rx_read_data = 2;
    localparam rx_discard_data = 3;
    localparam tx_idle = 0;
    localparam tx_send_header = 1;
    localparam tx_send_data = 2;

    reg [2:0] connection_state;
    reg [1:0] close_wait_sub_state;
    reg [1:0] rx_state;
    reg [1:0] tx_state;
    logic tx_next;
    logic [31:0] rcv_nxt;
    logic rx_fsm_to_idle;
    logic [15:0] snd_wnd;
    logic rx_ack_valid;
    logic [31:0] snd_una;
    logic tx_trans_done;
    logic [15:0] rx_window_buf;
    logic fin_detected;
    logic [31:0] connection_dest_addr;
    logic [15:0] tx_rcv_window;
    logic [15:0] rx_read_data_counter;
    logic [15:0] ufp_tx_checksum_data_only_buf;
    logic [15:0] ufp_tx_total_length_data_only_buf;
    logic [2:0] prev_connection_state;
    logic transcond_rx_to_read_data;
    logic [31:0] rx_src_addr_buf;
    logic rx_discard;
    logic [15:0] rx_urg_pointer_buf;
    logic rx_payload_not_aligned;
    logic ufp_tx_data_valid_buf;
    logic [31:0] tx_init_seq_number;
    logic [1:0] rx_payload_last_strb;
    logic tx_fsm_to_idle;
    logic rx_acceptable_packet;
    logic fin_ack_detected;
    logic [71:0] prev_debug_data_srv;
    logic rx_no_data_payload_buf;
    logic [31:0] prev_rcv_nxt;
    logic syn_detected;
    logic [15:0] rx_checksum_buf;
    logic syn_detected_buf;
    logic [15:0] rx_payload_length_buf;
    logic syn_ack_detected;
    logic tx_trans_done_comb;
    logic [15:0] rx_dest_port_buf;
    logic tx_dispatched_syn_rcvd;
    logic [31:0] snd_nxt;
    logic rx_target_self;
    logic tx_no_data_payload;
    logic fin_detected_buf;
    logic syn_ack_detected_buf;
    logic [15:0] config_src_port_buf;
    logic [31:0] rx_ack_number_buf;
    logic [15:0] rx_payload_dword_count;
    logic [15:0] rx_src_port_buf;
    logic [31:0] rx_seq_number_buf;
    logic rx_next;
    logic [5:0] rx_flags_buf;
    logic [31:0] rx_init_seq_number;
    logic ack_update_required;
    logic [31:0] config_src_addr_buf;
    logic [15:0] rx_init_window;
    logic [31:0] rx_dest_addr_buf;
    logic [15:0] connection_dest_port;
    logic rx_seq_valid;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            config_src_addr_buf <= 0;
            config_src_port_buf <= 0;
        end else begin
            if (config_valid) begin
                config_src_addr_buf <= config_src_addr;
                config_src_port_buf <= config_src_port;
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            connection_state <= 0;
        end else begin
            case (connection_state)
                closed: begin
                    if (config_valid) begin
                        connection_state <= listen;
                    end
                end
                listen: begin
                    if (((syn_detected_buf | syn_detected) & rx_fsm_to_idle)) begin
                        connection_state <= syn_rcvd;
                    end
                end
                syn_rcvd: begin
                    if (((syn_ack_detected_buf | syn_ack_detected) & rx_fsm_to_idle)) begin
                        connection_state <= estab;
                    end
                end
                estab: begin
                    if (((fin_detected_buf | fin_detected) & rx_fsm_to_idle)) begin
                        connection_state <= close_wait;
                    end
                end
                close_wait: begin
                    if (((close_wait_sub_state == close_wait_send_fin) && ((tx_state == tx_send_header) && ((tx_misc_ready & tx_misc_valid) & (tx_no_data_payload | tx_trans_done_comb))))) begin
                        connection_state <= last_ack;
                    end
                end
                last_ack: begin
                    if (fin_ack_detected) begin
                        connection_state <= closed;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            close_wait_sub_state <= 0;
        end else begin
            case (close_wait_sub_state)
                close_wait_init: begin
                    if (((connection_state == estab) && ((fin_detected_buf | fin_detected) & rx_fsm_to_idle))) begin
                        close_wait_sub_state <= close_wait_flush_tx;
                    end
                end
                close_wait_flush_tx: begin
                    if ((tx_state == tx_idle)) begin
                        close_wait_sub_state <= close_wait_send_ack;
                    end
                end
                close_wait_send_ack: begin
                    if (((tx_state == tx_send_header) && ((tx_misc_ready & tx_misc_valid) & (tx_no_data_payload | tx_trans_done_comb)))) begin
                        close_wait_sub_state <= close_wait_send_fin;
                    end
                end
                close_wait_send_fin: begin
                    if (((tx_state == tx_send_header) && ((tx_misc_ready & tx_misc_valid) & (tx_no_data_payload | tx_trans_done_comb)))) begin
                        close_wait_sub_state <= close_wait_init;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            rx_state <= 0;
        end else begin
            case (rx_state)
                rx_read_header: begin
                    if (((rx_misc_ready & rx_misc_valid) & rx_no_data_payload)) begin
                        rx_state <= rx_idle;
                    end else if ((((rx_misc_ready & rx_misc_valid) & (~rx_no_data_payload)) & (~rx_discard))) begin
                        rx_state <= rx_read_data;
                    end else if ((((rx_misc_ready & rx_misc_valid) & (~rx_no_data_payload)) & rx_discard)) begin
                        rx_state <= rx_discard_data;
                    end
                end
                rx_idle: begin
                    if (rx_next) begin
                        rx_state <= rx_read_header;
                    end
                end
                rx_read_data: begin
                    if (((rx_data_ready & rx_data_valid) & rx_data_last)) begin
                        rx_state <= rx_idle;
                    end
                end
                rx_discard_data: begin
                    if (((rx_data_ready & rx_data_valid) & rx_data_last)) begin
                        rx_state <= rx_idle;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            tx_state <= 0;
        end else begin
            case (tx_state)
                tx_idle: begin
                    if (tx_next) begin
                        tx_state <= tx_send_header;
                    end
                end
                tx_send_header: begin
                    if (((tx_misc_ready & tx_misc_valid) & (tx_no_data_payload | tx_trans_done_comb))) begin
                        tx_state <= tx_idle;
                    end else if ((((tx_misc_ready & tx_misc_valid) & (~tx_no_data_payload)) & (~tx_trans_done_comb))) begin
                        tx_state <= tx_send_data;
                    end
                end
                tx_send_data: begin
                    if (tx_trans_done_comb) begin
                        tx_state <= tx_idle;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            connection_dest_addr <= 0;
            connection_dest_port <= 0;
            rcv_nxt <= 0;
            rx_init_seq_number <= 0;
            rx_init_window <= 0;
            snd_nxt <= 0;
            snd_una <= 0;
            snd_wnd <= 0;
            tx_init_seq_number <= 0;
            tx_rcv_window <= 0;
        end else begin
            if (((connection_state == listen) && ((syn_detected_buf | syn_detected) & rx_fsm_to_idle))) begin
                tx_init_seq_number <= 32'd2557874740;
                tx_rcv_window <= 16'd4096;
                if ((rx_state == rx_read_header)) begin
                    rx_init_seq_number <= rx_seq_number;
                    rx_init_window <= rx_window;
                    connection_dest_port <= rx_src_port;
                    connection_dest_addr <= rx_src_addr;
                end else begin
                    rx_init_seq_number <= rx_seq_number_buf;
                    rx_init_window <= rx_window_buf;
                    connection_dest_port <= rx_src_port_buf;
                    connection_dest_addr <= rx_src_addr_buf;
                end
            end
            if (((connection_state == syn_rcvd) && ((syn_ack_detected_buf | syn_ack_detected) & rx_fsm_to_idle))) begin
                snd_nxt <= (tx_init_seq_number + 1);
                snd_una <= (tx_init_seq_number + 1);
                snd_wnd <= rx_init_window;
                rcv_nxt <= (rx_init_seq_number + 1);
            end else if ((((connection_state == estab) | (connection_state == close_wait)) | (connection_state == last_ack))) begin
                if (((rx_misc_ready & rx_misc_valid) & rx_acceptable_packet)) begin
                    snd_una <= rx_ack_number;
                    if (fin_detected) begin
                        rcv_nxt <= ((rx_seq_number + { 16'd0, rx_payload_length }) + 1);
                    end else begin
                        rcv_nxt <= (rx_seq_number + { 16'd0, rx_payload_length });
                    end
                end
                if ((tx_misc_ready & tx_misc_valid)) begin
                    if (tx_flags[0]) begin
                        snd_nxt <= ((snd_nxt + { 16'd0, tx_total_length_data_only }) + 1);
                    end else begin
                        snd_nxt <= (snd_nxt + { 16'd0, tx_total_length_data_only });
                    end
                end
            end
        end
    end
    always_comb begin
        rx_seq_valid = (rcv_nxt == rx_seq_number);
        if ((snd_una <= snd_nxt)) begin
            rx_ack_valid = ((snd_una <= rx_ack_number) & (rx_ack_number <= snd_nxt));
        end else begin
            rx_ack_valid = ((snd_una <= rx_ack_number) | (rx_ack_number <= snd_nxt));
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            ack_update_required <= 0;
            prev_connection_state <= 0;
            prev_rcv_nxt <= 0;
        end else begin
            prev_rcv_nxt <= rcv_nxt;
            prev_connection_state <= connection_state;
            if ((connection_state == estab)) begin
                if (((~(prev_rcv_nxt == rcv_nxt)) & (~(prev_connection_state == syn_rcvd)))) begin
                    ack_update_required <= 1'd1;
                end else if (((tx_state == tx_idle) && tx_next)) begin
                    ack_update_required <= 0;
                end
            end else begin
                ack_update_required <= 0;
            end
        end
    end
    always_comb begin
        rx_target_self = ((rx_dest_addr == config_src_addr_buf) & (rx_dest_port == config_src_port));
        rx_acceptable_packet = (((rx_target_self & rx_ack_valid) & rx_seq_valid) & rx_flags[4]);
        rx_fsm_to_idle = ((((rx_state == rx_read_header) && ((rx_misc_ready & rx_misc_valid) & rx_no_data_payload)) | ((rx_state == rx_discard_data) && ((rx_data_ready & rx_data_valid) & rx_data_last))) | ((rx_state == rx_read_data) && ((rx_data_ready & rx_data_valid) & rx_data_last)));
        tx_fsm_to_idle = (((tx_state == tx_send_header) && ((tx_misc_ready & tx_misc_valid) & (tx_no_data_payload | tx_trans_done_comb))) | ((tx_state == tx_send_data) && tx_trans_done_comb));
        if ((connection_state == listen)) begin
            if ((((rx_state == rx_read_header) & rx_misc_ready) & rx_misc_valid)) begin
                syn_detected = (rx_target_self & (rx_flags == 2));
            end else begin
                syn_detected = 0;
            end
        end else begin
            syn_detected = 0;
        end
        if ((connection_state == syn_rcvd)) begin
            if ((((rx_state == rx_read_header) & rx_misc_ready) & rx_misc_valid)) begin
                syn_ack_detected = (((rx_target_self & (rx_flags == 16)) & (rx_ack_number == (tx_init_seq_number + 1))) & (rx_seq_number == (rx_init_seq_number + 1)));
            end else begin
                syn_ack_detected = 0;
            end
        end else begin
            syn_ack_detected = 0;
        end
        if ((connection_state == estab)) begin
            if ((((rx_state == rx_read_header) & rx_misc_ready) & rx_misc_valid)) begin
                fin_detected = (rx_acceptable_packet & rx_flags[0]);
            end else begin
                fin_detected = 0;
            end
        end else begin
            fin_detected = 0;
        end
        if ((connection_state == last_ack)) begin
            if ((((rx_state == rx_read_header) & rx_misc_ready) & rx_misc_valid)) begin
                fin_ack_detected = (rx_acceptable_packet & (rx_ack_number == snd_nxt));
            end else begin
                fin_ack_detected = 0;
            end
        end else begin
            fin_ack_detected = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            fin_detected_buf <= 0;
            syn_ack_detected_buf <= 0;
            syn_detected_buf <= 0;
        end else begin
            if ((connection_state == listen)) begin
                syn_detected_buf <= (syn_detected | syn_detected_buf);
                if ((((rx_state == rx_read_header) & rx_misc_ready) & rx_misc_valid)) begin
                    
                end else begin
                    
                end
            end else begin
                syn_detected_buf <= 0;
            end
            if ((connection_state == syn_rcvd)) begin
                syn_ack_detected_buf <= (syn_ack_detected_buf | syn_ack_detected);
                if ((((rx_state == rx_read_header) & rx_misc_ready) & rx_misc_valid)) begin
                    
                end else begin
                    
                end
            end else begin
                syn_ack_detected_buf <= 0;
            end
            if ((connection_state == estab)) begin
                fin_detected_buf <= (fin_detected_buf | fin_detected);
                if ((((rx_state == rx_read_header) & rx_misc_ready) & rx_misc_valid)) begin
                    
                end else begin
                    
                end
            end else begin
                fin_detected_buf <= 0;
            end
            if ((connection_state == last_ack)) begin
                if ((((rx_state == rx_read_header) & rx_misc_ready) & rx_misc_valid)) begin
                    
                end else begin
                    
                end
            end else begin
                
            end
        end
    end
    always_comb begin
        rx_next = 1'd1;
        if ((connection_state == estab)) begin
            rx_discard = (~rx_acceptable_packet);
        end else begin
            rx_discard = 1;
        end
    end
    always_comb begin
        if ((rx_state == rx_read_header)) begin
            rx_misc_ready = 1;
        end else begin
            rx_misc_ready = 0;
        end
        if ((rx_state == rx_read_data)) begin
            dfp_rx_data_valid = rx_data_valid;
            rx_data_ready = dfp_rx_data_ready;
            dfp_rx_data = rx_data;
            if (((rx_read_data_counter + 1) == rx_payload_dword_count)) begin
                dfp_rx_data_strb = rx_payload_last_strb;
            end else begin
                dfp_rx_data_strb = 0;
            end
        end else if ((rx_state == rx_discard_data)) begin
            dfp_rx_data_valid = 0;
            rx_data_ready = 1;
            dfp_rx_data = 0;
            dfp_rx_data_strb = 0;
        end else begin
            dfp_rx_data_valid = 0;
            rx_data_ready = 0;
            dfp_rx_data = 0;
            dfp_rx_data_strb = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            rx_read_data_counter <= 0;
        end else begin
            if ((rx_state == rx_read_data)) begin
                if ((rx_data_valid & rx_data_ready)) begin
                    rx_read_data_counter <= (rx_read_data_counter + 1);
                end
            end else begin
                rx_read_data_counter <= 0;
            end
        end
    end
    always_comb begin
        rx_payload_last_strb = rx_payload_length_buf[1:0];
        rx_payload_not_aligned = (|(rx_payload_last_strb));
        rx_payload_dword_count = ((rx_payload_length_buf >> 2) + { 15'd0, rx_payload_not_aligned });
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            rx_ack_number_buf <= 0;
            rx_checksum_buf <= 0;
            rx_dest_addr_buf <= 0;
            rx_dest_port_buf <= 0;
            rx_flags_buf <= 0;
            rx_no_data_payload_buf <= 0;
            rx_payload_length_buf <= 0;
            rx_seq_number_buf <= 0;
            rx_src_addr_buf <= 0;
            rx_src_port_buf <= 0;
            rx_urg_pointer_buf <= 0;
            rx_window_buf <= 0;
        end else begin
            if ((rx_state == rx_read_header)) begin
                rx_src_addr_buf <= rx_src_addr;
                rx_dest_addr_buf <= rx_dest_addr;
                rx_no_data_payload_buf <= rx_no_data_payload;
                rx_src_port_buf <= rx_src_port;
                rx_dest_port_buf <= rx_dest_port;
                rx_seq_number_buf <= rx_seq_number;
                rx_ack_number_buf <= rx_ack_number;
                rx_flags_buf <= rx_flags;
                rx_window_buf <= rx_window;
                rx_checksum_buf <= rx_checksum;
                rx_urg_pointer_buf <= rx_urg_pointer;
                rx_payload_length_buf <= rx_payload_length;
            end
        end
    end
    always_comb begin
        if ((connection_state == syn_rcvd)) begin
            tx_next = (~tx_dispatched_syn_rcvd);
        end else if ((connection_state == estab)) begin
            tx_next = (ack_update_required | ufp_tx_data_valid);
        end else if ((connection_state == close_wait)) begin
            if ((close_wait_sub_state == close_wait_send_ack)) begin
                tx_next = 1;
            end else if ((close_wait_sub_state == close_wait_send_fin)) begin
                tx_next = 1;
            end else begin
                tx_next = 0;
            end
        end else begin
            tx_next = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            tx_dispatched_syn_rcvd <= 0;
        end else begin
            if ((connection_state == syn_rcvd)) begin
                if (((tx_state == tx_idle) && tx_next)) begin
                    tx_dispatched_syn_rcvd <= 1;
                end
            end else begin
                tx_dispatched_syn_rcvd <= 0;
            end
        end
    end
    always_comb begin
        tx_src_addr = config_src_addr_buf;
        tx_src_port = config_src_port_buf;
        tx_dest_addr = connection_dest_addr;
        tx_dest_port = connection_dest_port;
        if ((connection_state == syn_rcvd)) begin
            tx_seq_number = tx_init_seq_number;
            tx_ack_number = (rx_init_seq_number + 1);
            tx_flags = 6'd18;
            tx_window = tx_rcv_window;
            tx_urg_pointer = 0;
            tx_checksum_data_only = 0;
            tx_total_length_data_only = 0;
        end else if ((connection_state == estab)) begin
            tx_seq_number = snd_nxt;
            tx_ack_number = rcv_nxt;
            tx_flags = 16;
            tx_window = tx_rcv_window;
            tx_urg_pointer = 0;
            if (((tx_state == tx_send_header) & ufp_tx_data_valid_buf)) begin
                tx_checksum_data_only = ufp_tx_checksum_data_only_buf;
                tx_total_length_data_only = ufp_tx_total_length_data_only_buf;
            end else begin
                tx_checksum_data_only = 0;
                tx_total_length_data_only = 0;
            end
        end else if ((connection_state == close_wait)) begin
            if ((close_wait_sub_state == close_wait_send_ack)) begin
                tx_seq_number = snd_nxt;
                tx_ack_number = rcv_nxt;
                tx_flags = 16;
                tx_window = tx_rcv_window;
                tx_urg_pointer = 0;
                tx_checksum_data_only = 0;
                tx_total_length_data_only = 0;
            end else if ((close_wait_sub_state == close_wait_send_fin)) begin
                tx_seq_number = snd_nxt;
                tx_ack_number = rcv_nxt;
                tx_flags = 17;
                tx_window = tx_rcv_window;
                tx_urg_pointer = 0;
                tx_checksum_data_only = 0;
                tx_total_length_data_only = 0;
            end
        end else begin
            tx_seq_number = 0;
            tx_ack_number = 0;
            tx_flags = 0;
            tx_window = 0;
            tx_urg_pointer = 0;
            tx_checksum_data_only = 0;
            tx_total_length_data_only = 0;
        end
    end
    always_comb begin
        if ((tx_state == tx_send_header)) begin
            tx_misc_valid = 1;
        end else begin
            tx_misc_valid = 0;
        end
        if ((connection_state == syn_rcvd)) begin
            tx_no_data_payload = 1;
        end else if (((connection_state == estab) | (connection_state == close_wait))) begin
            if (((tx_state == tx_send_header) | (tx_state == tx_send_data))) begin
                if (ufp_tx_data_valid_buf) begin
                    tx_no_data_payload = 0;
                end else begin
                    tx_no_data_payload = 1;
                end
            end else begin
                tx_no_data_payload = 1;
            end
        end else begin
            tx_no_data_payload = 1;
        end
        if (((tx_state == tx_send_header) | (tx_state == tx_send_data))) begin
            tx_trans_done_comb = (tx_trans_done | ((tx_data_last & tx_data_valid) & tx_data_ready));
        end else begin
            tx_trans_done_comb = 0;
        end
    end
    always_comb begin
        if ((tx_state == tx_idle)) begin
            
        end
        if (((tx_state == tx_send_header) | (tx_state == tx_send_data))) begin
            if (((~tx_no_data_payload) & (~tx_trans_done))) begin
                tx_data_valid = ufp_tx_data_valid;
                tx_data_last = ufp_tx_data_last;
                ufp_tx_data_ready = tx_data_ready;
                tx_data = ufp_tx_data;
            end else begin
                tx_data_valid = 0;
                tx_data_last = 0;
                ufp_tx_data_ready = 0;
                tx_data = 0;
            end
            if (((tx_data_last & tx_data_valid) & tx_data_ready)) begin
                
            end
        end else begin
            tx_data_valid = 0;
            tx_data_last = 0;
            ufp_tx_data_ready = 0;
            tx_data = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            tx_trans_done <= 0;
            ufp_tx_checksum_data_only_buf <= 0;
            ufp_tx_data_valid_buf <= 0;
            ufp_tx_total_length_data_only_buf <= 0;
        end else begin
            if ((tx_state == tx_idle)) begin
                ufp_tx_data_valid_buf <= ufp_tx_data_valid;
                ufp_tx_checksum_data_only_buf <= ufp_tx_checksum_data_only;
                ufp_tx_total_length_data_only_buf <= ufp_tx_total_length_data_only;
            end
            if (((tx_state == tx_send_header) | (tx_state == tx_send_data))) begin
                if (((~tx_no_data_payload) & (~tx_trans_done))) begin
                    
                end else begin
                    
                end
                if (((tx_data_last & tx_data_valid) & tx_data_ready)) begin
                    tx_trans_done <= 1;
                end
            end else begin
                tx_trans_done <= 0;
            end
        end
    end
    always_comb begin
        transcond_rx_to_read_data = ((rx_state == rx_read_header) && (((rx_misc_ready & rx_misc_valid) & (~rx_no_data_payload)) & (~rx_discard)));
        debug_data_srv = { 1'd0, connection_state, rx_state, tx_state, snd_una, rcv_nxt };
        debug_valid_srv = (~(debug_data_srv == prev_debug_data_srv));
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            prev_debug_data_srv <= 0;
        end else begin
            prev_debug_data_srv <= debug_data_srv;
        end
    end
endmodule
module TcpPacketSendBlock_simTcpSrvSys_snsys_1 (
    input commandValid,
    output logic commandReady,
    input [47:0] destMacAddr,
    output logic [71:0] debug_data,
    input ufp_data_valid,
    input [31:0] src_addr,
    input [31:0] dest_addr,
    input [31:0] ufp_data,
    input [15:0] window,
    input [31:0] ack_number,
    input [15:0] urg_pointer,
    input [15:0] src_port,
    output logic debug_valid,
    input [5:0] flags,
    input [31:0] seq_number,
    input [15:0] total_length_data_only,
    input ufp_data_last,
    input [15:0] checksum_data_only,
    input [15:0] dest_port,
    output logic ufp_misc_ready,
    output logic ufp_data_ready,
    input ufp_misc_valid,
    output logic dfp_awvalid,
    output logic [31:0] dfp_wdata,
    output logic [7:0] dfp_awlen,
    output logic dfp_wlast,
    output logic dfp_wvalid,
    input dfp_awready,
    input dfp_wready,
    input CLK,
    input RST
);
    logic wready_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic ufp_addr_ready_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [5:0] flags_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [15:0] etherType_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] destAddr_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic ufp_last_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
    logic commandValid_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic wready_out_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic dfp_awready_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
    logic RST_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
    logic wvalid_in_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic wvalid_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic dfp_misc_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic ufp_misc_ready_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic wlast_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic wvalid_in_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic dfp_addr_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic CLK_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
    logic [15:0] dest_port_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] wdata_in_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] ack_number_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic wready_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic RST_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic dfp_data_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic dfp_wlast_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
    logic ufp_ready_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] sourceAddr_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [47:0] destMacAddr_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [15:0] totalLengthData_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic ufp_addr_valid_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic ufp_data_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic wlast_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] wdata_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] seq_number_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic wready_out_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] wdata_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [7:0] protocol_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic CLK_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] dfp_data_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic dfp_wready_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
    logic [71:0] debug_data_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic dfp_wvalid_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
    logic dfp_misc_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] ufp_data_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic ufp_data_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic RST_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [15:0] checksum_data_only_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [15:0] dfp_total_length_data_only_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic ufp_misc_valid_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] dfp_dest_addr_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [15:0] urg_pointer_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic ufp_misc_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic wvalid_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic RST_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] src_addr_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic ufp_data_last_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [15:0] window_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [7:0] dfp_awlen_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
    logic commandReady_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] ufp_data_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
    logic dfp_data_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic CLK_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic dfp_addr_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic CLK_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic debug_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [7:0] protocol_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic dfp_awvalid_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
    logic ufp_valid_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
    logic ufp_misc_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] dest_addr_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic wlast_in_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] dfp_src_addr_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] dfp_wdata_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
    logic [15:0] src_port_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic wlast_in_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic dfp_data_last_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [31:0] wdata_in_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [15:0] total_length_data_only_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
    logic [15:0] etherType_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;

    etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1 etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1_inst (
        .CLK(CLK_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1),
        .RST(RST_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1),
        .ufp_valid(ufp_valid_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1),
        .ufp_data(ufp_data_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1),
        .ufp_last(ufp_last_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1),
        .ufp_ready(ufp_ready_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1),
        .dfp_wready(dfp_wready_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1),
        .dfp_wvalid(dfp_wvalid_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1),
        .dfp_wdata(dfp_wdata_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1),
        .dfp_wlast(dfp_wlast_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1),
        .dfp_awlen(dfp_awlen_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1),
        .dfp_awvalid(dfp_awvalid_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1),
        .dfp_awready(dfp_awready_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1)
    );
    tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1_inst (
        .CLK(CLK_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .RST(RST_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .ufp_misc_valid(ufp_misc_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .ufp_misc_ready(ufp_misc_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .src_addr(src_addr_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .dest_addr(dest_addr_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .src_port(src_port_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .dest_port(dest_port_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .seq_number(seq_number_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .ack_number(ack_number_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .flags(flags_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .window(window_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .urg_pointer(urg_pointer_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .checksum_data_only(checksum_data_only_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .total_length_data_only(total_length_data_only_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .ufp_data_valid(ufp_data_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .ufp_data_last(ufp_data_last_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .ufp_data_ready(ufp_data_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .ufp_data(ufp_data_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .dfp_misc_valid(dfp_misc_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .dfp_misc_ready(dfp_misc_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .protocol(protocol_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .dfp_total_length_data_only(dfp_total_length_data_only_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .dfp_addr_valid(dfp_addr_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .dfp_addr_ready(dfp_addr_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .dfp_src_addr(dfp_src_addr_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .dfp_dest_addr(dfp_dest_addr_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .dfp_data_valid(dfp_data_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .dfp_data_last(dfp_data_last_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .dfp_data(dfp_data_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .dfp_data_ready(dfp_data_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .debug_valid(debug_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1),
        .debug_data(debug_data_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1)
    );
    IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1_inst (
        .CLK(CLK_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .RST(RST_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wvalid(wvalid_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wdata(wdata_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wlast(wlast_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wready(wready_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wdata_in(wdata_in_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wvalid_in(wvalid_in_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wlast_in(wlast_in_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wready_out(wready_out_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .ufp_addr_valid(ufp_addr_valid_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .ufp_misc_valid(ufp_misc_valid_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .ufp_addr_ready(ufp_addr_ready_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .ufp_misc_ready(ufp_misc_ready_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .totalLengthData(totalLengthData_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .sourceAddr(sourceAddr_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .destAddr(destAddr_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .protocol(protocol_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1),
        .etherType(etherType_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1)
    );
    etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1 etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1_inst (
        .CLK(CLK_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1),
        .RST(RST_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1),
        .destMacAddr(destMacAddr_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1),
        .etherType(etherType_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1),
        .commandValid(commandValid_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1),
        .commandReady(commandReady_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wdata(wdata_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wvalid(wvalid_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wlast(wlast_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wready(wready_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wvalid_in(wvalid_in_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wdata_in(wdata_in_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wlast_in(wlast_in_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1),
        .wready_out(wready_out_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1)
    );
    always_comb begin
        wready_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1 = ufp_ready_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
        wdata_in_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1 = wdata_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
        wvalid_in_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1 = wvalid_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
        wlast_in_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1 = wlast_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
        etherType_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1 = etherType_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
        wdata_in_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 = dfp_data_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
        wvalid_in_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 = dfp_data_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
        wlast_in_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 = dfp_data_last_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
        ufp_misc_valid_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 = dfp_misc_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
        protocol_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 = protocol_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
        totalLengthData_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 = dfp_total_length_data_only_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
        ufp_addr_valid_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 = dfp_addr_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
        sourceAddr_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 = dfp_src_addr_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
        destAddr_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 = dfp_dest_addr_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
        dfp_data_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = wready_out_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
        dfp_misc_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = ufp_misc_ready_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
        dfp_addr_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = ufp_addr_ready_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1;
        ufp_valid_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1 = wvalid_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
        ufp_data_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1 = wdata_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
        ufp_last_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1 = wlast_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
        wready_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 = wready_out_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
    end
    always_comb begin
        commandValid_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1 = commandValid;
        commandReady = commandReady_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1;
        destMacAddr_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1 = destMacAddr;
        debug_data = debug_data_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
        ufp_data_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = ufp_data_valid;
        src_addr_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = src_addr;
        dest_addr_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = dest_addr;
        ufp_data_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = ufp_data;
        window_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = window;
        ack_number_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = ack_number;
        urg_pointer_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = urg_pointer;
        src_port_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = src_port;
        debug_valid = debug_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
        flags_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = flags;
        seq_number_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = seq_number;
        total_length_data_only_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = total_length_data_only;
        ufp_data_last_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = ufp_data_last;
        checksum_data_only_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = checksum_data_only;
        dest_port_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = dest_port;
        ufp_misc_ready = ufp_misc_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
        ufp_data_ready = ufp_data_ready_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1;
        ufp_misc_valid_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = ufp_misc_valid;
        dfp_awvalid = dfp_awvalid_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
        dfp_wdata = dfp_wdata_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
        dfp_awlen = dfp_awlen_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
        dfp_wlast = dfp_wlast_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
        dfp_wvalid = dfp_wvalid_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1;
        dfp_awready_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1 = dfp_awready;
        dfp_wready_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1 = dfp_wready;
    end
    always_comb begin
        CLK_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1 = CLK;
        RST_etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1 = RST;
    end
    always_comb begin
        CLK_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = CLK;
        RST_tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 = RST;
    end
    always_comb begin
        CLK_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 = CLK;
        RST_IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 = RST;
    end
    always_comb begin
        CLK_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1 = CLK;
        RST_etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1 = RST;
    end
endmodule
module TcpRecvParser_simTcpSrvSys_snsys_1 (
    input CLK,
    input RST,
    input ufp_valid,
    input ufp_last,
    output logic ufp_ready,
    input [31:0] ufp_data,
    input [31:0] ufp_src_addr,
    input [31:0] ufp_dest_addr,
    input [15:0] ufp_total_length_data,
    output logic dfp_valid,
    output logic dfp_last,
    output logic [31:0] dfp_data,
    input dfp_ready,
    output logic [31:0] src_addr,
    output logic [31:0] dest_addr,
    output logic dfp_no_data_payload,
    output logic [15:0] src_port,
    output logic [15:0] dest_port,
    output logic [31:0] seq_number,
    output logic [31:0] ack_number,
    output logic [5:0] flags,
    output logic [15:0] window,
    output logic [15:0] checksum,
    output logic [15:0] urg_pointer,
    output logic [15:0] payload_length,
    input info_ready,
    output logic info_valid,
    output logic debug_valid_rcvparse,
    output logic [71:0] debug_data_rcvparse
);
    localparam read_header_core = 0;
    localparam read_option = 1;
    localparam read_data = 2;
    localparam explicitWaitDfpInfo = 3;

    reg [1:0] state;
    logic data_detected;
    logic [15:0] total_length_data_buf;
    logic [71:0] prev_debug_data_rcvparse;
    logic option_detected;
    logic option_read_done;
    logic header_read_done;
    logic [3:0] data_offset;
    logic info_done;
    logic [3:0] header_read_dword_count;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                read_header_core: begin
                    if ((header_read_done & option_detected)) begin
                        state <= read_option;
                    end else if (((header_read_done & (~option_detected)) & data_detected)) begin
                        state <= read_data;
                    end else if (((header_read_done & (~option_detected)) & (~data_detected))) begin
                        state <= explicitWaitDfpInfo;
                    end
                end
                read_option: begin
                    if ((option_read_done & (~dfp_no_data_payload))) begin
                        state <= read_data;
                    end else if ((option_read_done & dfp_no_data_payload)) begin
                        state <= explicitWaitDfpInfo;
                    end
                end
                read_data: begin
                    if ((((dfp_valid & dfp_ready) & dfp_last) & (info_done | (info_ready & info_valid)))) begin
                        state <= read_header_core;
                    end else if ((((dfp_valid & dfp_ready) & dfp_last) & (~(info_done | (info_ready & info_valid))))) begin
                        state <= explicitWaitDfpInfo;
                    end
                end
                explicitWaitDfpInfo: begin
                    if (info_done) begin
                        state <= read_header_core;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        if ((state == read_header_core)) begin
            header_read_done = ((ufp_valid & ufp_ready) & (header_read_dword_count == 4));
            option_detected = (4'd5 < data_offset);
            data_detected = (({ 12'd0, data_offset } << 2) < total_length_data_buf);
        end else begin
            header_read_done = 0;
            option_detected = 0;
            data_detected = 0;
        end
        if ((state == read_option)) begin
            option_read_done = ((ufp_valid & ufp_ready) & ((header_read_dword_count + 1) == data_offset));
        end else begin
            option_read_done = 0;
        end
    end
    always_comb begin
        if ((state == read_header_core)) begin
            ufp_ready = 1;
        end else if ((state == read_option)) begin
            ufp_ready = 1;
        end else if ((state == read_data)) begin
            ufp_ready = dfp_ready;
        end else begin
            ufp_ready = 0;
        end
        if ((state == read_data)) begin
            dfp_valid = ufp_valid;
            dfp_last = ufp_last;
            dfp_data = ufp_data;
        end else begin
            dfp_valid = 0;
            dfp_last = 0;
            dfp_data = 0;
        end
    end
    always_comb begin
        if ((state == read_header_core)) begin
            info_valid = 0;
        end else if ((((state == read_option) | (state == read_data)) | (state == explicitWaitDfpInfo))) begin
            info_valid = (~info_done);
            if ((info_valid & info_ready)) begin
                
            end
        end else begin
            info_valid = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            info_done <= 0;
        end else begin
            if ((state == read_header_core)) begin
                info_done <= 1'd0;
            end else if ((((state == read_option) | (state == read_data)) | (state == explicitWaitDfpInfo))) begin
                if ((info_valid & info_ready)) begin
                    info_done <= 1;
                end
            end else begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            ack_number <= 0;
            checksum <= 0;
            data_offset <= 0;
            dest_addr <= 0;
            dest_port <= 0;
            dfp_no_data_payload <= 0;
            flags <= 0;
            seq_number <= 0;
            src_addr <= 0;
            src_port <= 0;
            total_length_data_buf <= 0;
            urg_pointer <= 0;
            window <= 0;
        end else begin
            if ((state == read_header_core)) begin
                if ((ufp_valid & ufp_ready)) begin
                    src_addr <= ufp_src_addr;
                    dest_addr <= ufp_dest_addr;
                    total_length_data_buf <= ufp_total_length_data;
                    if ((header_read_dword_count == 0)) begin
                        src_port <= { ufp_data[7:0], ufp_data[15:8] };
                        dest_port <= { ufp_data[23:16], ufp_data[31:24] };
                    end else if ((header_read_dword_count == 1)) begin
                        seq_number <= { ufp_data[7:0], ufp_data[15:8], ufp_data[23:16], ufp_data[31:24] };
                    end else if ((header_read_dword_count == 2)) begin
                        ack_number <= { ufp_data[7:0], ufp_data[15:8], ufp_data[23:16], ufp_data[31:24] };
                    end else if ((header_read_dword_count == 3)) begin
                        data_offset <= { ufp_data[7:4] };
                        flags <= { ufp_data[13:8] };
                        window <= { ufp_data[23:16], ufp_data[31:24] };
                    end else if ((header_read_dword_count == 4)) begin
                        checksum <= { ufp_data[7:0], ufp_data[15:8] };
                        urg_pointer <= { ufp_data[23:16], ufp_data[31:24] };
                        dfp_no_data_payload <= (~data_detected);
                    end
                end
            end else if ((state == read_option)) begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            header_read_dword_count <= 0;
        end else begin
            if (((state == read_header_core) || (state == read_option))) begin
                if ((ufp_valid & ufp_ready)) begin
                    header_read_dword_count <= (header_read_dword_count + 4'd1);
                end
            end else begin
                header_read_dword_count <= 0;
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            payload_length <= 0;
        end else begin
            if ((state == read_header_core)) begin
                payload_length <= ((total_length_data_buf + 16'd1) + (~({ 12'd0, data_offset } << 2)));
            end
        end
    end
    always_comb begin
        debug_data_rcvparse = { 60'd0, 2'd0, state, { 1'd0, dfp_last, dfp_valid, dfp_ready }, { 1'd0, ufp_last, ufp_valid, ufp_ready } };
        debug_valid_rcvparse = (~(prev_debug_data_rcvparse == debug_data_rcvparse));
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            prev_debug_data_rcvparse <= 0;
        end else begin
            prev_debug_data_rcvparse <= debug_data_rcvparse;
        end
    end
endmodule
module etherFrameTxBuffers_tcptx_simTcpSrvSys_snsys_1 (
    input CLK,
    input RST,
    input ufp_valid,
    input [31:0] ufp_data,
    input ufp_last,
    output logic ufp_ready,
    input dfp_wready,
    output logic dfp_wvalid,
    output logic [31:0] dfp_wdata,
    output logic dfp_wlast,
    output logic [7:0] dfp_awlen,
    output logic dfp_awvalid,
    input dfp_awready
);
    logic [7:0] prev_wptr;
    logic full;
    logic enread;
    logic [31:0] din;
    logic [7:0] addrout;
    logic [7:0] awlen_buf;
    logic awdone;
    logic enwrite;
    logic [7:0] addrin;
    logic [7:0] wptr;
    logic [31:0] dout_ramSdpRfInst_;
    logic [7:0] rptr;

    ram_sdp_rf #(
        .addrlen(8),
        .datawid(32)
    ) _instramSdpRfInst_ (
        .clk(CLK),
        .enread(enread),
        .enwrite(enwrite),
        .addrin(addrin),
        .addrout(addrout),
        .din(din),
        .dout(dout_ramSdpRfInst_)
    );
    always_comb begin
        addrin = wptr;
        addrout = rptr;
        din = ufp_data;
        enread = 1'd1;
        enwrite = 0;
        ufp_ready = (~full);
        dfp_wlast = (full & (wptr == (rptr + 1)));
        dfp_wvalid = (~(prev_wptr == rptr));
        dfp_wdata = dout_ramSdpRfInst_;
        dfp_awvalid = (full & (~awdone));
        dfp_awlen = awlen_buf;
        if (((full & (wptr == rptr)) & awdone)) begin
            
        end else begin
            if ((~full)) begin
                if (ufp_valid) begin
                    enwrite = 1'd1;
                    if (ufp_last) begin
                        
                    end
                end
            end
            if ((dfp_wvalid & dfp_wready)) begin
                addrout = (rptr + 8'd1);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            awdone <= 0;
            awlen_buf <= 0;
            full <= 0;
            prev_wptr <= 0;
            rptr <= 0;
            wptr <= 0;
        end else begin
            if (((full & (wptr == rptr)) & awdone)) begin
                wptr <= 0;
                rptr <= 0;
                awlen_buf <= 0;
                full <= 0;
                prev_wptr <= 0;
                awdone <= 0;
            end else begin
                prev_wptr <= wptr;
                awdone <= (awdone | (dfp_awvalid & dfp_awready));
                if ((~full)) begin
                    if (ufp_valid) begin
                        wptr <= (wptr + 8'd1);
                        if (ufp_last) begin
                            awlen_buf <= wptr;
                            full <= 1;
                        end
                    end
                end
                if ((dfp_wvalid & dfp_wready)) begin
                    rptr <= (rptr + 8'd1);
                end
            end
        end
    end
endmodule
module tcpPacketGenerator_tcptx_simTcpSrvSys_snsys_1 (
    input CLK,
    input RST,
    input ufp_misc_valid,
    output logic ufp_misc_ready,
    input [31:0] src_addr,
    input [31:0] dest_addr,
    input [15:0] src_port,
    input [15:0] dest_port,
    input [31:0] seq_number,
    input [31:0] ack_number,
    input [5:0] flags,
    input [15:0] window,
    input [15:0] urg_pointer,
    input [15:0] checksum_data_only,
    input [15:0] total_length_data_only,
    input ufp_data_valid,
    input ufp_data_last,
    output logic ufp_data_ready,
    input [31:0] ufp_data,
    output logic dfp_misc_valid,
    input dfp_misc_ready,
    output logic [7:0] protocol,
    output logic [15:0] dfp_total_length_data_only,
    output logic dfp_addr_valid,
    input dfp_addr_ready,
    output logic [31:0] dfp_src_addr,
    output logic [31:0] dfp_dest_addr,
    output logic dfp_data_valid,
    output logic dfp_data_last,
    output logic [31:0] dfp_data,
    input dfp_data_ready,
    output logic debug_valid,
    output logic [71:0] debug_data
);
    localparam init = 0;
    localparam send_header = 1;
    localparam send_data = 2;

    reg [1:0] state;
    logic dfp_misc_done;
    logic header_trans_done_comb;
    logic [31:0] dest_addr_buf;
    logic [15:0] pseudoheader3sum;
    logic [16:0] pseudoheader3sum_raw;
    logic [16:0] header1_4sumraw;
    logic [16:0] header2sum_raw;
    logic [15:0] src_port_buf;
    logic [15:0] total_length_data_only_buf;
    logic [15:0] header1_2sum;
    logic [16:0] pseudoheader2sum_raw;
    logic [16:0] pseudoheader1sum_raw;
    logic [15:0] headerallsum;
    logic [16:0] header5_pseudo3sumraw;
    logic [15:0] header5_pseudo1sum;
    logic [15:0] header2sum;
    logic [16:0] header5datasum_raw;
    logic [31:0] src_addr_buf;
    logic [16:0] header3_4sumraw;
    logic [15:0] dest_port_buf;
    logic [16:0] header5_pseudo1sumraw;
    logic [15:0] urg_pointer_buf;
    logic [16:0] headerallsum_raw;
    logic [5:0] flags_buf;
    logic [15:0] header1sum;
    logic [15:0] header5_pseudo3sum;
    logic [15:0] checksum_data_only_buf;
    logic [16:0] header1sum_raw;
    logic dfp_addr_done;
    logic [4:0] header_counter;
    logic [31:0] seq_number_buf;
    logic misc_trans_done_comb;
    logic [15:0] pseudoheader1sum;
    logic [16:0] header1_2sumraw;
    logic addr_trans_done_comb;
    logic [15:0] header4sum;
    logic [15:0] header5datasum;
    logic [15:0] pseudoheader2_3sum;
    logic [16:0] header4sum_raw;
    logic [15:0] pseudoheader2sum;
    logic [15:0] header3sum;
    logic [15:0] window_buf;
    logic [16:0] pseudoheader2_3sumraw;
    logic [15:0] header3_4sum;
    logic [16:0] header3sum_raw;
    logic [15:0] header1_4sum;
    logic [3:0] header_dword_length;
    logic [31:0] ack_number_buf;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                init: begin
                    if ((ufp_misc_ready & ufp_misc_valid)) begin
                        state <= send_header;
                    end
                end
                send_header: begin
                    if ((((misc_trans_done_comb & header_trans_done_comb) & addr_trans_done_comb) & (total_length_data_only_buf == 0))) begin
                        state <= init;
                    end else if ((((misc_trans_done_comb & header_trans_done_comb) & addr_trans_done_comb) & (~(total_length_data_only_buf == 0)))) begin
                        state <= send_data;
                    end
                end
                send_data: begin
                    if (((dfp_data_last & dfp_data_valid) & dfp_data_ready)) begin
                        state <= init;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        if (((state == init) && (ufp_misc_ready & ufp_misc_valid))) begin
            debug_valid = 1;
            debug_data = 1;
        end else if (((state == send_header) && (((misc_trans_done_comb & header_trans_done_comb) & addr_trans_done_comb) & (~(total_length_data_only_buf == 0))))) begin
            debug_data = 2;
            debug_valid = 1;
        end else if (((state == send_data) && ((dfp_data_last & dfp_data_valid) & dfp_data_ready))) begin
            debug_data = 3;
            debug_valid = 1;
        end else begin
            debug_data = 0;
            debug_valid = 0;
        end
    end
    always_comb begin
        misc_trans_done_comb = (dfp_misc_done | (dfp_misc_ready & dfp_misc_valid));
        addr_trans_done_comb = (dfp_addr_done | (dfp_addr_ready & dfp_addr_valid));
        header_trans_done_comb = ((((header_counter == 4) & dfp_data_valid) & dfp_data_ready) | (header_counter == 5));
    end
    always_comb begin
        header_dword_length = 4'd5;
        if ((state == init)) begin
            ufp_misc_ready = 1;
        end else begin
            ufp_misc_ready = 0;
        end
        if ((state == send_data)) begin
            ufp_data_ready = dfp_data_ready;
        end else begin
            ufp_data_ready = 0;
        end
        if ((state == send_header)) begin
            dfp_misc_valid = (~dfp_misc_done);
            dfp_addr_valid = (~dfp_addr_done);
        end else begin
            dfp_misc_valid = 0;
            dfp_addr_valid = 0;
        end
        if ((state == send_header)) begin
            dfp_data_valid = (~(header_counter == { 1'd0, header_dword_length }));
            dfp_data_last = ((total_length_data_only_buf == 0) & (header_counter == 4));
            if ((header_counter == 0)) begin
                dfp_data = { dest_port_buf[7:0], dest_port_buf[15:8], src_port_buf[7:0], src_port_buf[15:8] };
            end else if ((header_counter == 1)) begin
                dfp_data = { seq_number_buf[7:0], seq_number_buf[15:8], seq_number_buf[23:16], seq_number_buf[31:24] };
            end else if ((header_counter == 2)) begin
                dfp_data = { ack_number_buf[7:0], ack_number_buf[15:8], ack_number_buf[23:16], ack_number_buf[31:24] };
            end else if ((header_counter == 3)) begin
                dfp_data = { window_buf[7:0], window_buf[15:8], 2'd0, flags_buf, 4'd5, 4'd0 };
            end else if ((header_counter == 4)) begin
                dfp_data = { urg_pointer_buf[7:0], urg_pointer_buf[15:8], (~headerallsum[7:0]), (~headerallsum[15:8]) };
            end
        end else if ((state == send_data)) begin
            dfp_data = ufp_data;
            dfp_data_last = ufp_data_last;
            dfp_data_valid = ufp_data_valid;
        end else begin
            dfp_data = 0;
            dfp_data_last = 0;
            dfp_data_valid = 0;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            header_counter <= 0;
        end else begin
            if ((state == send_header)) begin
                if ((dfp_data_valid & dfp_data_ready)) begin
                    header_counter <= (header_counter + 5'd1);
                end
            end else begin
                header_counter <= 0;
            end
        end
    end
    always_comb begin
        dfp_total_length_data_only = (total_length_data_only_buf + ({ 12'd0, header_dword_length } << 2));
        protocol = 6;
        dfp_src_addr = src_addr_buf;
        dfp_dest_addr = dest_addr_buf;
        if ((state == send_header)) begin
            if ((dfp_misc_ready & dfp_misc_valid)) begin
                
            end
            if ((dfp_addr_ready & dfp_addr_valid)) begin
                
            end
        end else begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            dfp_addr_done <= 0;
            dfp_misc_done <= 0;
        end else begin
            if ((state == send_header)) begin
                if ((dfp_misc_ready & dfp_misc_valid)) begin
                    dfp_misc_done <= 1;
                end
                if ((dfp_addr_ready & dfp_addr_valid)) begin
                    dfp_addr_done <= 1;
                end
            end else begin
                dfp_misc_done <= 0;
                dfp_addr_done <= 0;
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            ack_number_buf <= 0;
            checksum_data_only_buf <= 0;
            dest_addr_buf <= 0;
            dest_port_buf <= 0;
            flags_buf <= 0;
            seq_number_buf <= 0;
            src_addr_buf <= 0;
            src_port_buf <= 0;
            total_length_data_only_buf <= 0;
            urg_pointer_buf <= 0;
            window_buf <= 0;
        end else begin
            if ((state == init)) begin
                src_addr_buf <= src_addr;
                dest_addr_buf <= dest_addr;
                src_port_buf <= src_port;
                dest_port_buf <= dest_port;
                seq_number_buf <= seq_number;
                ack_number_buf <= ack_number;
                flags_buf <= flags;
                window_buf <= window;
                urg_pointer_buf <= urg_pointer;
                total_length_data_only_buf <= total_length_data_only;
                checksum_data_only_buf <= checksum_data_only;
            end
        end
    end
    always_comb begin
        header1sum_raw = (({ 1'd0, src_port_buf } + { 1'd0, dest_port_buf }) | 17'd0);
        header2sum_raw = (({ 1'd0, seq_number_buf[31:16] } + { 1'd0, seq_number_buf[15:0] }) | 17'd0);
        header3sum_raw = (({ 1'd0, ack_number_buf[31:16] } + { 1'd0, ack_number_buf[15:0] }) | 17'd0);
        header4sum_raw = (({ 1'd0, window_buf } + { 1'd0, 4'd5, 4'd0, 2'd0, flags_buf }) | 17'd0);
        header5datasum_raw = (({ 1'd0, urg_pointer_buf } + { 1'd0, checksum_data_only_buf }) | 17'd0);
        pseudoheader1sum_raw = (({ 1'd0, src_addr_buf[31:16] } + { 1'd0, src_addr_buf[15:0] }) | 17'd0);
        pseudoheader2sum_raw = (({ 1'd0, dest_addr_buf[31:16] } + { 1'd0, dest_addr_buf[15:0] }) | 17'd0);
        pseudoheader3sum_raw = (({ 1'd0, 8'd0, 8'd6 } + { 1'd0, dfp_total_length_data_only }) | 17'd0);
        header1_2sumraw = (({ 1'd0, header1sum } + { 1'd0, header2sum }) | 17'd0);
        header3_4sumraw = (({ 1'd0, header3sum } + { 1'd0, header4sum }) | 17'd0);
        header5_pseudo1sumraw = (({ 1'd0, header5datasum } + { 1'd0, pseudoheader1sum }) | 17'd0);
        pseudoheader2_3sumraw = (({ 1'd0, pseudoheader2sum } + { 1'd0, pseudoheader3sum }) | 17'd0);
        header1_4sumraw = (({ 1'd0, header1_2sum } + { 1'd0, header3_4sum }) | 17'd0);
        header5_pseudo3sumraw = (({ 1'd0, header5_pseudo1sum } + { 1'd0, pseudoheader2_3sum }) | 17'd0);
        headerallsum_raw = (({ 1'd0, header1_4sum } + { 1'd0, header5_pseudo3sum }) | 17'd0);
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            header1_2sum <= 0;
            header1_4sum <= 0;
            header1sum <= 0;
            header2sum <= 0;
            header3_4sum <= 0;
            header3sum <= 0;
            header4sum <= 0;
            header5_pseudo1sum <= 0;
            header5_pseudo3sum <= 0;
            header5datasum <= 0;
            headerallsum <= 0;
            pseudoheader1sum <= 0;
            pseudoheader2_3sum <= 0;
            pseudoheader2sum <= 0;
            pseudoheader3sum <= 0;
        end else begin
            header1sum <= (header1sum_raw[15:0] + { 15'd0, header1sum_raw[16] });
            header2sum <= (header2sum_raw[15:0] + { 15'd0, header2sum_raw[16] });
            header3sum <= (header3sum_raw[15:0] + { 15'd0, header3sum_raw[16] });
            header4sum <= (header4sum_raw[15:0] + { 15'd0, header4sum_raw[16] });
            header5datasum <= (header5datasum_raw[15:0] + { 15'd0, header5datasum_raw[16] });
            pseudoheader1sum <= (pseudoheader1sum_raw[15:0] + { 15'd0, pseudoheader1sum_raw[16] });
            pseudoheader2sum <= (pseudoheader2sum_raw[15:0] + { 15'd0, pseudoheader2sum_raw[16] });
            pseudoheader3sum <= (pseudoheader3sum_raw[15:0] + { 15'd0, pseudoheader3sum_raw[16] });
            header1_2sum <= (header1_2sumraw[15:0] + { 15'd0, header1_2sumraw[16] });
            header3_4sum <= (header3_4sumraw[15:0] + { 15'd0, header3_4sumraw[16] });
            header5_pseudo1sum <= (header5_pseudo1sumraw[15:0] + { 15'd0, header5_pseudo1sumraw[16] });
            pseudoheader2_3sum <= (pseudoheader2_3sumraw[15:0] + { 15'd0, pseudoheader2_3sumraw[16] });
            header1_4sum <= (header1_4sumraw[15:0] + { 15'd0, header1_4sumraw[16] });
            header5_pseudo3sum <= (header5_pseudo3sumraw[15:0] + { 15'd0, header5_pseudo3sumraw[16] });
            headerallsum <= (headerallsum_raw[15:0] + { 15'd0, headerallsum_raw[16] });
        end
    end
endmodule
module IpPacketSimpleGenerator_tcptx_simTcpSrvSys_snsys_1 (
    input CLK,
    input RST,
    output logic wvalid,
    output logic [31:0] wdata,
    output logic wlast,
    input wready,
    input [31:0] wdata_in,
    input wvalid_in,
    input wlast_in,
    output logic wready_out,
    input ufp_addr_valid,
    input ufp_misc_valid,
    output logic ufp_addr_ready,
    output logic ufp_misc_ready,
    input [15:0] totalLengthData,
    input [31:0] sourceAddr,
    input [31:0] destAddr,
    input [7:0] protocol,
    output logic [15:0] etherType
);
    localparam idle = 0;
    localparam header = 1;
    localparam payload = 2;

    reg [1:0] state;
    logic [7:0] protocolBuf;
    logic [3:0] headerCounter;
    logic [15:0] identification;
    logic [19:0] sumh1;
    logic [15:0] checksum;
    logic [19:0] sum_first;
    logic [19:0] sumh2;
    logic [7:0] ttl;
    logic [19:0] sumh1_2;
    logic [19:0] sumh4;
    logic [19:0] sumh5;
    logic ufp_addr_done;
    logic [15:0] totalLengthIp;
    logic [31:0] sourceAddrBuf;
    logic ufp_misc_done;
    logic [15:0] sum_third;
    logic [15:0] totalLengthDataBuf;
    logic [19:0] sumh4_5;
    logic [31:0] destAddrBuf;
    logic [16:0] sum_second;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                idle: begin
                    if ((((ufp_addr_ready & ufp_addr_valid) | ufp_addr_done) & ((ufp_misc_valid & ufp_misc_ready) | ufp_misc_done))) begin
                        state <= header;
                    end
                end
                header: begin
                    if ((((headerCounter == 4) & wvalid) & wready)) begin
                        state <= payload;
                    end
                end
                payload: begin
                    if (((wvalid & wready) & wlast)) begin
                        state <= idle;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        if ((state == header)) begin
            wvalid = 1;
            wready_out = 0;
            wlast = 0;
            if ((headerCounter == 0)) begin
                wdata = { totalLengthIp[7:0], totalLengthIp[15:8], 16'd69 };
            end else if ((headerCounter == 1)) begin
                wdata = { 16'd0, identification[7:0], identification[15:8] };
            end else if ((headerCounter == 2)) begin
                wdata = { checksum[7:0], checksum[15:8], protocolBuf, ttl };
            end else if ((headerCounter == 3)) begin
                wdata = { sourceAddrBuf[7:0], sourceAddrBuf[15:8], sourceAddrBuf[23:16], sourceAddrBuf[31:24] };
            end else begin
                wdata = { destAddrBuf[7:0], destAddrBuf[15:8], destAddrBuf[23:16], destAddrBuf[31:24] };
            end
        end else if ((state == payload)) begin
            wvalid = wvalid_in;
            wdata = wdata_in;
            wlast = wlast_in;
            wready_out = wready;
        end else begin
            wvalid = 0;
            wdata = 0;
            wlast = 0;
            wready_out = 0;
        end
    end
    always_comb begin
        etherType = 2048;
        totalLengthIp = (totalLengthDataBuf + 20);
        ttl = 8'd128;
        sumh1 = ({ 4'd0, 16'd17664 } + { 4'd0, totalLengthIp });
        sumh2 = ({ 4'd0, identification } + { 4'd0, ttl, protocolBuf });
        sumh4 = ({ 4'd0, sourceAddrBuf[31:16] } + { 4'd0, sourceAddrBuf[15:0] });
        sumh5 = ({ 4'd0, destAddrBuf[31:16] } + { 4'd0, destAddrBuf[15:0] });
        sum_first = ((sumh1_2 + sumh4_5) | 20'd0);
        sum_second = (({ 1'd0, sum_first[15:0] } + { 13'd0, sum_first[19:16] }) | 17'd0);
        checksum = 0;
        if ((state == header)) begin
            if ((headerCounter == 0)) begin
                
            end else if ((headerCounter == 1)) begin
                
            end else if ((headerCounter == 2)) begin
                checksum = (~sum_third);
            end
        end
        if ((state == idle)) begin
            ufp_addr_ready = (~ufp_addr_done);
            ufp_misc_ready = (~ufp_misc_done);
            if ((ufp_addr_ready & ufp_addr_valid)) begin
                
            end
            if ((ufp_misc_ready & ufp_misc_valid)) begin
                
            end
        end else begin
            ufp_addr_ready = 0;
            ufp_misc_ready = 0;
        end
        if ((state == header)) begin
            if ((wvalid & wready)) begin
                
            end
        end else begin
            
        end
        if (((state == payload) && ((wvalid & wready) & wlast))) begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            destAddrBuf <= 0;
            headerCounter <= 0;
            identification <= 0;
            protocolBuf <= 0;
            sourceAddrBuf <= 0;
            sum_third <= 0;
            sumh1_2 <= 0;
            sumh4_5 <= 0;
            totalLengthDataBuf <= 0;
            ufp_addr_done <= 0;
            ufp_misc_done <= 0;
        end else begin
            if ((state == header)) begin
                if ((headerCounter == 0)) begin
                    sumh1_2 <= (sumh1 + sumh2);
                    sumh4_5 <= (sumh4 + sumh5);
                end else if ((headerCounter == 1)) begin
                    sum_third <= (sum_second[15:0] + { 15'd0, sum_second[16] });
                end else if ((headerCounter == 2)) begin
                    
                end
            end
            if ((state == idle)) begin
                if ((ufp_addr_ready & ufp_addr_valid)) begin
                    sourceAddrBuf <= sourceAddr;
                    destAddrBuf <= destAddr;
                    ufp_addr_done <= 1'd1;
                end
                if ((ufp_misc_ready & ufp_misc_valid)) begin
                    ufp_misc_done <= 1'd1;
                    protocolBuf <= protocol;
                    totalLengthDataBuf <= totalLengthData;
                end
            end else begin
                ufp_addr_done <= 0;
                ufp_misc_done <= 0;
            end
            if ((state == header)) begin
                if ((wvalid & wready)) begin
                    headerCounter <= (headerCounter + 4'd1);
                end
            end else begin
                headerCounter <= 0;
            end
            if (((state == payload) && ((wvalid & wready) & wlast))) begin
                identification <= (identification + 16'd1);
            end
        end
    end
endmodule
module etherFrameGenerator_tcptx_simTcpSrvSys_snsys_1 (
    input CLK,
    input RST,
    input [47:0] destMacAddr,
    input [15:0] etherType,
    input commandValid,
    output logic commandReady,
    output logic [31:0] wdata,
    output logic wvalid,
    output logic wlast,
    input wready,
    input wvalid_in,
    input [31:0] wdata_in,
    input wlast_in,
    output logic wready_out
);
    localparam idle = 0;
    localparam header = 1;
    localparam payload = 2;
    localparam lastpayload = 3;

    reg [1:0] state;
    logic [2:0] headerCounter;
    logic [47:0] destMacAddrBuf;
    logic [47:0] sourceMacAddr;
    logic [15:0] wdataHalfWordBuf;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            state <= 0;
        end else begin
            case (state)
                idle: begin
                    if ((commandValid & commandReady)) begin
                        state <= header;
                    end
                end
                header: begin
                    if ((((headerCounter == 2) & wvalid) & wready)) begin
                        state <= payload;
                    end
                end
                payload: begin
                    if (((wlast_in & wvalid) & wready)) begin
                        state <= lastpayload;
                    end
                end
                lastpayload: begin
                    if ((wvalid & wready)) begin
                        state <= idle;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
    always_comb begin
        commandReady = 0;
        { wdata, wvalid, wlast } = 0;
        wready_out = 0;
        if ((state == idle)) begin
            commandReady = 1;
        end else if ((state == header)) begin
            wvalid = 1;
            if ((headerCounter == 0)) begin
                wdata = { destMacAddrBuf[23:16], destMacAddrBuf[31:24], destMacAddrBuf[39:32], destMacAddrBuf[47:40] };
            end else if ((headerCounter == 1)) begin
                wdata = { sourceMacAddr[39:32], sourceMacAddr[47:40], destMacAddrBuf[7:0], destMacAddrBuf[15:8] };
            end else if ((headerCounter == 2)) begin
                wdata = { sourceMacAddr[7:0], sourceMacAddr[15:8], sourceMacAddr[23:16], sourceMacAddr[31:24] };
            end
        end else if ((state == payload)) begin
            wvalid = wvalid_in;
            wready_out = wready;
            wdata = { wdata_in[15:0], wdataHalfWordBuf };
        end else if ((state == lastpayload)) begin
            wlast = 1;
            wdata = { 16'd0, wdataHalfWordBuf };
            wvalid = 1;
        end
    end
    always_comb begin
        sourceMacAddr = 48'd1577122510;
        if ((state == idle)) begin
            
        end
        if ((state == header)) begin
            if ((wvalid & wready)) begin
                
            end
        end else begin
            
        end
        if ((state == idle)) begin
            
        end else if ((state == payload)) begin
            if ((wvalid & wready)) begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            destMacAddrBuf <= 0;
            headerCounter <= 0;
            wdataHalfWordBuf <= 0;
        end else begin
            if ((state == idle)) begin
                destMacAddrBuf <= destMacAddr;
            end
            if ((state == header)) begin
                if ((wvalid & wready)) begin
                    headerCounter <= (headerCounter + 3'd1);
                end
            end else begin
                headerCounter <= 0;
            end
            if ((state == idle)) begin
                wdataHalfWordBuf <= { etherType[7:0], etherType[15:8] };
            end else if ((state == payload)) begin
                if ((wvalid & wready)) begin
                    wdataHalfWordBuf <= wdata_in[31:16];
                end
            end
        end
    end
endmodule
