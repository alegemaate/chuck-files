Std.srand(100);

// Define constants
40 => int MAX_PARTS;

// Create oscillators
SawOsc drones[MAX_PARTS];

// Create lfos
SinOsc lfos[MAX_PARTS];

// Create filters
LPF filters[MAX_PARTS];

// The midi event
MidiIn min;

// The message for retrieving dat
MidiMsg msg;

// Reverb
PRCRev reverb;

// Setup osc spread
100 => int oscSpread;

// Last note
400.0 => float lastNote;

// Filter params
100.0 => float filterFreq;
100.0 => float filterMod;
0.00 => float lfoSpread;
0.05 => float lfoFreq;

// Create drone
fun void createDrone(float freq, float spread) {
    // Loop over oscs
    for(0 => int i; i < MAX_PARTS ; i++) {
        // Generate detune
        Std.rand2f(freq - spread, freq + spread) => float newFreq;
        
        // Adjst freq
        drones[i].freq(newFreq);
    }
}

// Modulate Filter (lfo)
fun void modulateFilter() {
    while(20::samp => now) {
        // Loop over lfos and update filters
        for(0 => int i; i < MAX_PARTS ; i++) {
            // Calc new frequency
            (lfos[i].last() + 1) * filterMod + filterFreq => float f;
            
            // Set it
            filters[i].freq(f);
        }
    }
}

// Init drones
fun void init() {
    // Connect gain to dac
    Gain gain => dac;
    gain.gain(0.8);
    
    // Setup reverb
    reverb => gain;
    reverb.mix(0.0);
    
    // Adjust gain of drone parts and attach to gain
    for(0 => int i; i < MAX_PARTS ; i++) {
        // Set gain
        drones[i].gain(1.0 / MAX_PARTS);
                
        // Init filter
        filters[i].Q(1);
        filters[i].gain(0.8);
        filters[i].freq(filterFreq);
        
        // Connect drone to filter
        drones[i] => filters[i] => reverb;
    } 
}

// Init lfos
fun void initLfos(float lfoFreq, float lfoSpread) {
    // Setup filter and lfo per osc
    for(0 => int i; i < MAX_PARTS; i++) {
        // Get that outta here
        lfos[i] => blackhole;
        
        // Set freq depending on spread
        lfos[i].freq(lfoFreq + (lfoSpread * i));
    }
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
    while(100::ms => now) {
        while(min.recv(msg)) {
            <<< msg.data1, msg.data2, msg.data3 >>>;
            
            mapMidi(msg.data3) => float fd3;
            
            // CC
            if(msg.data1 == 176) {
                // Verb
                if (msg.data2 == 73) {
                    reverb.mix(fd3);
                }
                // Filter Q
                else if (msg.data2 == 9) {
                    for(0 => int i; i < MAX_PARTS ; i++) {
                        filters[i].Q(fd3 * 20.0);
                    }
                }
                // Osc spread
                else if (msg.data2 == 7) {
                    msg.data3 * 10 => oscSpread;
                    createDrone(lastNote, oscSpread);
                }
                // Filter frequency
                else if (msg.data2 == 72) {
                    msg.data3 * 10 => filterFreq;
                    <<< filterFreq >>>;
                }
                // Filter modulation
                else if (msg.data2 == 74) {
                    msg.data3 * 10 => filterMod;
                    <<< filterMod >>>;
                }
                // Filter lfo speed
                else if (msg.data2 == 71) {
                    fd3 * 10 => lfoFreq;
                    initLfos(lfoFreq, lfoSpread);
                }
                // Filter spread
                else if (msg.data2 == 14) {
                    fd3 => lfoSpread;
                    initLfos(lfoFreq, lfoSpread);
                }
            }
            // Midi note in
            else if(msg.data1 == 144 && msg.data3 > 0) {
                Std.mtof(msg.data2) => lastNote;
                createDrone(lastNote, oscSpread);
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
    
    // Init lfos
    initLfos(lfoFreq, lfoSpread);

    // Create drone
    createDrone(lastNote, oscSpread);
        
    // Spork the modulation
    spork~ modulateFilter();
    
    // Spork the midi
    spork~ runMidi();
    
    // Lets do this for a while
    1::day => now;
}

// Start it up
start();

    