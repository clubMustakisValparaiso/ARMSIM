`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2020 01:11:44 PM
// Design Name: 
// Module Name: genericBuildingBlocks
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*------------------------------------------------------------*/
/*------------------------------------------------------------*/

module flopr#(parameter WIDTH=32)(
    input logic rst,clk,
    input logic [WIDTH-1:0] d,
    output logic[WIDTH-1:0] q
);
    
    always_ff @(posedge clk) begin
        if(rst) q <= 0;
        else    q <= d;
    end

endmodule

/*------------------------------------------------------------*/
/*------------------------------------------------------------*/

module adder#(parameter WIDTH=32)(
    input logic [WIDTH-1:0] a,b,
    output logic [WIDTH-1:0] y
);
    assign y=a+b;
endmodule

/*------------------------------------------------------------*/
/*------------------------------------------------------------*/

module mux2#(parameter WIDTH=32)(
    input logic [WIDTH-1:0] d0,d1,
    input logic ctrl,
    output logic [WIDTH-1:0] y 
);
    assign y = ctrl ? d1 : d0;  
endmodule

/*------------------------------------------------------------*/
/*------------------------------------------------------------*/
module mux3#(parameter WIDTH=32)(
    input logic [WIDTH-1:0] d0,d1,d2,
    input logic[1:0] ctrl,
    output logic[WIDTH-1:0] y
);
    always_comb begin
        case(ctrl)
            2'b00:    y=d0;
            2'b01:    y=d1;
            2'b10:    y=d2;
            default:  y=32'bx;
        endcase
    end

endmodule

/*------------------------------------------------------------*/
/*------------------------------------------------------------*/

module regFile(
    input logic clk, rst, we3,
    input logic [3:0] ra1,ra2,wa3,
    input logic [31:0] wd3,r15,
    output logic [31:0] rd1,rd2,
    output logic [31:0]watcher[14:0]
);
    
    
    logic [31:0]rf[14:0];
    assign watcher = rf;
    
    always_ff @(posedge clk) begin
        if(rst) begin
            rf[0] <= 32'b0;
            rf[1] <= 32'b0;
            rf[2] <= 32'b0;
            rf[3] <= 32'b0;
            rf[4] <= 32'b0;
            rf[5] <= 32'b0;
            rf[6] <= 32'b0;
            rf[7] <= 32'b0;
            rf[8] <= 32'b0;
            rf[9] <= 32'b0;
            rf[10] <= 32'b0;
            rf[11] <= 32'b0;
            rf[12] <= 32'b0;
            rf[13] <= 32'b0;
            rf[14] <= 32'b0; 
        end
        else if(we3) rf[wa3] <= wd3;
    end
    
    always_ff @(negedge clk) begin
        rd1 <= (ra1==4'b1111) ? r15 : rf[ra1];
        rd2 <= (ra2==4'b1111) ? r15 : rf[ra2];
    end
 
endmodule

/*------------------------------------------------------------*/
/*------------------------------------------------------------*/

module alu(
    input logic [31:0]a,b,
    input logic [1:0] mode,
    output logic [31:0] y,
    output logic [3:0]flags,         //NZCV
    output logic [2:0]showing
);
    
   logic [31:0] b_invertido;       // invertir en complemento 2
   logic [31:0] sum;
   
   always_comb begin
    if(mode == 2'b1)    b_invertido = ~b + 32'b1;
    else                b_invertido = b;  
   
    sum = a+b_invertido;
   end
    
   always_comb begin   
        
      ;
       case(mode) 
        2'b00:  y = sum;  
        2'b01:  y = sum;  
        2'b10:  y = a&b;
        2'b11:  y = a|b;
        
        default: y = 31'bx;
        
       endcase
   end
   
    assign flags[3] = y[31];        //N
    assign flags[2] = (a==b);       //Z
    assign flags[1] = 0;
    assign flags[0] = ~mode[1] & (a[31]!=sum[31]) & 
                    ( (~mode[0] & (a[31]==b[31])) | (mode[0] & (a[31!=b[31]])) );      //fkng overflow         
endmodule

/*------------------------------------------------------------*/
/*------------------------------------------------------------*/

module extend(
    input logic [23:0] instr,
    input logic [1:0] immSrc,
    output logic [31:0] extImm
);

    always_comb begin
        case(immSrc)
            2'b00: begin                                     // 8bits unsigned
                    extImm[31:8] = 24'b0;
                    extImm[7:0] = instr[7:0];
                    end
            2'b01: begin                                    // 12bits unsigned
                    extImm[31:12] = 20'b0;
                    extImm[11:0] = instr[11:0];
                    end
            2'b10: begin                                   //  24bits two's complement
                    extImm = {{6{instr[23]}},instr[23:0],2'b00};
                    end
            default: extImm = 32'bx;
        endcase
    end

endmodule

/*------------------------------------------------------------*/
/*------------------------------------------------------------*/

module flopenr #(parameter WIDTH=8)(
                input logic clk,rst,en,
                input logic [WIDTH-1:0] d,
                output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk) begin
        if(rst)   q <= 0;
        else if(en) q <= d; 
    end

endmodule


