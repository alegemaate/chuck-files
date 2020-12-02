// Chuck MIDI test 

TriOsc t => dac; 

// number of the device to open (see: chuck --probe)

0 => int device; // MIDI port 
// get command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// the midi event

MidiIn min;

// the message for retrieving data

MidiMsg msg;



// open the device

if( !min.open( device ) ) me.exit();



// print out device that was opened

<<< "MIDI device:", min.num(), " -> ", min.name() >>>;



// infinite time-loop

while( true )
    
    {
        
        // wait on the event 'min'
        
        min => now;
        
        
        
        // get the message(s)
        
        while( min.recv(msg) )
            
            {
                msg.data2 * 100 => t.freq; // mapping works here but not in other patch.
                // print out midi message
                
                <<< msg.data1, msg.data2, msg.data3 >>>;
                
            }
            
        }
        
