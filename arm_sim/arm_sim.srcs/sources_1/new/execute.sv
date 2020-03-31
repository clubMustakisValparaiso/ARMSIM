`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2020 10:35:04 AM
// Design Name: 
// Module Name: execute
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


module execute(
    input logic aluSrcE,
    input logic[1:0]aluCtrlE, forwardAE, forwardBE,
    input logic[31:0] srcAE_prima, writeDataE_prima,extImmE, aluOutM, resultW,
    output logic[3:0]aluFlags,
    output logic[31:0]aluResultE, writeDataE
    );
    
    //--------------------------- Cables--------------------------------
  
    logic[31:0] srcAE,srcBE, writeDataE_;
    assign writeDataE = writeDataE_;
   //-------------------------------------------------------------------
    
    mux3 srcA(srcAE_prima,resultW,aluOutM, forwardAE,srcAE);
    mux3 srcB(writeDataE_prima,resultW,aluOutM, forwardBE, writeDataE_);
    

    
    mux2 aluSrcMux(writeDataE_,extImmE, aluSrcE, srcBE);
    alu myAlu( srcAE,srcBE,
                aluCtrlE,
                aluResultE,
                aluFlags    
                );  
endmodule
