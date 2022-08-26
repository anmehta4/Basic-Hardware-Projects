module microwave_SM_tb();

  ///// stimulus of type reg /////
  reg error;			// error flag set true if error detected
  reg clk, rst_n;		//	clock and async active low reset
  reg press;			// Add30 button pressed
  reg open;				// door open sensor
  
  ///// Outputs of DUT connected to wires /////
  wire set4,set30;		// set signals to timer
  wire inc30;			// increment timer by 30
  wire dec;				// decrement timer
  wire on;				// Magnetron on
  wire beep;			// beeping
  
  ////////////////////////////////////////////
  // Declare any needed internal registers //
  //////////////////////////////////////////
  reg [6:0] tmr;			// timer of microwave
  
  ///////////////////////////
  // Instantiate DUT (SM) //
  /////////////////////////
  microwave_SM iDUT(.clk(clk),.rst_n(rst_n),.press(press),.open(open),
                    .tmr_zr(~|tmr),.set30(set30),.set4(set4),.inc30(inc30),
                    .dec(dec),.on(on),.beep(beep));

  //////////////////////////////////////////
  // Main stimulus initial block follows //
  ////////////////////////////////////////
  initial begin
    error = 0;		// innocent till proven guilty
    clk = 0;
	rst_n = 0;
	press = 0;
	open = 0;
	@(posedge clk);
	@(negedge clk);
	rst_n = 1;			// dassert reset
	repeat (2) @(negedge clk);
	if (on | beep) begin
	  $display("ERR: at time %t",$time);
	  $display("     Just came out of reset.  Niether on nor beep should be asserted");
	  error = 1;
	end else $display("GOOD: reset to off passed");
	
	//// Now press button and check it transitions to ON ////
	press = 1;			// should transition to ON state with timer of 30
	@(negedge clk);
	if ((tmr!==7'd30) || (!on)) begin
	  $display("ERR: at time %t",$time);
	  $display("     Should be in ON state with timer of 30");
	  error = 1;
    end	else $display("GOOD: transition to ON via press passed");
	
	//// check it maintains in ON ////
    #1;
	press = 0;
	@(negedge clk);
	if (!on) begin
	  $display("ERR: at time %t",$time);
	  $display("     Should still be ON");
	  error = 1;
    end		
	
	@(negedge clk);
	
	//// Now open door and ensure it turns off ////
	#1;
	open = 1;
	@(negedge clk);
	if ((tmr>7'd28) || (on)) begin
	  $display("ERR: at time %t",$time);
	  $display("     Door open, should be OFF with timer < 30");
	  error = 1;
    end else $display("GOOD: door open shut off oven");
	
	//// Now press button while door open, ensure timer increments ///
	#1;
	press = 1;		// test a press of button with door open
	@(negedge clk);
	if ((tmr<7'd50) || (on)) begin
	  $display("ERR: at time %t",$time);
	  $display("     button press with door open should still inc timer, should be off");
	  error = 1;
	end else $display("GOOD: press with door open passed");
	
	//// now close door and check transition back to ON ////
	#1;
	press = 0;
	open = 0;
	@(negedge clk);
	if (!on) begin
	  $display("ERR: at time %t",$time);
	  $display("     Door closed so should have transitioned back to ON");
	  error = 1;
	end else $display("GOOD: transition back to ON on door close passed");
	
	//// Now wait out majority of timer and check still on ////
	repeat (50) @(negedge clk);
	if (!on) begin
	  $display("ERR: at time %t",$time);
	  $display("     Should still be on");
	  error = 1;
	end

	//// Now wait out rest of timer and ensure entered BEEP state ////
	repeat (9) @(negedge clk);
	if ((on) || (!beep))  begin
	  $display("ERR: at time %t",$time);
	  $display("     Oven should be off and beeping now");
	  error = 1;
	end	else $display("GOOD: passed Beep test at time %t",$time);
	
	//// Now while in BEEP state do a button press so it goes back to ON ///
	#1;
	press = 1;
	@(negedge clk);
	if ((beep) || (!on) || (tmr<7'd29) || (tmr>7'd30)) begin
	  $display("ERR: button pressed while in BEEP state, should be ON");
	  $display("     should not be beeping, and timer should be 30");
	  error = 1;
	end else $display("GOOD: press while beeping resumed cooking");

    //// Now wait out cook time again ////
    #1;
    press = 0;
    repeat(31) @(negedge clk);
 	if ((on) || (!beep))  begin
	  $display("ERR: at time %t",$time);
	  $display("     Oven should be off and beeping now");
	  error = 1;
	end	else $display("GOOD: passed Beep test 2 at time %t",$time);   

    //// Now wait out BEEP time ////
    repeat(4) @(negedge clk);
 	if ((on) || (beep) || (tmr>7'd0))  begin
	  $display("ERR: at time %t",$time);
	  $display("     Oven should be in OFF state with timer zero");
	  error = 1;
	end	else $display("GOOD: passed transition to OFF from BEEP");  	

	if (!error) begin
	  $display("YAHOO!! microwave test passed!");
	  $stop();
	end
	
	$stop();
	
  end
  
  /// model clock oscillator ///
  always
    #5 clk = ~clk;


  //////////////////
  // model timer //
  ////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  tmr <= 7'h00;
	else if (set4)
	  tmr <= 7'h04;
	else if (set30)
	  tmr <= 7'd30;
	else if (inc30)
	  tmr <= tmr + 7'd30;
	else if (dec)
	  tmr <= tmr - 7'h01;
	  
endmodule