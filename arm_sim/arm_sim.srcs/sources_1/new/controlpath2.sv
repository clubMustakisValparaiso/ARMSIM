`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2020 08:20:53 PM
// Design Name: 
// Module Name: controlpath2
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





module controlpath2(
    input logic rst,clk, flushE,
    input logic[1:0] op,
    input logic[5:0] funct,
    input logic[3:0] rd,condD,aluFlags,
    output logic aluSrcE ,memWriteM, PCSrcW,regWriteM,regWriteW,mem2RegW,mem2RegE_, aluSrcD, branchTaken,
    output logic PCSrcD,PCSrcE,PCSrcM,
    output logic[1:0] immSrcD,regSrcD, aluCtrlE, 
    output logic regWriteD,regWriteE
    );


    //------------ Cables -------------------
    logic[1:0] flagWriteD, aluCtrlD;
    
    logic mem2RegE,memWriteE,branchE;
    logic[1:0] aluCtrlE_, flagWriteE;
    logic[3:0] condE,flagsE;
    
    logic mem2RegM,memWriteM_;
    
    assign branchTaken = condExE & branchE;
    assign aluCtrlE = aluCtrlE_;
    assign memWriteM = memWriteM_;
    
    assign mem2RegE_ = mem2RegE;
    
    //-------- FlipFlops---------------------
    always_ff @(posedge clk) begin                                // ff decode-execute
        if(rst | flushE) begin
            PCSrcE      <=0;
            regWriteE   <=0;    
            mem2RegE    <=0;
            memWriteE   <=0;
            branchE     <=0;
            aluSrcE     <=0;
            flagWriteE <=2'b0;
            aluCtrlE_    <=2'b0;
            flagsE      <=4'b0;
            condE       <=4'b0;
            
        end 
        else begin
            if(flagWriteE[1]) flagsE[3:2]<=aluFlags[3:2];
            if(flagWriteE[0]) flagsE[1:0]<=aluFlags[1:0];
            
            PCSrcE      <=PCSrcD;
            regWriteE   <=regWriteD;    
            mem2RegE    <=mem2RegD;
            memWriteE   <=memWriteD;
            branchE     <=branchD;
            aluSrcE     <=aluSrcD;
            aluCtrlE_   <=aluCtrlD;
            flagWriteE  <=flagWriteD; 
            condE       <=condD;
        end
    end
    
    always_ff @(posedge clk) begin                                  // ff execute-memory
        if(rst) begin
            PCSrcM      <=0;
            regWriteM   <=0;
            mem2RegM    <=0;
            memWriteM_   <=0;
        end
        else begin  
            PCSrcM      <= condExE & PCSrcE;
            regWriteM   <= condExE & regWriteE;
            mem2RegM    <= condExE & mem2RegE;
            memWriteM_  <= condExE & memWriteE;
        end
    
    end
    
    always_ff @(posedge clk) begin                              // ff memory-writeback
        if(rst) begin
            PCSrcW      <=0;
            regWriteW   <=0;
            mem2RegW    <=0;
        end
        else begin
            PCSrcW      <= PCSrcM;
            regWriteW   <= regWriteM;
            mem2RegW    <= mem2RegM;
        end
    end
    
    //-------- Modulos -----------------------

    controlUnit myCtrlUnit(op,funct,rd,
                            flagWriteD,
                            PCSrcD,regWriteD,memWriteD, branchD,
                            mem2RegD,aluSrcD,
                            immSrcD,regSrcD,aluCtrlD
                            );
    condCheck myCheck(
                condE,
                flagsE,
                condExE
                );

endmodule

//-----------------------------------------------------------------
//------------------------- CONDITIONS CHECK ----------------------
//-----------------------------------------------------------------

module condCheck(
                input logic [3:0]cond,
                input logic [3:0]flags,
                output logic condEx
                );
    logic neg,zero,carry,overflow,ge;
    assign {neg,zero,carry,overFlow} = flags;
    assign ge = (neg==overFlow);
    
    always_comb begin
        case(cond)
            4'b0000:    condEx = zero; 
            4'b0001:    condEx = ~zero;
            4'b0010:    condEx = carry;
            4'b0011:    condEx = ~carry;
            4'b0100:    condEx = neg;
            4'b0101:    condEx = ~neg;
            4'b0110:    condEx = overFlow;
            4'b0111:    condEx = ~overFlow;
            4'b1000:    condEx = carry & ~zero;
            4'b1001:    condEx = ~(carry & ~zero);
            4'b1010:    condEx = ge;
            4'b1011:    condEx = ~ge;   
            4'b1100:    condEx = ~zero & ge;
            4'b1101:    condEx = ~(~zero & ge);
            4'b1110:    condEx = 1'b1;                  
            default:    condEx = 1'bx;
        endcase
    
    end

endmodule



/*
module controlpath2(
    input logic clk,rst,
    input logic[31:12] instr,
    input logic[3:0] aluFlags,
    output logic [1:0] regSrc,
    output logic regWrite,
    output logic [1:0] immSrc,
    output logic aluSrc,
    output logic [1:0] aluCtrl,
    output logic memWrite, mem2Reg,
    output logic PCSrc,
    output logic[3:0] flags,
    output logic [1:0] flagWrite, flagW_
    );
    
    
    logic[1:0] flagW;
    logic regW,memW,PCS;
    assign flagW_ = flagW;
    
    decoder dec(
            instr[27:26],instr[25:20],instr[15:12],
            flagW,PCS,regW,memW,
            mem2Reg,aluSrc,immSrc,regSrc,aluCtrl
            );
    condLogic cond(
            clk,rst,
            instr[31:28],
            aluFlags,
            flagW, PCS, regW, memW,
            PCSrc,regWrite, memWrite,
            flags, flagWrite     
            );
    
endmodule

//-----------------------------------------------------------------
//-------------------------------- DECODER ------------------------
//-----------------------------------------------------------------

module decoder(
    input logic[1:0] op,
    input logic[5:0] funct,
    input logic[3:0] rd,
    output logic[1:0] flagW,
    output logic PCS,regW,memW,
    output logic mem2Reg,aluSrc,
    output logic[1:0] immSrc,regSrc,aluCtrl
    );
    
    logic [9:0] controls;
    logic branch,aluOp;
    
    //-------------------------------------------------Main decoder
    
    always_comb begin
        casex(op)
            2'b00:      if(funct[5])    controls=10'b0000101001;
                        else            controls=10'b0000001001;
            2'b01:      if(funct[0])    controls=10'b0001111000;
                        else            controls=10'b1001110100;
            2'b10:                      controls=10'b0110100010;
            default:                    controls=10'bxxxxxxxxxx;
        endcase
    
        assign {regSrc,immSrc,aluSrc,mem2Reg,regW,memW,branch,aluOp} = controls;
    end
    //------------------------------------------------- ALU decoder    
    always_comb begin
        if(aluOp) begin
            case(funct[4:1])
                4'b0100:    aluCtrl = 2'b00;
                4'b0010:    aluCtrl = 2'b01;
                4'b0000:    aluCtrl = 2'b10;
                4'b1100:    aluCtrl = 2'b11;
                default:    aluCtrl = 2'bxx;
            endcase
        flagW[1] = funct[0];
        flagW[0] = funct[0] & (aluCtrl == 2'b00 | aluCtrl == 2'b01);
        end
        else begin
            aluCtrl = 2'b00;
            flagW= 2'b00;
        end
    end
    //------------------------------------------------- PC logic
    assign PCS=((rd == 4'b1111) & regW) | branch;

endmodule


//-----------------------------------------------------------------
//---------------------------- CONDICIONAL LOGIC ------------------
//-----------------------------------------------------------------


module condLogic(
    input logic clk,rst,
    input logic [3:0] cond, aluFlags,
    input logic [1:0] flagW,
    input logic PCS,regW,memW,
    output logic PCSrc,regWrite,memWrite,
    output logic[3:0] flags,
    output logic[1:0] flagWrite
    );
    
   // logic [1:0 ]flagWrite;
    //logic [3:0] flags;
    logic condEx;
    
    flopenr #(2) flagReg1(clk,rst,flagWrite[1],
                            aluFlags[3:2],flags[3:2]);
    flopenr #(2) flagReg0(clk,rst,flagWrite[0],
                            aluFlags[1:0],flags[1:0]);                         

    condCheck cc(cond,flags, condEx);
    
    assign flagWrite = flagW & {2{condEx}};
    assign regWrite = regW & condEx;
    assign memWrite = memW & condEx;
    assign PCSrc = PCS & condEx;

endmodule


//-----------------------------------------------------------------
//------------------------- CONDITIONS CHECK ----------------------
//-----------------------------------------------------------------

module condCheck(
                input logic [3:0]cond,
                input logic [3:0]flags,
                output logic condEx
                );
    logic neg,zero,carry,overflow,ge;
    assign {neg,zero,carry,overFlow} = flags;
    assign ge = (neg==overFlow);
    
    always_comb begin
        case(cond)
            4'b0000:    condEx = zero; 
            4'b0001:    condEx = ~zero;
            4'b0010:    condEx = carry;
            4'b0011:    condEx = ~carry;
            4'b0100:    condEx = neg;
            4'b0101:    condEx = ~neg;
            4'b0110:    condEx = overFlow;
            4'b0111:    condEx = ~overFlow;
            4'b1000:    condEx = carry & ~zero;
            4'b1001:    condEx = ~(carry & ~zero);
            4'b1010:    condEx = ge;
            4'b1011:    condEx = ~ge;   
            4'b1100:    condEx = ~zero & ge;
            4'b1101:    condEx = ~(~zero & ge);
            4'b1110:    condEx = 1'b1;                  
            default:    condEx = 1'bx;
        endcase
    
    end

endmodule

*/