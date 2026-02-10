module reg_mul(clk,rst,ce,in,out);
    
    parameter REG=1;//select 
    parameter RSTtype="SYNC";//rst is syncronus
    parameter width=18;
    input clk,rst,ce;
    input [width-1:0] in;
    output reg [width-1:0] out;
    
    generate
        if(REG==1)begin
            if (RSTtype == "SYNC") begin
                always @(posedge clk) begin
                    if(rst)
                        out<=0;
                    else if(ce)begin
                        out<=in;
                    end
                end
            end
            else if (RSTtype == "ASYNC") begin
                always @(posedge clk or posedge rst) begin
                    if(rst)
                        out<=0;
                    else if(ce)begin
                        out<=in;
                    end
                end
            end
        end
        else begin
            always @(*) begin
                out=in;
            end
            // Dummy usage to avoid unconnected port warnings

            (* DONT_TOUCH = "true" *) reg clk_unused, rst_unused, ce_unused;
            // always @(posedge clk) begin
            //      clk_unused <= clk_unused;
            //      rst_unused <= rst;
            //      ce_unused<=ce;
            //  end
        end
    endgenerate
    
endmodule