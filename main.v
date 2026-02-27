module main(clk, PBtop, PBbot, led0, led1, led2, led3, led4, led5, led6, led7, led8, led9, sec_ones, sec_tens, min_ones, min_tens, hr_ones, hr_tens);

input clk, PBtop, PBbot;

output reg led0, led1, led2, led3, led4, led5, led6, led7, led8, led9;

output [6:0] sec_ones, sec_tens, min_ones, min_tens, hr_ones, hr_tens; //hex displays 0-5

reg [4:0] time_hr=0;
reg [5:0] time_min=0;
reg [5:0] time_sec=0; //internal time values

reg [4:0] alarm_hrs=0;
reg [5:0] alarm_mins=0;	//alarm values

reg [6:0] stopwatch_ms = 0;
reg [5:0] stopwatch_sec = 0;
reg [5:0] stopwatch_min = 0; //stopwatch values

reg [4:0] timer_hr=0;
reg [5:0] timer_min=0;
reg [5:0] timer_sec=0; //internal timer values

reg [3:0] h_tens, h_ones, m_tens, m_ones, s_tens, s_ones; 

reg [3:0] s=0; //high-level states
reg [1:0] sw_state=2'b10; //stopwatch states
reg timer_state = 1; //timer states

wire slow_clk, flash_clk, timer_clk;

clock_divider myclock(.cin(clk), .cout(slow_clk));		//normal operation clock
clock_divider myFlashClock(.cin(clk), .cout(flash_clk)); //flash operation clock
ms_clock_divider myTimerClock(.cin(clk), .cout(timer_clk)); //timer clock for milliseconds

//States (PBtop)
//1. Display Time
localparam TIME_DISPLAY = 4'b0000;		//1

//2. Set time
localparam TIME_SET_HRS = 4'b0001,		//a. set hrs, display hrs only (1)
			  TIME_SET_MINS = 4'b0010,	   //b. set mins, display mins only (2)
			  TIME_SET_SECS = 4'b0011,		//c. set secs, display secs only (3)
			  TIME_SET_TIME = 4'b0100;		//d. set time, display all three units, real time set in background (4)

//3. Alarm
localparam ALRM_MODE = 4'b0101, 			//a. Mode name display (5)
			  ALRM_SET_HRS = 4'b0110,		//a. set hrs (6)
			  ALRM_SET_MINS = 4'b0111,		//b. set mins (7)
			  ALRM_SET = 4'b1000;			//c. set alarm, display alarm time (8)

//4. Stopwatch
localparam STPWTCH_MODE	= 4'b1001;					//a. Mode name display (9)
//			  START = 4'b0111,				
//			  STOP = 4'b1000,
//			  RESET = 4'b1001;

//5. Timer
localparam TIMER_SET_HRS = 4'b1010, 	//a. set hrs (10)
			  TIMER_SET_MINS = 4'b1011,	//b. set mins (11)
			  TIMER_SET_SECS = 4'b1100,	//c. set secs (12)
			  TIMER_ACTIVE = 4'b1101,		//d. timer active (13)
			  //TIMER_START;
			  //TIMER_STOP;
			  TIMER_END = 4'b1110;			//e. end timer (14)
			  
			  
//timer internal states

localparam TIMER_START = 1'b0,
			  TIMER_PAUSE = 1'b1;



//filter to avoid rapid consecutive presses

reg prev_PBtop, prev_PBbot;

always @(posedge slow_clk) begin
    prev_PBtop <= PBtop;
	 prev_PBbot <= PBbot;
end


wire PBtop_rising = PBtop & ~prev_PBtop;
wire PBbot_rising = PBbot & ~ prev_PBbot;	


//Modes, Button Logic

