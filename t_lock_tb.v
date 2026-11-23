// ============================================================================
// Testbench: t_lock_tb
// Project: Temporal Trinary Logic (00) v2.4
// Author: Peter Hunt (CC BY 4.0)
// ============================================================================

`timescale 1ns / 1ps

module t_lock_tb;

    logic        clk;
    logic        rst_n;
    logic        prune_trigger;
    logic        stall_in;
    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic [1:0]  ttl_state;
    logic        gated_clk_en;
    logic [31:0] gated_op_a;
    logic [31:0] gated_op_b;

    t_lock_core #(.DATA_WIDTH(32)) dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .prune_trigger (prune_trigger),
        .stall_in      (stall_in),
        .operand_a     (operand_a),
        .operand_b     (operand_b),
        .ttl_state     (ttl_state),
        .gated_clk_en  (gated_clk_en),
        .gated_op_a    (gated_op_a),
        .gated_op_b    (gated_op_b)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, t_lock_tb);

        // 1. Global Reset -> Enters Active (11)
        rst_n = 0; prune_trigger = 0; stall_in = 0;
        operand_a = 32'hA5A5_0001; operand_b = 32'h0000_0004;
        #12 rst_n = 1;
        #10 $display("[T=%0t] After Reset: state=%b, clk_en=%b, op_a=%h", $time, ttl_state, gated_clk_en, gated_op_a);

        // 2. Reversible Stall -> Enters Dormant (10) and recovers to (11)
        stall_in = 1;
        #10 $display("[T=%0t] Stalled:     state=%b, clk_en=%b, op_a=%h", $time, ttl_state, gated_clk_en, gated_op_a);
        stall_in = 0;
        #10 $display("[T=%0t] Resumed:     state=%b, clk_en=%b, op_a=%h", $time, ttl_state, gated_clk_en, gated_op_a);

        // 3. Prune Trigger -> Locks irreversibly into T-Lock (00)
        prune_trigger = 1;
        #10 prune_trigger = 0;
        operand_a = 32'hFFFF_FFFF;
        #20 $display("[T=%0t] T-Locked:    state=%b, clk_en=%b, op_a=%h (Irreversible check)", $time, ttl_state, gated_clk_en, gated_op_a);

        // 4. Global Reset restores (11)
        rst_n = 0;
        #10 rst_n = 1;
        #10 $display("[T=%0t] Post-Reset:  state=%b, clk_en=%b, op_a=%h", $time, ttl_state, gated_clk_en, gated_op_a);

        $finish;
    end

endmodule
