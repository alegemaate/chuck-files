Std.srand(100);

// Create oscillators
SinOsc drones[3];

// Create filter
LPF filter;

// Create env
ADSR envelope;

// The midi event
MidiIn min;

// The message for retrieving dat
MidiMsg msg;

// Reverb
JCRev reverb;

// Chorus
Chorus chorus;

// Setup params
100000.0 => float filterFreq;

fun void initDrone(float base) {
    // Setup drone gain
    drones[0].gain(0.3);
    drones[0].freq(Std.mtof(base));
    
    drones[1].gain(0.3);
    drones[1].freq(Std.mtof(base + 0.2));

    drones[2].gain(0.3);
    drones[2].freq(Std.mtof(base + 5.2));
}

// Init drones
fun void init() {
    // Connect gain to dac
    Gain gain;
    gain.gain(0.5);
    gain => dac;

    // Setup reverb
    reverb.mix(0.4);
    reverb => gain;

    // Setup chorus
    chorus.mix(1.0);
    chorus.modFreq(0.08);
    chorus.modDepth(0.05);
    chorus => reverb;

    // Setup LPF
    filter.Q(1);
    filter.gain(0.5);
    filter.freq(filterFreq);
    filter => chorus;
        
    // ADSR
    envelope.attackTime(1000::ms);
    envelope.releaseTime(1000::ms);
    envelope => filter;

    // Attatch drones to filter
    drones[0] => envelope;
    drones[1] => envelope;
    drones[2] => envelope;   
}

// Map midi to 0-1
fun float mapMidi(int val) {
    val => float fval;
    return fval / 127.0;
}

// Run midi commands
fun void runMidi() {
    min => now;

    // Get the message(s)
    while(10::ms => now) {
        while(min.recv(msg)) {
            <<< msg.data1, msg.data2, msg.data3 >>>;
            
            mapMidi(msg.data3) => float fd3;
            
            // CC
            if(msg.data1 == 176) {
                // Verb
                if (msg.data2 == 73) {
                    reverb.mix(fd3);
                }

                // 9 12 72 74 71 14 17
            }

            // Midi note in
            else if(msg.data1 == 144 && msg.data3 > 0) {
                initDrone(msg.data2);
                envelope.keyOn();
                
            } else if(msg.data1 == 144 && msg.data3 == 0) { 
                envelope.keyOff();
            }
        }
    }
}



// Start drone
fun void start() {    
    // Check for midi
    if(!min.open(0)) {
        <<< "Warning, could not open midi. Starting anyways" >>>;
    } else {
        <<< "MIDI device:", min.num(), " -> ", min.name() >>>;
    }
    
    // Init main components
    init();
    
    // Spork the midi
    spork~ runMidi();
    
    // Lets do this for a while
    1::day => now;
}



// Start it up
start();



