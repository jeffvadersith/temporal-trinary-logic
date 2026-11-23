"""
Temporal Trinary Logic (00): Cycle-Accurate Verification & Switching-Power Simulation
Version: 2.4 (20 November 2026)
Author: Peter Hunt (Independent Researcher, United Kingdom)
License: Creative Commons Attribution 4.0 International (CC BY 4.0)
Zenodo DOI: https://doi.org/10.5281/zenodo.24398575
Live Verilog RTL: https://edaplayground.com/x/TV2X

Dual-Rail [Alive, Active] Encoding:
  (1, 1) -> Active / Viable
  (1, 0) -> Dormant / Idle (Reversible)
  (0, 0) -> Terminated / T-Lock (Irreversible Absorbing State until global reset)
  (0, 1) -> Illegal / Fault State (Auto-collapses to 00)
"""

import random


class TLockNode:
    def __init__(self, node_id):
        self.node_id = node_id
        self.alive = 1
        self.active = 1
        self.gated_cycles = 0
        self.active_cycles = 0

    @property
    def state(self):
        return (self.alive, self.active)

    def reset(self):
        self.alive = 1
        self.active = 1
        self.gated_cycles = 0
        self.active_cycles = 0

    def step(self, prune_trigger=False, stall=False):
        if self.alive == 0:
            # Absorbing state (00): strictly irreversible until global reset
            self.active = 0
            self.gated_cycles += 1
            return False

        if prune_trigger:
            self.alive = 0
            self.active = 0
            self.gated_cycles += 1
            return False

        self.active = 0 if stall else 1
        self.active_cycles += 1
        return True


def run_test_a_sparse_tree(num_branches=64, depth=16, prune_prob=0.18, seed=42):
    rng = random.Random(seed)
    nodes = [TLockNode(i) for i in range(num_branches)]
    baseline_transitions = 0
    ttl_transitions = 0

    for _ in range(depth):
        for node in nodes:
            # Standard binary clock-tree still toggles control/evaluation registers
            baseline_transitions += 1
            trigger = rng.random() < prune_prob
            if node.step(prune_trigger=trigger):
                ttl_transitions += 1

    reduction = (1.0 - ttl_transitions / baseline_transitions) * 100.0
    return baseline_transitions, ttl_transitions, reduction


def run_test_b_packet_filter(num_packets=256, stages=8, match_rate=0.25, seed=42):
    rng = random.Random(seed)
    baseline_transitions = num_packets * stages
    ttl_transitions = 0

    for _ in range(num_packets):
        node = TLockNode(0)
        is_match = rng.random() < match_rate
        for stage in range(stages):
            # Stage 1 checks header; non-matching packets enter irreversible 00 T-Lock
            trigger = (stage == 1) and (not is_match)
            if node.step(prune_trigger=trigger):
                ttl_transitions += 1

    reduction = (1.0 - ttl_transitions / baseline_transitions) * 100.0
    return baseline_transitions, ttl_transitions, reduction


def run_test_c_mac_gating(num_macs=128, cycles=64, zero_sparsity=0.65, seed=42):
    rng = random.Random(seed)
    baseline_transitions = num_macs * cycles
    ttl_transitions = 0

    for _ in range(num_macs):
        node = TLockNode(0)
        # Stationary zero-weight locks MAC operand registers into 00 for the tile duration
        is_zero_weight = rng.random() < zero_sparsity
        for cycle in range(cycles):
            trigger = (cycle == 0) and is_zero_weight
            if node.step(prune_trigger=trigger):
                ttl_transitions += 1

    reduction = (1.0 - ttl_transitions / baseline_transitions) * 100.0
    return baseline_transitions, ttl_transitions, reduction


if __name__ == "__main__":
    print("=== Temporal Trinary Logic (00) v2.4 Benchmark Suite ===")
    for name, fn in [
        ("Test A (Sparse Tree Traversal)", run_test_a_sparse_tree),
        ("Test B (Streaming Packet Filter)", run_test_b_packet_filter),
        ("Test C (MAC Operand Gating)", run_test_c_mac_gating),
    ]:
        base, ttl, pct = fn()
        print(f"{name}: Baseline={base}, TTL={ttl}, Reduction={pct:.2f}%")
