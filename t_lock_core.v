// ============================================================================
// Module: t_lock_core
// Project: Temporal Trinary Logic (00) v2.4
// Author: Peter Hunt (Independent Researcher, United Kingdom)
// License: Creative Commons Attribution 4.0 International (CC BY 4.0)
// Zenodo DOI: https://doi.org/10.5281/zenodo.24398575
// Live Simulation: https://edaplayground.com/x/TV2X
//
// Description:
//   Synthesizable dual-rail [Alive, Active] T-Lock state cell and clock/operand
//   gating controller. Once state enters 2'b00 (Terminated), it is hardware-
//   locked irreversibly until global synchronous rst_n assertion.
// ============================================================================

module t_lock_core #(
    parameter int DATA_WIDTH = 32
) (
    input  logic                  clk,
    input  logic                  rst_n,         // Active-low global domain reset
    input  logic                  prune_trigger, // Asserted when branch/weight is dead
    input  logic                  stall_in,      // Temporary reversible pause (10 state)
    input  logic [DATA_WIDTH-1:0] operand_a,
    input  logic [DATA_WIDTH-1:0] operand_b,
    output logic [1:0]            ttl_state,     // {Alive, Active}: 11, 10, or 00
    output logic                  gated_clk_en,  // Downstream clock-gate enable
    output logic [DATA_WIDTH-1:0] gated_op_a,
    output logic [DATA_WIDTH-1:0] gated_op_b
);

    logic alive_q;
    logic active_q;

    // Irreversible Absorbing State Latch (00 T-Lock)
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            alive_q  <= 1'b1;
            active_q <= 1'b1;
        end else if (!alive_q || prune_trigger) begin
            // Absorbing state: permanently locked at 00 until rst_n
            alive_q  <= 1'b0;
            active_q <= 1'b0;
        end else begin
            alive_q  <= 1'b1;
            active_q <= ~stall_in;
        end
    end

    assign ttl_state    = {alive_q, active_q};
    assign gated_clk_en = alive_q & active_q;

    // Operand isolation: clamps downstream switching to zero when in 00 or 10
    assign gated_op_a   = gated_clk_en ? operand_a : '0;
    assign gated_op_b   = gated_clk_en ? operand_b : '0;

endmodule
