`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2020 12:19:49 AM
// Design Name: 
// Module Name: fetch
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



module fetch(
            input logic clk, rst,stallF,branchTaken,
            input logic PCSrcW,
            input logic[31:0] resultW,aluResultE,
            output logic [31:0]PCF,PCPlus4F 
            );
            
    //----------------- Cables ----------------------
            
    logic [31:0] PCPrima, PCplus4F_,PCF_, PCPrima2;     
    assign PCPlus4F = PCplus4F_;
    assign PCF = PCF_;
            
    //-------------- PC LOGIC ------------------------
            
    adder myAdder(PCF_,32'b100,PCplus4F_);        
    flopenr#(32) myFlopPC(clk,rst,~stallF,PCPrima2,PCF_);
    mux2 pcmux(PCplus4F_,resultW,PCSrcW,PCPrima);
    mux2 pcmux2(PCPrima,aluResultE, branchTaken,PCPrima2);
    //------------- instr memmory--------------------
    
endmodule
