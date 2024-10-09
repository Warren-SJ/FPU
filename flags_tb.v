`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chris Larsen, Copyright 2019
// 
// Create Date: 08/14/2019 01:19:36 PM
// Design Name: 
// Module Name: hp_class_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Test hp_class module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module flags_tb;
  reg [31:0] f;
  wire snan, qnan, infinity, zero, subnormal, normal;
  
  integer i, nSnans, nQnans, nInfinities, nZeroes, nSubnormals, nNormals;
  
  initial
    begin
      f = 0;
      nSnans = 0;
      nQnans = 0;
      nInfinities = 0;
      nZeroes = 0;
      nSubnormals = 0;
      nNormals = 0;
//      $monitor("f = %x, class = %b", f,
//       {snan, qnan, infinity, zero, subnormal, normal});
    end
     
  initial
    begin
    i = 0;
      for (i = 0; i < (1 << 16); i = i + 1)
        begin
        $display("num = %x",f);
          #10
           f = i;
          if ((snan & ~qnan & ~infinity & ~zero & ~subnormal & ~normal) == 1)
            nSnans = nSnans + 1;
          else if ((~snan & qnan & ~infinity & ~zero & ~subnormal & ~normal) == 1)
            nQnans = nQnans + 1;
          else if ((~snan & ~qnan & infinity & ~zero & ~subnormal & ~normal) == 1)
            nInfinities = nInfinities + 1;
          else if ((~snan & ~qnan & ~infinity & zero & ~subnormal & ~normal) == 1)
            nZeroes = nZeroes + 1;
          else if ((~snan & ~qnan & ~infinity & ~zero & subnormal & ~normal) == 1)
            nSubnormals = nSubnormals + 1;
          else if ((~snan & ~qnan & ~infinity & ~zero & ~subnormal & normal) == 1)
            nNormals = nNormals + 1;
          else
            begin
              $display("Error: f = %x, class = %b", f, {snan, qnan, infinity, zero, subnormal, normal});
              $stop;
            end
        end
     
      // Output test results   
      begin
        $display("     Number of sNaNs: %d", nSnans);
        $display("     Number of qNaNs: %d", nQnans);
        $display("Number of Infinities: %d", nInfinities);
        $display("    Number of Zeroes: %d", nZeroes);
        $display("Number of Subnormals: %d", nSubnormals);
        $display("   Number of Normals: %d", nNormals);
        $display("               Total: %d (%x)", nSnans+nQnans+nInfinities+nZeroes+nSubnormals+nNormals,
         nSnans+nQnans+nInfinities+nZeroes+nSubnormals+nNormals);
      end
      
      #10 $stop;
    end

  flags inst1(f, snan, qnan, infinity, zero, subnormal, normal);

endmodule