module Example_State
(
	X,Z,CLK_50M,RST_N
);

input		CLK_50M;
input 	RST_N;
input		X;
output	Z;

reg 		Z;
reg		Z_N;

parameter S0 = 2'b00;
parameter S1 = 2'b01;
parameter S2 = 2'b10;

reg [1:0] FSM_CS;
reg [1:0] FSM_NS;

always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
        FSM_CS <= 2'b00;
    else
        FSM_CS <= FSM_NS;
end

always @ (*)
begin
    case(FSM_CS)
    S0 :    
    begin
        if(X == 1'b1)
            FSM_NS = S1;
        else
            FSM_NS = S0;
    end
    S1 :    
    begin
        if(X == 1'b1)
            FSM_NS = S2;
        else
            FSM_NS = S1;
    end
    S2 :    
    begin
        if(X == 1'b1)
            FSM_NS = S0;
        else
            FSM_NS = S2;
    end
    endcase
end

always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
        Z <= 1'b0;
    else
        Z <= Z_N;
end

always @ (*)
begin
    if((FSM_CS == S2) && (X == 1'b1))
        Z_N = 1'b1;
    else
        Z_N = 1'b0;
end

endmodule

