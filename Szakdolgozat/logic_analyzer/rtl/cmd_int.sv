module cmd_int(
	input clk_i,
	input rst_n_i,

//uart <-> cmd_int
	input data_received_i,
	input [7:0] data_i,
	
	input rx_active_i,
	input tx_active_i,
	
	output data_valid_o,
	output [7:0] data_o,
	
	output cmd_busy_o,
	
//cmd_int <-> reg_top
	output wr_o,
	output [6:0] address_o,
	
	//input read_received_i,
	input [7:0] read_data_i,
	
	//output write_valid_o,
	output [7:0] write_data_o
);

typedef enum {IDLE, WRITE, READ} cmd_state_e;

//logic [7:0] write_data_d, write_data_q;
//logic [7:0] data_d, data_q;
//logic wr_d, wr_q;

logic [6:0] address_d, address_q;
cmd_state_e cmd_state_d, cmd_state_q;

logic read;

//logic address_ready;
//assign address_ready = (cmd_state_q == IDLE) & data_received_i;

	always_comb begin
		//wr_d = wr_q;
		address_d = address_q;
		cmd_state_d = cmd_state_q;
		//write_data_d = write_data_q;
		//data_d = data_q;
		case (cmd_state_q)
			IDLE: begin
				if (data_received_i) begin
					//wr_d = data_i[7];
					address_d = data_i[6:0];
					if (data_i[7]) begin
						cmd_state_d = WRITE;
					end
					else begin
						cmd_state_d = READ;
					end
				end
			end
			WRITE: begin
				if (data_received_i) begin
					cmd_state_d = IDLE;
				end
			end
			READ: begin
				//data_o = read_data_i;
				cmd_state_d = IDLE;
			end
			default: begin
				cmd_state_d = IDLE;
			end
		endcase
	end

	always_ff @(posedge clk_i, negedge rst_n_i) begin
		if (!rst_n_i) begin
			//wr_q <= 0; //READ
			address_q <= 7'b0;
			//write_data_q <= 8'b0;
			//data_q <= 8'b0;
			cmd_state_q <= IDLE;
		end
		else begin
			/*if (address_ready) begin
				wr_q <= wr_d;
				address_q <= address_d;
			end
			write_data_q <= write_data_d;
			data_q <= data_d;*/
			address_q <= address_d;
			cmd_state_q <= cmd_state_d;
		end
	end
	
	assign cmd_busy_o   = rx_active_i || tx_active_i;	//!( (cmd_state_d != cmd_state_q) & (cmd_state_d != READ) );
	assign read         = (cmd_state_q == IDLE)  & (data_received_i) & !data_i[7];
	assign wr_o         = (cmd_state_q == WRITE) & (data_received_i);
	assign address_o    = wr_o ? address_q : read ? data_i[6:0] : '0;							 
	assign write_data_o = wr_o ? data_i : '0;	
	assign data_o       = read_data_i;
	assign data_valid_o = read;

	/*assign write_data_o = (write_valid_o) ? data_i : write_data_o; //'0;
	//assign data_o = data_q;
	assign data_o = (cmd_state_q == READ) ? read_data_i : data_o; //'0; 
	assign data_valid_o = (cmd_state_q == READ) & (cmd_state_d == IDLE); //address_ready; //data_valid_q;
	assign write_valid_o = (cmd_state_q == WRITE) & data_received_i; //write_valid_q;
	assign wr_o = wr_q; //(write_valid_o) ? wr_q : '0;
	assign address_o = address_q;*/

endmodule
