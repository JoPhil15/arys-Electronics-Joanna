module tb_fault_Det;

  reg clk, rstn;
  reg [31:0] volt, current;
  wire fault, warning, shutdown;

  // Instantiate DUT
  fault_Det uut (
    .clk(clk),
    .rstn(rstn),
    .volt(volt),
    .current(current),
    .fault(fault),
    .warning(warning),
    .shutdown(shutdown)
  );

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  initial begin
    $dumpfile("tb_fault_Det.vcd");  
    $dumpvars(0, tb_fault_Det);

    clk   = 1;
    rstn  = 0;
    volt  = 32'h00000000;
    current = 32'h00000000;

    // Reset pulse
    #12 rstn = 1;

    // --- Test 1: Normal operation ---
    volt = 32'h3f800000;     // ~1.0
    current = 32'h3f000000;  // ~0.5
    #50;

    // --- Test 2: Over voltage (> 5.0) ---
    volt = 32'h40a00001;
    #70;

    // --- Test 3: Reset recovery after SHUTDOWN ---
    rstn = 0;
    volt = 32'h3f800000;     // 1.0
    #20 rstn = 1;

    // --- Test 3: Over current (> 2.0) ---
    current = 32'h40000001;
    #70;

    // --- Test 3: Reset recovery after SHUTDOWN ---
    rstn = 0;
    current = 32'h3f000000;  // 0.5
    #20 rstn = 1;

    // --- Test 4: Under voltage (< 0.1) ---
    volt = 32'h3d000000;
    #70;

    // --- Test 3: Reset recovery after SHUTDOWN ---
    rstn = 0;
    volt = 32'h3f800000;     // 1.0
    #20 rstn = 1;

    // --- Test 5: Persist abnormal condition to trigger FAULT/SHUTDOWN ---
    volt = 32'h40a00001;  // Keep high voltage for >3 cycles
    repeat(5) @(posedge clk);
    #20;

    // --- Test 6: Return to safe values ---
    volt = 32'h3f800000;     // 1.0
    current = 32'h3f000000;  // 0.5
    #50;

    // --- Test 7: Reset recovery after SHUTDOWN ---
    rstn = 0;
    #20 rstn = 1;
    #50;

    $finish;
  end

  // Monitor outputs and key signals
  initial begin
    $monitor("t=%0t | rstn=%b volt=%h current=%h | warning=%b fault=%b shutdown=%b",
              $time, rstn, volt, current, warning, fault, shutdown);
  end

endmodule