always @(posedge slow_clk) begin

	//change state at every PBtop push
	 if (PBtop_rising) s <= s + 1;
	 
	 //change stopwatch internal modes
	 if (PBbot_rising && s==STPWTCH_MODE) begin
		if(sw_state == 2'b10) sw_state <= 0;
		else sw_state <= sw_state + 1; //change stopwatch state (PBbot)
	 end
	 
	 //change timer internal mode
	 
	 if (PBbot_rising && s==TIMER_ACTIVE) timer_state <= timer_state + 1;
	 
		
	//Set Time (PBbottom)
		if (PBbot_rising && s==TIME_SET_HRS) begin
			//increment internal time hours
			if (time_hr==23) time_hr <= 0;
			else time_hr <= time_hr + 1;
		end
		else if (PBbot_rising && s==TIME_SET_MINS) begin
			//increment internal time minutes
			if (time_min==59) time_min <= 0;
			else time_min <= time_min + 1;
			
		end
		else if (PBbot_rising && s==TIME_SET_SECS) begin
			//increment internal time seconds
			if(time_sec==59) time_sec <= 0;
			else time_sec <= time_sec + 1;
			
		end
		
		//Internal time (default increment)
		else begin
			if(time_sec==59) begin
				time_sec <= 0;
				if(time_min==59) begin
					time_min <= 0;
						if(time_hr==23) time_hr <= 0;
						else time_hr <= time_hr + 1; //increment hrs after 59 min
				end
				else time_min<= time_min + 1; //increment mins after 59 sec
			end
	
			else time_sec <= time_sec + 1;
			
		end
	
	//alarm clock mode
	if (PBbot_rising && s==ALRM_SET_HRS) begin
		if(alarm_hrs==23) alarm_hrs <= 0;
		else alarm_hrs <= alarm_hrs + 1;
	end
	else if (PBbot_rising && s==ALRM_SET_MINS) begin
		if(alarm_mins==59) alarm_mins <= 0;
		else alarm_mins <= alarm_mins + 1; 
	end
		
		
	//Timer mode
	
	if(s == TIMER_ACTIVE && timer_state == TIMER_START) begin
        if(timer_sec == 0 && timer_min == 0 && timer_hr == 0) begin
            s <= TIMER_END;  // Timer finished
        end
    end
	 
	 //Timer logic
	 
	 //timer-setting mode
	if (PBbot_rising && s==TIMER_SET_HRS) begin
		//increment internal time hours
		if (timer_hr==23) timer_hr <= 0;
		else timer_hr <= timer_hr + 1;
	end
	else if (PBbot_rising && s==TIMER_SET_MINS) begin
		//increment internal time minutes
		if (timer_min==59) timer_min <= 0;
		else timer_min <= timer_min + 1;
			
	end
	else if (PBbot_rising && s==TIMER_SET_SECS) begin
			//increment internal time seconds
			if(timer_sec==59) timer_sec <= 0;
			else timer_sec <= timer_sec + 1;
			
	end
	
	
	//timer countdown mode
	
	if(s==TIMER_ACTIVE && timer_state == TIMER_START) begin
		
		if (timer_sec == 0) begin
			
			if (timer_min > 0) begin
			
				timer_sec <= 59;
				timer_min <= timer_min - 1;
				
			end
			
			else if (timer_min == 0) begin
			
				if(timer_hr > 0) begin 
					timer_sec <= 59;
					timer_min <= 59;
					timer_hr <= timer_hr - 1;
				end
				else s <= TIMER_END;		//leave timer
				
			end
			
			//else timer_min <= timer_min - 1;	//decrement minutes if minutes are not zero
			
		end
		
		else timer_sec <= timer_sec - 1;		//decrement seconds if seconds are not zero
		
	end
	
	else if(s==TIMER_ACTIVE && timer_state == TIMER_PAUSE) begin
	
		timer_hr <= timer_hr;
		timer_min <= timer_min;
		timer_sec <= timer_sec;
		
	end
	
	else if(s==TIMER_END) begin
	
		timer_hr <= 0;
		timer_min <= 0;
		timer_sec <= 0;
		
	end

	 
	 
	
end

//Stopwatch Mode

//stopwatch states (PBbot) 
localparam SW_START = 2'b00,
			  SW_STOP = 2'b01,
			  SW_RESET = 2'b10;

always @(posedge timer_clk) begin
	
	if(s==STPWTCH_MODE && sw_state==SW_START) begin
	
		if(stopwatch_ms == 99) begin
			stopwatch_ms <= 0;
			
			if(stopwatch_sec==59) begin
				stopwatch_sec <= 0;
				
				if(stopwatch_min==59) stopwatch_min <= 0;
				else stopwatch_min <= stopwatch_min + 1;
			end
			
			else stopwatch_sec <= stopwatch_sec + 1;
		end
		else stopwatch_ms <= stopwatch_ms + 1;
	end
	
	else if(s==STPWTCH_MODE && sw_state==SW_STOP) begin
	
		stopwatch_ms <= stopwatch_ms;
		stopwatch_sec <= stopwatch_sec;
		stopwatch_min <= stopwatch_min;
		
	end
	
	else begin
		stopwatch_ms <= 0;
		stopwatch_sec <= 0;
		stopwatch_min <= 0;
	end

end



always @(*) begin

	//Integer values for BCD conversion
	
		s_ones = time_sec % 10;
		s_tens = time_sec / 10;
	
		m_ones = time_min % 10;
		m_tens = time_min / 10;
	
		h_ones = time_hr % 10;
		h_tens = time_hr / 10;
	
	if(s==TIME_DISPLAY) begin

		s_ones = time_sec % 10;
		s_tens = time_sec / 10;
	
		m_ones = time_min % 10;
		m_tens = time_min / 10;
	
		h_ones = time_hr % 10;
		h_tens = time_hr / 10;
	
	end
	
	//display alarm when in alarm mode
	else if(s==ALRM_MODE || s==ALRM_SET_HRS || s==ALRM_SET_MINS || s==ALRM_SET) begin
	
		s_ones = 0;
		s_tens = 0;
	
		m_ones = alarm_mins % 10;
		m_tens = alarm_mins / 10;
	
		h_ones = alarm_hrs % 10;
		h_tens = alarm_hrs / 10;
	
	end
	
	else if(s==STPWTCH_MODE) begin
	
		s_ones = stopwatch_ms % 10;
		s_tens = stopwatch_ms / 10;
	
		m_ones = stopwatch_sec % 10;
		m_tens = stopwatch_sec / 10;
	
		h_ones = stopwatch_min % 10;
		h_tens = stopwatch_min / 10;
	
	end
	
	else if((s==TIMER_SET_HRS) || (s==TIMER_SET_MINS) || (s==TIMER_SET_SECS) || (s==TIMER_ACTIVE) || (s==TIMER_END)) begin
	
		s_ones = timer_sec % 10;
		s_tens = timer_sec / 10;
	
		m_ones = timer_min % 10;
		m_tens = timer_min / 10;
	
		h_ones = timer_hr % 10;
		h_tens = timer_hr / 10;
		
	end
	
	//flashing logic when setting time, alarm, or timer
	 if (((s == TIME_SET_HRS) || (s == ALRM_SET_HRS) || (s == TIMER_SET_HRS)) && flash_clk) begin
        h_tens = 4'b1100; // blank
        h_ones = 4'b1100; // blank
    end
    if (((s == TIME_SET_MINS) || (s == ALRM_SET_MINS) || (s == TIMER_SET_MINS)) && flash_clk) begin
        m_tens = 4'b1100; // blank
        m_ones = 4'b1100; // blank
    end
    if (((s == TIME_SET_SECS) || (s == TIMER_SET_SECS)) && flash_clk) begin
        s_tens = 4'b1100; // blank
        s_ones = 4'b1100; // blank
    end

end

seven_seg HR_T (.a(hr_tens[0]),.b(hr_tens[1]),.c(hr_tens[2]), .d(hr_tens[3]), .e(hr_tens[4]), .f(hr_tens[5]), .g(hr_tens[6]), .x3(h_tens[3]), .x2(h_tens[2]), .x1(h_tens[1]), .x0(h_tens[0]));
seven_seg HR_O (.a(hr_ones[0]),.b(hr_ones[1]), .c(hr_ones[2]),.d(hr_ones[3]), .e(hr_ones[4]), .f(hr_ones[5]), .g(hr_ones[6]),.x3(h_ones[3]),.x2(h_ones[2]),.x1(h_ones[1]),.x0(h_ones[0]));
seven_seg MIN_T(.a(min_tens[0]), .b(min_tens[1]), .c(min_tens[2]), .d(min_tens[3]), .e(min_tens[4]), .f(min_tens[5]), .g(min_tens[6]),.x3(m_tens[3]),.x2(m_tens[2]),.x1(m_tens[1]),.x0(m_tens[0]));
seven_seg MIN_O(.a(min_ones[0]), .b(min_ones[1]), .c(min_ones[2]), .d(min_ones[3]), .e(min_ones[4]), .f(min_ones[5]), .g(min_ones[6]),.x3(m_ones[3]),.x2(m_ones[2]),.x1(m_ones[1]),.x0(m_ones[0]));
seven_seg SEC_T(.a(sec_tens[0]), .b(sec_tens[1]), .c(sec_tens[2]), .d(sec_tens[3]), .e(sec_tens[4]), .f(sec_tens[5]), .g(sec_tens[6]),.x3(s_tens[3]),.x2(s_tens[2]),.x1(s_tens[1]),.x0(s_tens[0]));
seven_seg SEC_O(.a(sec_ones[0]), .b(sec_ones[1]), .c(sec_ones[2]), .d(sec_ones[3]), .e(sec_ones[4]), .f(sec_ones[5]), .g(sec_ones[6]),.x3(s_ones[3]),.x2(s_ones[2]),.x1(s_ones[1]),.x0(s_ones[0]));

//Led flashing logic

always @(*) begin

	//alarm "ringing"
	if(alarm_hrs==time_hr && alarm_mins==time_min) begin
		if(flash_clk) begin
			
			led0 <= 1;
			led2 <= 1;
			led4 <= 1;
			led6 <= 1;
			led8 <= 1;
			
			//turn other ones off
			led1 <= 0;
			led3 <= 0;
			led5 <= 0;
			led7 <= 0;
			led9 <= 0;
		
		end
		
		else begin
		
			led1 <= 1;
			led3 <= 1;
			led5 <= 1;
			led7 <= 1;
			led9 <= 1;
			
			//turn other ones off
			led0 <= 0;
			led2 <= 0;
			led4 <= 0;
			led6 <= 0;
			led8 <= 0;
		
		end
	end
	
	//timer "ringing" 
	else if (timer_hr==0 && timer_min==0 && timer_sec==0 && s==TIMER_ACTIVE) begin
		if(flash_clk) begin
			
			led0 <= 1;
			led2 <= 1;
			led4 <= 1;
			led6 <= 1;
			led8 <= 1;
			
			//turn other ones off
			led1 <= 0;
			led3 <= 0;
			led5 <= 0;
			led7 <= 0;
			led9 <= 0;
		
		end
		
		else begin
		
			led1 <= 1;
			led3 <= 1;
			led5 <= 1;
			led7 <= 1;
			led9 <= 1;
			
			//turn other ones off
			led0 <= 0;
			led2 <= 0;
			led4 <= 0;
			led6 <= 0;
			led8 <= 0;
		
		end
	end
	
	else begin
		
			led0 <= 0;
			led2 <= 0;
			led4 <= 0;
			led6 <= 0;
			led8 <= 0;
			
			led1 <= 0;
			led3 <= 0;
			led5 <= 0;
			led7 <= 0;
			led9 <= 0;
		
		
	
	end
end

endmodule