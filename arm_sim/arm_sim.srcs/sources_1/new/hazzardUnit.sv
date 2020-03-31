`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2020 02:02:04 PM
// Design Name: 
// Module Name: hazzardUnit
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


module hazardUnit( input logic regWriteM, regWriteW, mem2RegE, aluSrcD, branchTaken,
                    input logic PCSrcD,PCSrcE,PCSrcM,PCSrcW,
                    input logic[6:0] hazardMatches,
                    output logic stallD,stallF,flushE,flushD, forwardAD, forwardBD,
                    output logic[1:0] forwardAE, forwardBE
    );
    
    //------------------- Cables----------------------
    logic ldrStall, PCWrPendingF;
    logic[1:0] forwardAE_, forwardBE_;
    assign forwardAE = forwardAE_;
    assign forwardBE = forwardBE_; 
    
    //------------------------------------------------
                                                                        // [12DE,1EM, 1EW, 2EM, 2EW]
    always_comb begin                                                  //  forwarding
        forwardAE_[1] = hazardMatches[3] & regWriteM;
        forwardAE_[0] = ~(hazardMatches[3] & regWriteM) & (hazardMatches[2] & regWriteW); 
        forwardBE_[1] = hazardMatches[1] & regWriteM;
        forwardBE_[0] = ~(hazardMatches[1] & regWriteM) & (hazardMatches[0] & regWriteW);     
        
        forwardAD = hazardMatches[6] & regWriteW;
        forwardBD = hazardMatches[5] & regWriteW & ~aluSrcD;
        
                                                                      // stall
        ldrStall = hazardMatches[4] & mem2RegE;
        PCWrPendingF = PCSrcD + PCSrcE + PCSrcM;
        
        stallD = ldrStall;
        stallF = ldrStall + PCWrPendingF;
        flushE = ldrStall + branchTaken;
        flushD = PCWrPendingF + PCSrcW + branchTaken;
    end
    
    
endmodule
