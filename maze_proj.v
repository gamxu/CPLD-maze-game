module final(M,clk1,clk2,q,r,rst1,accept);
    input M ,clk1,clk2; // M = countup or countdown
    output [2:0] q,r; // output q = colum , r = rowa
	output rst1,accept; 
	reg rst1;
	reg reset; // ไว้ใช้ set reset ให้ทำงานหรือไม่
	reg accept; //ไว้แสดง ouput accept state

always@(clk1 || clk2) // ทำงานทุกครั้งที่กด ปุ่ม switch
	    begin // เริ่มเช็คเงื่อนไขใน map
		accept <= 1'b0;
        if(r == 3'b000 && q == 3'b000) rst1 <= 1'b0;
		else if(r == 3'b000 && q == 3'b001) rst1 <= 1'b1;
		else if(r == 3'b000 && q == 3'b010) rst1 <= 1'b0;
		else if(r == 3'b000 && q == 3'b011) rst1 <= 1'b1;
		else if(r == 3'b000 && q == 3'b100) rst1 <= 1'b0;

		else if(r == 3'b001 && q == 3'b000) rst1 <= 1'b0;
		else if(r == 3'b001 && q == 3'b001) rst1 <= 1'b1;
		else if(r == 3'b001 && q == 3'b010) #1 accept <= 1'b1;
		else if(r == 3'b001 && q == 3'b011) rst1 <= 1'b1;
		else if(r == 3'b001 && q == 3'b100) rst1 <= 1'b0;

		else if(r == 3'b010 && q == 3'b000) rst1 <= 1'b0;
		else if(r == 3'b010 && q == 3'b001) rst1 <= 1'b1;
		else if(r == 3'b010 && q == 3'b010) rst1 <= 1'b0;
		else if(r == 3'b010 && q == 3'b011) rst1 <= 1'b1;
		else if(r == 3'b010 && q == 3'b100) rst1 <= 1'b1;
		
		else if(r == 3'b011 && q == 3'b000) rst1 <= 1'b0;
		else if(r == 3'b011 && q == 3'b001) rst1 <= 1'b1;
		else if(r == 3'b011 && q == 3'b010) rst1 <= 1'b0;
		else if(r == 3'b011 && q == 3'b011) rst1 <= 1'b0;
		else if(r == 3'b011 && q == 3'b100) rst1 <= 1'b0;

		else if(r == 3'b100 && q == 3'b000) rst1 <= 1'b1;
		else if(r == 3'b100 && q == 3'b001) rst1 <= 1'b1;
		else if(r == 3'b100 && q == 3'b010) rst1 <= 1'b0;
		else if(r == 3'b100 && q == 3'b011) rst1 <= 1'b0;
		else if(r == 3'b100 && q == 3'b100) rst1 <= 1'b1;
		else rst1 <= 1'b0;

		reset <= rst1; // set ค่า reset ตาม rst1
		
		end
	
    counter3bit box1(q,r,clk1,clk2,reset,M); // เรียกใช้ block diagram ชื่อ counter3bit
	
endmodule


module counter3bit(q,r, clk1,clk2, reset, M);
	output [2:0] q,r;
	input clk1,clk2, reset, M;
		// เรียกใช้ block diagram ชื่อ count3bit ให้ส่ง output แยกกันตาม switch
        count3bit c1(q,clk1,reset,M);
        count3bit c2(r,clk2,reset,M);

endmodule

module count3bit  (q, clk, reset, M);
	output [2:0] q;
	input clk, reset, M;
	wire TA_in, TB_in, TC_in;

			// เรียกใช้ block diagram ตาม state machine ที่ออกแบบไว้
            TA_trans ta(TA_in, q[0], q[1], q[2], M); 
            TB_trans tb(TB_in, q[0], q[1], q[2], M);
            TC_trans tc(TC_in, q[0], q[1], q[2], M);            

			T_FF tff0 (q[0], TA_in, clk, reset);
			T_FF tff1 (q[1], TB_in, clk, reset);
            T_FF tff2 (q[2], TC_in, clk, reset);


endmodule

module T_FF (q, t, clk, reset);
	output q;
	input t,clk,reset;
		xor xor01(d,q,t);
		D_FF  d01(q,d,clk,reset);
endmodule

module D_FF (q, d, clk, reset);
	output q;
	input d,clk,reset;
	reg q;
	
	always @(posedge reset or negedge clk)
		if (reset)
  			q= 1'b0;
		else
  			q=d;
endmodule


module and3input (out, in1, in2 , in3);
    input in1, in2, in3;
    output out;
    wire and1Out, and2Out;
    and and1(and1Out, in1, in2);
    and and2(and2Out, in3, in3);
    and andOut(out, and1Out, and2Out);
endmodule

module or4input (out, in1, in2, in3, in4);
    input in1, in2, in3, in4;
    output out;
    wire or1out, or2out;
        or or1(or1out, in1, in2);
        or or2(or2out, in3, in4);
        or orOut(out, or1out, or2out);
endmodule

module or3input (out, in1, in2, in3);
    input in1, in2, in3;
    output out;
    wire or1out, or2out;
        or or1(or1out, in1, in2);
        or or2(or2out, in3, in3);
        or orOut(out, or1out, or2out);
endmodule

module TA_trans (out, Qa, Qb, Qc, M);
    input Qa, Qb, Qc, M;
    output out; 
    wire and1out, and2out, and3out;
        and and1(and1out, ~M, ~Qc);
        and3input and2(and2out, M, Qc, ~Qb);
        and3input and3(and3out, M, ~Qc, Qb);
        or4input or1(out, Qa, and1out, and2out, and3out);
endmodule

module TB_trans (out, Qa, Qb, Qc, M);
    input Qa, Qb, Qc, M;
    output out; 
    wire and1out, and2out, and3out, and4out;
        and and1 (and1out, Qc, Qb);
        and3input and2(and2out, M, Qc, ~Qa);
        and3input and3(and3out, ~M, ~Qc, Qa);
        and3input and4(and4out, M, Qb, ~Qa);
        or4input or1(out, and1out, and2out, and3out, and4out);
endmodule

module TC_trans (out, Qa, Qb, Qc, M);
    input Qa, Qb, Qc, M;
    output out; 
    wire and1out, and2out;
        and3input and1(and1out, M, ~Qb, ~Qa);
        and3input and2(and2out, ~M, Qb, Qa);
        or3input or1(out, Qc, and1out, and2out);
endmodule
