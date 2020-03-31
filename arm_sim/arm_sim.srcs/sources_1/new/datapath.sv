`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2020 04:13:23 PM
// Design Name: 
// Module Name: datapath
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

module datapath(
                    input logic clk, rst,stallD,stallF,flushE,flushD, branchTaken,
                    input logic PCSrcW, regWriteW,aluSrcE, mem2RegW, forwardAD, forwardBD,
                    input logic[1:0] regSrcD,immSrcD,aluCtrlE,forwardAE,forwardBE,
                    input logic[31:0]instrF,
                    input logic[31:0]readDataM,
                    output logic [31:0] PCF, writeDataM,aluOutM,
                    output logic [31:0]watcher[14:0],
                    output logic[31:0] instrD_,
                    output logic[3:0] aluFlags, 
                    output logic[6:0]hazardMatches
                    );
    //------------------------------------------------------------------------
    //-----------------------------Cables ------------------------------------
    //------------------------------------------------------------------------
    
    logic flushE_, flushD_;                                                                
    logic[3:0]wa3D,wa3W,wa3E,wa3M, aluFlags_, RA1D, RA2D, RA1E,RA2E;
    logic [31:0]resultW, readDataW,aluOutW;                                   
    logic [31:0] rd1,rd2,extImmD, instrD;
    logic[31:0] aluResultE, writeDataE, writeDataE_prima, srcAE,extImmE; 
    logic[31:0] writeDataM_, aluOutM_;
    logic [31:0]PCPlus4F;
    
    assign flushE_ = rst | flushE;
    assign flushD_ = rst | flushD;
    assign instrD_ = instrD;
    assign aluFlags = aluFlags_;
    
    //------------------------------------------------------------------------
    //-------------------- flipflops -----------------------------------------
    //------------------------------------------------------------------------ 
    
    flopenr#(32) fdInstr(clk,flushD_, ~stallD, instrF,instrD);
     
    
    flopr deRd1(flushE_,clk,rd1,srcAE);
    flopr deRd2(flushE_,clk,rd2,writeDataE_prima);
    flopr deExtimm(flushE_,clk,extImmD,extImmE);
    flopr#(4) deWa3(flushE_,clk,wa3D,wa3E);
    flopr#(4) deRA1(flushE_, clk, RA1D,RA1E);
    flopr#(4) deRA2(flushE_, clk, RA2D,RA2E);
    
    
    flopr emResult(rst,clk,aluResultE, aluOutM_);
    flopr emWriteData(rst,clk,writeDataE, writeDataM_);
    flopr#(4) emWe3(rst,clk,wa3E,wa3M);
    
    flopr mwReadData(rst,clk,readDataM,readDataW);
    flopr mwAluOut(rst,clk,aluOutM_,aluOutW);
    flopr#(4) mwWa3W(rst,clk,wa3M,wa3W);  
    //------------------------------------------------------------------------
    //-------------------- HazardUnit matches --------------------------------
    //------------------------------------------------------------------------ 
                                                                      // [12DE,1EM, 1EW, 2EM, 2EW]                
    assign hazardMatches[3] = (RA1E==wa3M);                           // forwarding
    assign hazardMatches[2] = (RA1E==wa3W);
    assign hazardMatches[1] = (RA2E==wa3M);
    assign hazardMatches[0] = (RA2E==wa3W);
    
    assign hazardMatches[4] = (RA1D == wa3E) | (RA2D == wa3E);         // stall 
    
    assign hazardMatches[6] = (RA1D==wa3W);
    assign hazardMatches[5] = (RA2D==wa3W);     
    //------------------------------------------------------------------------
    //-------------------- Stages --------------------------------------------
    //------------------------------------------------------------------------
    
    //---------------------------------------------------- Fetch
    fetch myFetch(
                 clk,rst,stallF, branchTaken,
                 PCSrcW,
                 resultW,aluResultE,
                 PCF,PCPlus4F
                 );
                 
    //---------------------------------------------------- Decode
    decode myDecode(
                    clk,rst,
                    regWriteW, forwardAD, forwardBD,
                    regSrcD,immSrcD,
                    wa3W, 
                    PCPlus4F,
                    resultW,instrD,
                    wa3D,RA1D, RA2D,
                    rd1,rd2,extImmD, watcher   
                    );
   //---------------------------------------------------- Execute
   execute myExecute(
                    aluSrcE,aluCtrlE, forwardAE, forwardBE,
                    srcAE,writeDataE_prima,extImmE, aluOutM_, resultW,                                                     
                    aluFlags_,
                    aluResultE, writeDataE
                     );
    //---------------------------------------------------- Memory
    //                                                      (como memory solo contiene cables y dmem, pero dmem esta fuera del datapath, no amerita crear un modulo para memory_stage)
    assign writeDataM = writeDataM_;
    assign aluOutM = aluOutM_;
     
    //----------------------------------------------------WriteBack (tampoco amerita modulo ya que solo tiene un mux)
    
    mux2 resultMux(aluOutW,readDataW, mem2RegW,resultW);
   
endmodule

