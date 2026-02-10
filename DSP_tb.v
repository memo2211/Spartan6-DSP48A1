module DSP_tb();
    
    parameter A0REG_tb=0 , A1REG_tb=1 ,B0REG_tb=0 ,B1REG_tb=1;
    parameter CREG_tb=1, DREG_tb=1, MREG_tb=1, PREG_tb=1, CARRYINREG_tb=1, CARRYOUTREG_tb=1, OPREG_tb=1;
    parameter CARRYINSEL_tb="OPMODE5";
    parameter B_INPUT_tb="DIRECT";
    parameter RSTTYPE_tb ="SYNC";
    parameter w1_tb=1, w8_tb=8, w18_tb=18, w36_tb=36, w48_tb=48;

    reg [w18_tb-1:0] a_tb, b_tb,d_tb;
    reg [w1_tb-1:0] cin_tb;
    reg [w48_tb-1:0] c_tb;
    reg [w8_tb-1:0] opmode_tb;
    reg [47:0] Pcin_tb;
    reg [17:0] Bcin_tb;
    reg clk_tb,CEa_tb,CEb_tb,CEc_tb,CEcin_tb,CEd_tb,CEm_tb,CEopmode_tb,CEp_tb;
    reg rsta_tb,rstb_tb,rstc_tb,rstcin_tb,rstd_tb,rstM_tb,rstopmode_tb,rstP_tb;
    
    wire [35:0] M_dut;
    wire [47:0] P_dut;
    wire cout_dut,coutf_dut;
    wire [17:0] bcout_dut;
    wire [47:0] Pcout_dut;
    
    DSP #(.A0REG(A0REG_tb), .A1REG(A1REG_tb), .B0REG(B0REG_tb), .B1REG(B1REG_tb),
          .CREG(CREG_tb), .DREG(DREG_tb), .MREG(MREG_tb), .PREG(PREG_tb), 
          .CARRYINREG(CARRYINREG_tb), .CARRYOUTREG(CARRYOUTREG_tb), .OPREG(OPREG_tb),
          .CARRYINSEL(CARRYINSEL_tb), .B_INPUT(B_INPUT_tb), .RSTTYPE(RSTTYPE_tb),
          .w1(w1_tb), .w8(w8_tb), .w18(w18_tb), .w36(w36_tb), .w48(w48_tb))
        
        D1(a_tb, b_tb, c_tb, d_tb, cin_tb, opmode_tb, Pcin_tb, Bcin_tb, clk_tb,
           CEa_tb, CEb_tb, CEc_tb, CEcin_tb, CEd_tb, CEm_tb, CEopmode_tb, CEp_tb,
           rsta_tb, rstb_tb, rstc_tb, rstcin_tb, rstd_tb, rstM_tb, rstopmode_tb,
           rstP_tb, M_dut, P_dut, cout_dut, coutf_dut, bcout_dut, Pcout_dut);

    initial begin
        clk_tb=0;
        forever begin
            #1 clk_tb=~clk_tb;
        end
    end

    integer i;
    initial begin
        rsta_tb=1; rstb_tb=1; rstc_tb=1; rstcin_tb=1; rstd_tb=1; rstM_tb=1; rstopmode_tb=1; rstP_tb=1;
        a_tb=$random; b_tb=$random; c_tb=$random; d_tb=$random;
        cin_tb=$random;
        opmode_tb=$random;
        Pcin_tb=$random;
        Bcin_tb=$random;
        CEa_tb=$random; CEb_tb=$random; CEc_tb=$random; CEcin_tb=$random; CEd_tb=$random;
        CEm_tb=$random; CEopmode_tb=$random; CEp_tb=$random;

        @(negedge clk_tb);
        if (M_dut!=0 || P_dut!=0 || cout_dut!=0 || coutf_dut!=0 || bcout_dut!=0 || Pcout_dut!=0 ) begin
            $display("error");
            $stop;
        end
        else begin
            $display("BCOUT=%h, M=%h, P=%h, PCOUT=%h, Carryout=%h, Carryoutf=%h",bcout_dut, M_dut, P_dut, Pcout_dut, cout_dut, coutf_dut);
            $display("reset function is good");
        end

        rsta_tb=0; rstb_tb=0; rstc_tb=0; rstcin_tb=0; rstd_tb=0; rstM_tb=0; rstopmode_tb=0; rstP_tb=0;
        CEa_tb=1; CEb_tb=1; CEc_tb=1; CEcin_tb=1; CEd_tb=1; CEm_tb=1; CEopmode_tb=1; CEp_tb=1;

        opmode_tb= 8'b11011101;
        a_tb = 20; b_tb = 10; c_tb= 350; d_tb = 25; 
        cin_tb=$random; Pcin_tb=$random; Bcin_tb=$random;
        
        repeat(4) @(negedge clk_tb);
        if (bcout_dut !='hf ||  M_dut != 'h12c || P_dut !='h32 || Pcout_dut != 'h32 || cout_dut != 0 || coutf_dut!= 0) begin
            $display("error");
            $stop;
        end
        else begin
            $display("BCOUT=%h, M=%h, P=%h, PCOUT=%h, Carryout=%h, Carryoutf=%h",bcout_dut,M_dut, P_dut, Pcout_dut, cout_dut, coutf_dut);
            $display("no errors in path 1");
        end

        opmode_tb= 8'b00010000;
        a_tb = 20; b_tb = 10; c_tb= 350; d_tb = 25; 
        cin_tb=$random; Pcin_tb=$random; Bcin_tb=$random;
        repeat(3) @(negedge clk_tb);
        if (bcout_dut !='h23 ||  M_dut != 'h2bc || P_dut !='h0 || Pcout_dut != 'h0 || cout_dut != 0 || coutf_dut!= 0) begin
            $display("error");
            $stop;
        end
        else begin
            $display("BCOUT=%h, M=%h, P=%h, PCOUT=%h, Carryout=%h, Carryoutf=%h",bcout_dut, M_dut, P_dut, Pcout_dut, cout_dut, coutf_dut);
            $display("no errors in path 2");
        end
        
        opmode_tb= 8'b00001010;
        a_tb = 20; b_tb = 10; c_tb= 350; d_tb = 25; 
        cin_tb=$random; Pcin_tb=$random; Bcin_tb=$random;
        repeat(3) @(negedge clk_tb);
        if (bcout_dut !='ha ||  M_dut != 'hc8 || P_dut !='h0 || Pcout_dut != 'h0 || cout_dut != 0 || coutf_dut!= 0) begin
            $display("error");
            $stop;
        end
        else begin
            $display("BCOUT=%h, M=%h, P=%h, PCOUT=%h, Carryout=%h, Carryoutf=%h",bcout_dut, M_dut, P_dut, Pcout_dut, cout_dut, coutf_dut);
            $display("no errors in path 3");
        end

        opmode_tb= 8'b10100111;
        a_tb = 5; b_tb = 6; c_tb= 350; d_tb = 25; Pcin_tb=3000; 
        cin_tb=$random; Bcin_tb=$random;
        repeat(3) @(negedge clk_tb);
        if (bcout_dut !='h6 ||  M_dut != 'h1e || P_dut !='hfe6fffec0bb1 || Pcout_dut !='hfe6fffec0bb1 || cout_dut != 1 || coutf_dut!= 1) begin
            $display("BCOUT=%h, M=%h, P=%h, PCOUT=%h, Carryout=%h, Carryoutf=%h",bcout_dut, M_dut, P_dut, Pcout_dut, cout_dut, coutf_dut);
            $display("error");
            $stop;
        end
        else begin
            $display("BCOUT=%h, M=%h, P=%h, PCOUT=%h, Carryout=%h, Carryoutf=%h",bcout_dut, M_dut, P_dut, Pcout_dut, cout_dut, coutf_dut);
            $display("no errors in path 4");
        end

        $display("all is good isa");
        $stop;

    end

endmodule