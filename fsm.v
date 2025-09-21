module fault_Det(input clk, input rstn, input [31:0]volt, input [31:0]current,output reg fault,output reg warning,output reg shutdown);
reg highV,lowV,highI; //flags to indicate an abnormal condn 
reg [2:0] count;

reg [1:0]ps,ns;
parameter NORMAL=2'd0,WARNING=2'd1,FAULT=2'd2,SHUTDOWN=2'd3;

always@(posedge clk,negedge rstn) begin
	if(!rstn)
		ps <= NORMAL;
	else
		ps <= ns;
end

always@(*) begin
case(ps)
	NORMAL: begin
		if(highV || highI || lowV) // if any abnorMal condn in the system, move to the WARNING state
			ns = WARNING ;
		else 
			ns = ps;
	end
	WARNING: begin
			if( !highI && !highV && !lowV) // only if all condns are normal, go to NORMAL state
				ns = NORMAL;
			else if((highV || highI || lowV) && (count == 3'd2)) // in the warning, we wait for 3 cycles for the abnormal condn to be checked. If the condn stil										    persists, we go to the FAULT state
				ns = FAULT;				     
			else 
				ns = ps;
	end
	FAULT: begin							    // if in the FAULT state, it will go to the SHUTDOWN state
			ns = SHUTDOWN;
	end
	SHUTDOWN: begin
			if(!rstn)					   //unless the system is reset, the system will remain SHUTDOWN
				ns = NORMAL;
			else 
				ns = ps;
	end
endcase
end



always@(posedge clk,negedge rstn) begin
	case(ps)
		NORMAL : begin
			if(!rstn) begin		     // resetting the system to normal condition
				highV = 1'd0; 
				highI = 1'd0;
				lowV = 1'd0;
				warning = 1'd0;
				fault = 1'd0;
				shutdown = 1'd0;
			end
			else if(volt > 32'h40a00000) 	// incase of voltage above 5V
				highV = 1'd1;	    	// High voltage flag is set
			else if(current > 32'h40000000) // incase of current above 2A
				highI =1'd1;		// High current flag is set
			else if(volt < 32'h3dcccccd)	// incase current goes below 0.1A
				lowV = 1'd1;		// Low current flag is set
		end
		WARNING : begin				// after entering the warning state, the V and I is checked again.
				if(volt < 32'h40a00000) // If V or I has gone back to normal levels, the flags are reset. 
					highV = 1'd0;
				else if(current < 32'h40000000)
					highI = 1'd0;
				else if(volt > 32'h3dcccccd)
					lowV = 1'd0;
				else 
					warning = 1'd1; // a warning signal is outputted
		end
		FAULT : begin				// fault is set
				fault = 1'd1;		
		end
		SHUTDOWN : begin
				shutdown = 1'd1;	// system shutsdown
				
		end			
	endcase
end

//this is a counter to wait for the condn to be corrected in the WARNING state
always@(posedge clk, negedge rstn) begin
	if(!rstn)
		count <= 3'd0;
	else if(ps == WARNING)
		count <= count + 1;
	else if(ps == FAULT)
		count <= 3'd0;
	else 
		count <= count;
end

endmodule
