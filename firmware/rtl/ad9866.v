//
//  Hermes Lite
// 
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

// (C) Steve Haynal KF7O 2014, 2015, 2016


module ad9866 #
(
    parameter WB_DATA_WIDTH = 32,
    parameter WB_ADDR_WIDTH = 6
)
(
    input  logic        clk,
    input  logic        rst,
    output logic        sclk,
    output logic        sdio,
    input  logic        sdo,
    output logic        sen_n,
    output logic [7:0]  dataout,

    input  logic        rx_pwr_off,
    input  logic        rx_pwr_on,

    // Wishbone slave interface
    input  logic [WB_ADDR_WIDTH-1:0]   wbs_adr_i,
    input  logic [WB_DATA_WIDTH-1:0]   wbs_dat_i,
    input  logic                       wbs_we_i,
    input  logic                       wbs_stb_i,
    output logic                       wbs_ack_o,   
    input  logic                       wbs_cyc_i

);



reg [15:0] datain;
reg start;
reg [3:0] dut2_bitcount;
reg [1:0] dut2_state;
reg [15:0] dut2_data;
reg [5:0] dut1_pc;

logic [8:0] initarrayv;
reg [8:0] initarray [19:0];


// Wishbone slave
logic [2:0]       wbs_state = 3'b0;
logic [2:0]       next_wbs_state;
logic [3:0]       tx_gain = 4'h0;
logic [3:0]       next_tx_gain;
logic [6:0]       rx_gain = 7'b1000000;
logic [6:0]       next_rx_gain;

logic             cmd_ack; 
logic [12:0]      cmd_data;

logic             set_rx_pwr;

initial begin
    // First bit is 1'b1 for write enable to that address
    initarray[0] = {1'b0,8'h80}; // Address 0x00, enable 4 wire SPI
    initarray[1] = {1'b0,8'h00}; // Address 0x01,
    initarray[2] = {1'b0,8'h00}; // Address 0x02,
    initarray[3] = {1'b0,8'h00}; // Address 0x03,
    initarray[4] = {1'b0,8'h00}; // Address 0x04,
    initarray[5] = {1'b0,8'h00}; // Address 0x05,
    initarray[6] = {1'b1,8'h54}; // Address 0x06, Disable clkout2
    initarray[7] = {1'b1,8'h20}; // Address 0x07, Initiate DC offset calibration and RX filter on, 21 to 20 to disable RX filter
    initarray[8] = {1'b0,8'h4b}; // Address 0x08, RX filter f-3db at ~34 MHz after scaling
    initarray[9] = {1'b0,8'h00}; // Address 0x09,
    initarray[10] = {1'b0,8'h00}; // Address 0x0a,
    initarray[11] = {1'b1,8'h00}; // Address 0x0b, No RX gain on PGA
    initarray[12] = {1'b1,8'h43}; // Address 0x0c, TX twos complement and interpolation factor
    initarray[13] = {1'b1,8'h03}; // Address 0x0d, RX twos complement
    initarray[14] = {1'b1,8'h81}; // Address 0x0e, Enable/Disable IAMP
    initarray[15] = {1'b0,8'h00}; // Address 0x0f,
    initarray[16] = {1'b1,8'h80}; // Address 0x10, Select TX gain
    initarray[17] = {1'b1,8'h00}; // Address 0x11, Select TX gain
    initarray[18] = {1'b1,8'h00}; // Address 0x12,
    initarray[19] = {1'b0,8'h00}; // Address 0x13,
end


localparam 
  WBS_IDLE    = 3'b000,
  WBS_TXGAIN  = 3'b001,
  WBS_RXGAIN  = 3'b011,
  WBS_WRITE   = 3'b010,
  SET_RXPWR_OFF = 3'b100,
  SET_RXPWR_ON  = 3'b101;

always @(posedge clk) begin
  if (rst) begin
    wbs_state <= WBS_IDLE;
    tx_gain <= 4'h0;
    rx_gain <= 7'b1000000;
  end else begin
    wbs_state <= next_wbs_state;
    tx_gain <= next_tx_gain;
    rx_gain <= next_rx_gain;
  end
end


