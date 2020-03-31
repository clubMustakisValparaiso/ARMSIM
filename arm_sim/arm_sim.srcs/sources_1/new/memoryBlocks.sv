`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2020 01:24:43 PM
// Design Name: 
// Module Name: memoryBlocks
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

module dmem(
    input logic clk,we,
    input logic [31:0] addr,wd,
    output logic [31:0] rd
    );
    
    logic [31:0]RAM[13:0];
    assign rd = RAM[addr[31:2]];
    
    always_ff @(posedge clk) begin
        if(we) RAM[addr[31:2]] <= wd; 
    end
    
    initial
        $readmemh("memory.mem",RAM);
  
endmodule


module imem(
    input logic [31:0] addr,
    output logic [31:0] rd
    );
    logic [31:0]ROM[100:0];
    
    initial
        $readmemh("ROM.mem",ROM);
     assign rd = ROM[addr[31:2]];
    
endmodule




