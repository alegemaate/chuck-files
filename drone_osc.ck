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
OscIn oin;
OscMsg msg;

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
    gain.gain(0.9);
    
    // Setup reverb
    reverb => gain;
    reverb.mix(0.0);
    
    // Setups OSC
    oin.port(7500);
    oin.addAddress("/chuck/oscnote");
    
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
        oin => now;
        // Get the message(s)
        while (oin.recv(msg) != 0) {
            msg.getFloat(0) => float param1;
            msg.getFloat(1) => float param2;
            msg.getFloat(2) => float param3;
            
            createDrone(param1 / 10, param2);
            
            <<< param1, param2 >>>;
        }
}

// Start drone
fun void start() {    
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

    