always @* begin
  next_wbs_state = wbs_state;
  next_tx_gain = tx_gain;
  next_rx_gain = rx_gain;
  cmd_ack = 1'b0;
  cmd_data  = {wbs_dat_i[20:16],wbs_dat_i[7:0]};
  set_rx_pwr = 1'b0;

  case(wbs_state)

    WBS_IDLE: begin
      if (wbs_we_i & wbs_stb_i & sen_n) begin
        // Accept possible write
        case (wbs_adr_i)

          // Hermes TX Gain Setting
          6'h09: begin
            next_tx_gain = wbs_dat_i[31:28];
            if (tx_gain != wbs_dat_i[31:28]) next_wbs_state = WBS_TXGAIN;
          end

          // Hermes RX Gain Setting
          6'h0a: begin
            next_rx_gain = wbs_dat_i[6:0];
            if (rx_gain != wbs_dat_i[6:0]) next_wbs_state = WBS_RXGAIN;
          end

          // Generic AD9866 write
          6'h3b: begin
            if (wbs_dat_i[31:24] == 8'h06) next_wbs_state = WBS_WRITE;
          end

          default: next_wbs_state = wbs_state;

        endcase 
      end else if (rx_pwr_off & sen_n) begin
        next_wbs_state = SET_RXPWR_OFF;
      end else if (rx_pwr_on & sen_n) begin
        next_wbs_state = SET_RXPWR_ON;
      end
    end

    WBS_TXGAIN: begin
      cmd_ack   = 1'b1;
      cmd_data  = {5'h0a,4'b0100,tx_gain};
      next_wbs_state = WBS_IDLE;
    end
    
    WBS_RXGAIN: begin
      cmd_ack   = 1'b1;
      cmd_data[12:6]  = {5'h09,2'b01};
      cmd_data[5:0]   = rx_gain[6] ? rx_gain[5:0] : (rx_gain[5] ? ~rx_gain[5:0] : {1'b1,rx_gain[4:0]});
      next_wbs_state = WBS_IDLE;
    end

    WBS_WRITE: begin
      cmd_ack   = 1'b1;
      cmd_data  = {wbs_dat_i[20:16],wbs_dat_i[7:0]};
      next_wbs_state = WBS_IDLE;
    end

    SET_RXPWR_OFF: begin
      set_rx_pwr   = 1'b1;
      cmd_data = {5'h01,8'h01};
      next_wbs_state = WBS_IDLE;
    end
	 
	 SET_RXPWR_ON: begin
      set_rx_pwr   = 1'b1;
      cmd_data = {5'h01,8'h00};
      next_wbs_state = WBS_IDLE;
    end

  endcase
end

assign wbs_ack_o = cmd_ack;

// SPI interface


// Init program counter
always @(posedge clk) begin: AD9866_DUT1_FSM
    if (rst) begin
        dut1_pc <= 6'h00;
    end
    else begin
        if ((dut1_pc != 6'h3f) & sen_n) begin
            dut1_pc <= (dut1_pc + 6'h01);
        end
        // Toggle LSB
        else if ((dut1_pc == 6'h3f) & sen_n) begin
            dut1_pc <= 6'h3e;
        end
    end
end

always @* begin
    initarrayv = initarray[dut1_pc[5:1]];
    datain = {3'b000,cmd_data};   
    start = 1'b0;
    if (sen_n) begin
        if (dut1_pc[5:1] <= 6'h13) begin
            if (dut1_pc[0] == 1'b0) begin
                
                datain = {3'h0,dut1_pc[5:1],initarrayv[7:0]};
                start = initarrayv[8];
            end
        end else begin
            start = cmd_ack | set_rx_pwr;
        end
    end
end

assign dataout = dut2_data[8-1:0];
assign sdio = dut2_data[15];

// SPI state machine
always @(posedge clk) begin: AD9866_DUT2_FSM
    if (rst) begin
        sen_n <= 1;
        sclk <= 0;
        dut2_state <= 2'b00;
        dut2_data <= 0;
        dut2_bitcount <= 0;
    end
    else begin
        case (dut2_state)
            2'b00: begin
                sclk <= 0;
                dut2_bitcount <= 15;
                if (start) begin
                    dut2_data <= datain;
                    sen_n <= 0;
                    dut2_state <= 2'b01;
                end
                else begin
                    sen_n <= 1;
                end
            end
            2'b01: begin
                dut2_state <= 2'b11;
                if ((!sclk)) begin
                    sclk <= 1;
                end
                else begin
                    dut2_data <= {dut2_data[15-1:0], sdo};
                    dut2_bitcount <= (dut2_bitcount - 1);
                    sclk <= 0;
                    if ((dut2_bitcount == 0)) begin
                        dut2_state <= 2'b00;
                    end
                end
            end
            2'b11: begin
                dut2_state <= 2'b01;
            end
        endcase
    end
end

endmodule
