module DSP(a,b,c,d,cin,opmode,Pcin,Bcin,clk,CEa,CEb,CEc,CEcin,CEd,CEm,
           CEopmode,CEp,rsta,rstb,rstc,rstcin,rstd,rstM,rstopmode,rstP,M,P,cout,coutf,bcout,Pcout);

    parameter A0REG=0 , A1REG=1 ,B0REG=0 ,B1REG=1;
    parameter CREG=1, DREG=1, MREG=1, PREG=1, CARRYINREG=1, CARRYOUTREG=1, OPREG=1;
    parameter CARRYINSEL="OPMODE5";
    parameter B_INPUT="DIRECT";
    parameter RSTTYPE ="SYNC";
    parameter w1=1, w8=8, w18=18, w36=36, w48=48;

    input [w18-1:0] a, b,d;
    input [w1-1:0] cin;
    input [w48-1:0] c;
    input [w8-1:0] opmode;
    input [47:0] Pcin;
    input [17:0] Bcin;
    input clk,CEa,CEb,CEc,CEcin,CEd,CEm,CEopmode,CEp;
    input rsta,rstb,rstc,rstcin,rstd,rstM,rstopmode,rstP;
    
    output [35:0] M;
    output [47:0] P;
    output cout,coutf;
    output [17:0] bcout;
    output [47:0] Pcout;

    wire [w18-1:0] d_reg;
    wire [w18-1:0] b0_reg;
    wire [w18-1:0] bb;
    wire [w18-1:0] a0_reg;
    wire [w48-1:0] c_reg;
    wire [w8-1:0] opmode_reg;
    wire [w18-1:0] k0;
    wire [w18-1:0] add1_out;
    wire [w18-1:0] k0_reg;
    wire [w18-1:0] a1_reg;
    wire [w36-1:0] m;
    wire [w36-1:0] m_reg;
    wire k1;
    wire Cin;
    wire [47:0] conc;
    wire [47:0] x_out,z_out;
    wire [47:0] add2_out;
    wire cout0;

    assign bb=(B_INPUT=="DIRECT")?b:(B_INPUT=="CASCADE")?Bcin:18'b0;
    
    reg_mul #(.REG(DREG),.RSTtype(RSTTYPE),.width(w18)) D_REG(clk,rstd,CEd,d,d_reg);
    reg_mul #(.REG(B0REG),.RSTtype(RSTTYPE),.width(w18)) B0_REG(clk,rstb,CEb,bb,b0_reg);
    reg_mul #(.REG(A0REG),.RSTtype(RSTTYPE),.width(w18)) A0_REG(clk,rsta,CEa,a,a0_reg);
    reg_mul #(.REG(CREG),.RSTtype(RSTTYPE),.width(w48)) C_REG(clk,rstc,CEc,c,c_reg);
    reg_mul #(.REG(OPREG),.RSTtype(RSTTYPE),.width(w8)) opmode_REG(clk,rstopmode,CEopmode,opmode,opmode_reg);
    
    assign add1_out=(opmode_reg[6]==0)?d_reg+b0_reg:d_reg-b0_reg;
    assign k0=(opmode_reg[4]==0)?b0_reg:add1_out;
    
    reg_mul #(.REG(B1REG),.RSTtype(RSTTYPE),.width(w18)) B1_REG(clk,rstb,CEb,k0,k0_reg);
    reg_mul #(.REG(A1REG),.RSTtype(RSTTYPE),.width(w18)) A1_REG(clk,rsta,CEa,a0_reg,a1_reg);

    assign bcout=k0_reg;
    assign m=k0_reg*a1_reg;

    reg_mul #(.REG(MREG),.RSTtype(RSTTYPE),.width(w36)) M_REG(clk,rstM,CEm,m,m_reg);
    
    assign M=m_reg;
    assign k1=(CARRYINSEL=="OPMODE5")?opmode_reg[5]:cin;
    
    reg_mul #(.REG(CARRYINREG),.RSTtype(RSTTYPE),.width(w1)) CYI(clk,rstcin,CEcin,k1,Cin);

    assign conc={d[11:0],a1_reg[17:0],k0_reg[17:0]};
    
    assign x_out=(opmode_reg[1:0]==2'b00)?48'b0:(opmode_reg[1:0]==2'b01)?{{(w48 - w36){1'b0}},m_reg}:
    (opmode_reg[1:0]==2'b10)?Pcout:conc;

    assign z_out=(opmode_reg[3:2]==2'b00)?48'b0:(opmode_reg[3:2]==2'b01)?Pcin:(opmode_reg[3:2]==2'b10)?Pcout:c_reg;
    assign {cout0,add2_out}=(opmode_reg[7]==0)?z_out+x_out+Cin : z_out-(x_out+Cin);

    reg_mul #(.REG(CARRYOUTREG),.RSTtype(RSTTYPE),.width(w1)) CYO(clk,rstcin,CEcin,cout0,cout);

    assign coutf=cout;

    reg_mul #(.REG(PREG),.RSTtype(RSTTYPE),.width(w48)) P_REG(clk,rstP,CEp,add2_out,P);

    assign Pcout = P;

    // Dummy usage to avoid unconnected port warnings
    // generate
    //     if (CARRYINSEL == "OPMODE5") begin
    //         (* DONT_TOUCH = "true" *) wire cin_unused = |cin;
    //     end

    //     if (B_INPUT != "CASCADE") begin
    //         (* DONT_TOUCH = "true" *) wire bcin_unused = |Bcin;
    //     end
    // endgenerate

endmodule