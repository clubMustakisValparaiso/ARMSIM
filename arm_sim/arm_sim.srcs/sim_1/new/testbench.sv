`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2020 12:10:27 AM
// Design Name: 
// Module Name: testbench
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


module testbench(
    );
   
    //----------------- Cables ----------------------
    logic clk,rst;
   
    logic aluSrcE, memWriteM;                                                          //control cables
    logic[1:0]regSrcD,immSrcD, aluCtrlE,forwardAE,forwardBE;
    
    logic[3:0] aluFlags;
    logic[6:0] hazardMatches;
    logic[31:0] instrD, instrF, PCF, writeDataM, readDataM, aluOutM;
    
    logic [31:0]registros[14:0];
    

    //-------------- Modulos -------------------------
    datapath myDatapath(clk,rst, stallD,stallF,flushE,flushD, branchTaken,
                          PCSrcW,regWriteW,aluSrcE,mem2RegW,forwardAD, forwardBD, 
                          regSrcD,immSrcD,aluCtrlE,forwardAE, forwardBE,
                          instrF,readDataM,
                          PCF,writeDataM,aluOutM,
                          registros,
                          instrD, aluFlags, hazardMatches
                          );
    
    //--------------------------------------------------------------------------                   
    controlpath2 myControl(rst,clk, flushE,
                          instrD[27:26],
                          instrD[25:20],
                          instrD[15:12], instrD[31:28],aluFlags,
                          aluSrcE, memWriteM, PCSrcW,regWriteM,regWriteW,mem2RegW, mem2RegE, aluSrcD,branchTaken,
                          PCSrcD,PCSrcE,PCSrcM,
                          immSrcD,regSrcD,aluCtrlE,
                          regWriteD,regWriteE
                          );
    //--------------------------------------------------------------------------                     

    hazardUnit myHazzard(regWriteM, regWriteW, mem2RegE,aluSrcD,branchTaken,
                        PCSrcD,PCSrcE,PCSrcM, PCSrcW,
                        hazardMatches,
                        stallD,stallF,flushE,flushD, forwardAD, forwardBD,
                        forwardAE,forwardBE);
     
    //--------------------------------------------------------------------------                     
    imem DUTimem(PCF,instrF); 
    //--------------------------------------------------------------------------                     
    dmem DUTdmem(   clk,memWriteM,
                    aluOutM,writeDataM,
                    readDataM
                    );
    //--------------------------------------------------------------------------                     
    
   
    
    always begin
        clk <= 1; #5;
        clk <= 0; #5;
    end
    
    
    initial begin
    rst = 1; #10; 
    rst <= 0;
    
    
    end
    
endmodule
