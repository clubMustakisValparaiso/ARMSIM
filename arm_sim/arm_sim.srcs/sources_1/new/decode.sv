`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2020 12:37:30 AM
// Design Name: 
// Module Name: decode
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


module decode(
                input logic clk,rst,
                input logic regWriteW, forwardAD, forwardBD,
                input logic[1:0] regSrcD,immSrcD,
                input logic[3:0] wa3W,
                input logic[31:0] PCPlus8D, resultW, instrD,
                output logic[3:0] wa3D, RA1D,RA2D,
                output logic [31:0] rd1,rd2,extImmD,
                output logic [31:0]watcher[14:0]
                );
    //------------------------- Cables--------------------------
    logic [3:0] addr_reg1D, addr_reg2D;
    logic [31:0] PCPlus8_, rd1_, rd2_;
    
    assign PCPlus8_ = PCPlus8D;
    assign wa3D = instrD[15:12];
    assign RA1D = addr_reg1D;
    assign RA2D = addr_reg2D;
    //----------------------------------------------------------
    
    mux2#(4) ra1Mux(instrD[19:16], 4'b1111, regSrcD[0],addr_reg1D);
    mux2#(4) ra2Mux(instrD[3:0], instrD[15:12], regSrcD[1], addr_reg2D);
    
    mux2 muxRd1(rd1_, resultW, forwardAD, rd1);
    mux2 muxRd2(rd2_, resultW, forwardBD, rd2);
                
    regFile myReg( clk, rst,
                    regWriteW,
                    addr_reg1D,addr_reg2D,wa3W,
                    resultW,PCPlus8_,
                    rd1_, rd2_,
                    watcher
                    );                                             
                    
    extend DUText(instrD[23:0],immSrcD,extImmD);
endmodule
