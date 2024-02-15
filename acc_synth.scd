// Sound synthesis using accelorometer

// List available serial ports
SerialPort.devices;
// Create a new SerialPort object
~port = SerialPort.new("/dev/cu.usbmodem101", 115200);

(
~xVal;
~yVal;
~zVal;
~nun;

~getValues = Routine.new({
	var buffer = "";
	var prevChar = "";

	{
		var char = ~port.read.asAscii;
		if (char.notNil, {
			// if reading is not properly processed yet, continue
			if ((((buffer == "") && (char.isAlpha == false))) || (buffer == nil), {
				~nun = 1;}, {

			// otherwise, append character to buffer
            buffer = buffer ++ char;

            // set first character
			if (prevChar == "", {
				prevChar = char;
			}, {
					// if not first, do logic checking to see if x, y or z. gyro taken care of in arduino code
			if (((char == $x) && (prevChar.isDecDigit)) || ((char == $y) && (prevChar.isDecDigit)) || ((char == $z) && (prevChar.isDecDigit)), {
                // Extract the value from the buffer
                var value = buffer.copyRange(1, buffer.size).asFloat;
                // Update the corresponding variable based on the prefix character. Map the values so they are better comprehensible
						if (buffer[0] == $x, { ~xVal = (value*10).abs });
						if (buffer[0] == $y, { ~yVal = (value*10).abs });
						if (buffer[0] == $z, { ~zVal = (value*10).abs });

				"x".post; ~xVal.postln;
				"y".post; ~yVal.postln;
				"z".post; ~zVal.postln;

                // Clear the buffer
                buffer = buffer.copyRange(buffer.size, buffer.size+1);
			});

			// Update the previous character
            prevChar = char;
				});
			});
		});
    }.loop;
}).play;
)

// synthesizer starup
s.options.sampleRate = 48000;
s.boot;

// define a saw synthdef
(
SynthDef.new(\saw, {
	arg pitch=440, amp=0;
    var sig;
	sig = Saw.ar(pitch)*amp;
    //sig = RLPF.ar(sig, cutoff.lag(0.02), 0.25, 0.2);
    Out.ar(0, sig);
}).add;
)


// initialize a saw synth
~synth = Synth(\saw);

// control code for the synth based on accelerometer values
(
~control = Routine.new({
	{
		// y acceleration determines pitch
		~synth.set(\pitch, ~yVal.linlin(0, 20, 100, 500));
		// x acceleration determines volume
		~synth.set(\amp, ~xVal.linlin(0, 20, 0, 1));
		0.01.wait;
	}.loop;
}).play;
)

~synth.free;

~port.close;
