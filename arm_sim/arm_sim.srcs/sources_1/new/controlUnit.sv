`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2020 10:29:22 AM
// Design Name: 
// Module Name: controlUnit
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


module controlUnit(
    input logic[1:0] op,
    input logic[5:0] funct,
    input logic[3:0] rd,
    output logic[1:0] flagWriteD,
    output logic PCSrcD,regWriteD,memWriteD, branch,
    output logic mem2RegD,aluSrcD, 
    output logic[1:0] immSrcD,regSrcD,aluCtrlD
    );
    
    logic [9:0] controls;
    logic aluOp;
    
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
    
        assign {regSrcD,immSrcD,aluSrcD,mem2RegD,regWriteD,memWriteD,branch,aluOp} = controls;
    end
    //------------------------------------------------- ALU decoder    
    always_comb begin
        if(aluOp) begin
            case(funct[4:1])
                4'b0100:    aluCtrlD = 2'b00;
                4'b0010:    aluCtrlD = 2'b01;
                4'b0000:    aluCtrlD = 2'b10;
                4'b1100:    aluCtrlD = 2'b11;
                default:    aluCtrlD = 2'bxx;
            endcase
        flagWriteD[1] = funct[0];
        flagWriteD[0] = funct[0] & (aluCtrlD == 2'b00 | aluCtrlD == 2'b01);
        end
        else begin
            aluCtrlD = 2'b00;
            flagWriteD= 2'b00;
        end
    end
    //------------------------------------------------- PC logic
    assign PCSrcD=((rd == 4'b1111) & regWriteD);

endmodule
