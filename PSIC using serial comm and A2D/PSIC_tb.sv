module PSIC_tb();

  ///////////////////////////////
  // Declare stimulus signals //
  /////////////////////////////
  logic clk,rst_n;				// clock and asynch active low reset
  logic [23:0] cmd2send;		// command/data to send to PSIC
  logic send_cmd;				// strobed high to initiate send
  logic error;					// flag to keep track of error in test
  
  ///////////////////////////////////////////////
  // Declare internal signals being monitored //
  /////////////////////////////////////////////
  logic sensor_rdy;				// data returned by sensor is ready
  logic [15:0] sensor_rcvd;		// data received from sensor
  
  /////////////////////////////
  // Other internal signals //
  ///////////////////////////
  logic RX,TX;					// serial lines to/fro sensor

  
  /////////////////////////////
  // Instantiate DUT (PSIC) //
  ///////////////////////////
  PSIC iDUT(.clk(clk),.rst_n(rst_n),.RX(RX), .TX(TX));
  
  
  ///////////////////////////////////////////////////////
  // Instantiate serial_mstr to drive commands to DUT //
  /////////////////////////////////////////////////////
  serial_mstr iMSTR(.clk(clk),.rst_n(rst_n),.sensor_rdy(sensor_rdy),
                    .sensor_data(sensor_rcvd),.cmd2send(cmd2send),.send_cmd(send_cmd),
					.RX(TX),.TX(RX));
					
  initial begin
    error = 0;					// innocent till proven guilty
    clk = 0;
	rst_n = 0;
	send_cmd = 0;
	cmd2send = 24'h07_4000;		// Write Gain to unity
	@(posedge clk);
	@(negedge clk);
	rst_n = 1;					// deassert reset

	/////////////////////////////////////////////////////////
	// First test is write to NV_MEM looking for response //
	///////////////////////////////////////////////////////
	@(negedge clk);				// send first command (write Gain unity)
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	
	fork
	  begin: timeout1
	    repeat(10000) @(negedge clk);
		$display("ERR: timed out waiting for response from write to NV_MEM");
		error = 1;
		$stop();
	  end
	  begin
	    while (!sensor_rdy) @(negedge clk);
              disable timeout1;
		$display("GOOD: Test1 passed, write to NV_MEM gave response");
	  end
	join
	
	///////////////////////////////////////////////////////////////
	// second test is read of pressure.  With no Tco, no Offset //
	// and unity gain the result should match raw A2D reading  //
	////////////////////////////////////////////////////////////
	cmd2send = 24'h00_0000;		// read pressure
	@(negedge clk);				// send second command (get sensor reading)
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	
	fork
	  begin: timeout2
	    repeat(10000) @(negedge clk);
		$display("ERR: timed out waiting for first corrected pressure");
		error = 1;
	  end
	  begin
	    while (!sensor_rdy) @(negedge clk);
        disable timeout2;
		if (sensor_rcvd!==16'h3456) begin
		  $display("ERR: result should be PRESSURE[0] = 16'h3456");
		  error = 1;
		end else
		  $display("GOOD: Test2 passed, raw mode reading worked");
	  end
	join
	
	//////////////////////////////////////////////////////////////
	// Third test write Gain to 1.25, Then get another reading //
	////////////////////////////////////////////////////////////
	cmd2send = 24'h07_5000;		// write Gain = 1.25
	@(negedge clk);				// send third command (write Gain 1.25)
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	/// wait for response ///
	while (!sensor_rdy) @(negedge clk);
	cmd2send = 24'h00_5000;		// Get reading
	@(negedge clk);
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	
	fork
	  begin: timeout3
	    repeat(10000) @(negedge clk);
		$display("ERR: timed out waiting for second corrected pressure");
		error = 1;
	  end
	  begin
	    while (!sensor_rdy) @(negedge clk);
        disable timeout3;
		if (sensor_rcvd!==16'h496B) begin
		  $display("ERR: result should be 1.25*PRESSURE[1] = 16'h496B");
		  error = 1;
		end else
		  $display("GOOD: Test3 passed, 1.25 Gain worked");
	  end
	join
	
	//////////////////////////////////////////////////////////////
	// Fourth test write Offset to x0025, write gain to 1 Then get another reading //
	////////////////////////////////////////////////////////////
	cmd2send = 24'h06_0025;		// write Offset = 0x0025
	@(negedge clk);				// send fourth command (write Offset x0025)
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	/// wait for response ///
	while (!sensor_rdy) @(negedge clk);
	cmd2send = 24'h00_0025;		// Get reading
	@(negedge clk);
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	
	fork
	  begin: timeout4
	    repeat(10000) @(negedge clk);
		$display("ERR: timed out waiting for second corrected pressure");
		error = 1;
	  end
	  begin
	    while (!sensor_rdy) @(negedge clk);
        disable timeout4;
		if (sensor_rcvd!==16'h7FFF) begin
		  $display("ERR: result should be 1.25*(PRESSURE[2]+OFFSET) = 16'h7FFF"); // due to + saturation
		  error = 1;
		end else
		  $display("GOOD: Test4 passed, Offset = 0x0025, Tco = 0, Gain = 1.25 with + saturation worked");
	  end
	join

	//////////////////////////////////////////////////////////////////////////////
	// Fifth test write TCoeff to -1,write gain to one Then get another reading //
	/////////////////////////////////////////////////////////////////////////////
	cmd2send = 24'h07_4000;		// write gain to unity
	@(negedge clk);				// send fifth command (write gain to unity)
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	/// wait for response ///
	while (!sensor_rdy) @(negedge clk);

	cmd2send = 24'h05_C000;		// write TCoeff to -1
	@(negedge clk);				// send sixth command (write coeff to -1)
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	/// wait for response ///
	while (!sensor_rdy) @(negedge clk);
	cmd2send = 24'h00_4000;		// Get reading
	@(negedge clk);
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	
	fork
	  begin: timeout5
	    repeat(10000) @(negedge clk);
		$display("ERR: timed out waiting for second corrected pressure");
		error = 1;
	  end
	  begin
	    while (!sensor_rdy) @(negedge clk);
        disable timeout5;
		if (sensor_rcvd!==16'h4025) begin
		  $display("ERR: result should be 1.00*(PRESSURE[4] + OFFSET + TCO*PTAT) = 16'h4025"); 
		  error = 1;
		end else
		  $display("GOOD: Test5 passed, Offset = 0x0025, Tco = -1.00, Gain = 1.00 with no saturation worked");
	  end
	join

	//////////////////////////////////////////////////////////////
	// Sixth test write Offset to x0105 Then get another reading //
	////////////////////////////////////////////////////////////
	cmd2send = 24'h06_0105;		// write Offset = 0x0105
	@(negedge clk);				// send seventh command (write Offset x0025)
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	/// wait for response ///
	while (!sensor_rdy) @(negedge clk);


	cmd2send = 24'h00_0025;		// Get reading
	@(negedge clk);
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	
	fork
	  begin: timeout6
	    repeat(10000) @(negedge clk);
		$display("ERR: timed out waiting for second corrected pressure");
		error = 1;
	  end
	  begin
	    while (!sensor_rdy) @(negedge clk);
        disable timeout6;
		if (sensor_rcvd!==16'h0105) begin
		  $display("ERR: result should be 1.00*(PRESSURE[5] + OFFSET + TCO*PTAT) = 16'h0105"); 
		  error = 1;
		end else
		  $display("GOOD: Test6 passed, Offset = 0x0105, Tco = -1.00 Gain = 1.00 with no saturation worked");
	  end
	join

	//////////////////////////////////////////////////////////////
	// Seventh test write Tco to -1 Then get another reading //
	////////////////////////////////////////////////////////////
	cmd2send = 24'h06_6668;		// write offset = 0x6668
	@(negedge clk);				// send eigth command (write offset = 0x6668)
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	/// wait for response ///
	while (!sensor_rdy) @(negedge clk);

	cmd2send = 24'h05_C000;		// write TCoeff to -1
	@(negedge clk);				// send ninth command (write coeff to -1)
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	/// wait for response ///
	while (!sensor_rdy) @(negedge clk);

	cmd2send = 24'h07_A000;		// write gain to -1.5
	@(negedge clk);				// send tenth command (write gain to -1.5)
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	/// wait for response ///
	while (!sensor_rdy) @(negedge clk);

	cmd2send = 24'h00_0025;		// Get reading
	@(negedge clk);
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	
	fork
	  begin: timeout7
	    repeat(10000) @(negedge clk);
		$display("ERR: timed out waiting for second corrected pressure");
		error = 1;
	  end
	  begin
	    while (!sensor_rdy) @(negedge clk);
        disable timeout7;
		if (sensor_rcvd!==16'h8000) begin
		  $display("ERR: result should be 1.00*(PRESSURE[6] + OFFSET + TCO*PTAT) = 16'h8000"); // due to - saturation
		  error = 1;
		end else
		  $display("GOOD: Test7 passed, Offset = 0x6888, Tco = -1.00, Gain = -1.50 with - saturation worked");
	  end
	join

	//////////////////////////////////////////////////////////////
	// Seventh test write Tco to -1 Then get another reading //
	////////////////////////////////////////////////////////////
	cmd2send = 24'h06_0000;		// write offset = 0x0000
	@(negedge clk);				// send eigth command (write offset = 0x0000)
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	/// wait for response ///
	while (!sensor_rdy) @(negedge clk);

	cmd2send = 24'h05_4000;		// write TCoeff to 1
	@(negedge clk);				// send ninth command (write coeff to 1)
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	/// wait for response ///
	while (!sensor_rdy) @(negedge clk);

	cmd2send = 24'h07_4000;		// write gain to 1
	@(negedge clk);				// send tenth command (write gain to 1)
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	/// wait for response ///
	while (!sensor_rdy) @(negedge clk);

	cmd2send = 24'h00_0025;		// Get reading
	@(negedge clk);
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	
	fork
	  begin: timeout8
	    repeat(10000) @(negedge clk);
		$display("ERR: timed out waiting for second corrected pressure");
		error = 1;
	  end
	  begin
	    while (!sensor_rdy) @(negedge clk);
        disable timeout8;
		if (sensor_rcvd!==16'h7FFF) begin
		  $display("ERR: result should be 1.00*(PRESSURE[7] + OFFSET + TCO*PTAT) = 16'h7FFF"); // due to + saturation
		  error = 1;
		end else
		  $display("GOOD: Test8 passed, Offset = 0x0000, Tco = 1.00, Gain = 1.00  with + saturation worked");
	  end
	join
	////////////////////////////////////////////////////////////////////////////
	// Study method of above tests.  Use copy/paste/modify to add more tests //
	//////////////////////////////////////////////////////////////////////////
	
	if (!error) begin
	  $display("YAHOO!! all tests passed!");
	end else
	  $display("ERRORS exist...continue debugging");
	  
	$stop();
  end
  
  always
    #5 clk = ~clk;
  
endmodule