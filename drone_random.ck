Std.rand(1);

// Define constants
20 => int MAX_PARTS;

// Create oscillators
SawOsc drones[MAX_PARTS];

// Create lfos
SinOsc lfos[MAX_PARTS];

// Create filters
LPF filters[MAX_PARTS];

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
fun void modulateFilter(float filterBaseFreq, float filterModAmt) {
    while(20::samp => now) {
        // Loop over lfos and update filters
        for(0 => int i; i < MAX_PARTS ; i++) {
            // Calc new frequency
            (lfos[i].last() + 1) * filterModAmt + filterBaseFreq => float f;
            
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
    
    // Reverb
    PRCRev reverb;
    reverb => gain;
    reverb.mix(0.5);
    
    // Adjust gain of drone parts and attach to gain
    for(0 => int i; i < MAX_PARTS ; i++) {
        // Set gain
        drones[i].gain(1.0 / MAX_PARTS);
                
        // Init filter
        filters[i].Q(1);
        filters[i].gain(0.8);
        filters[i].freq(0);
        
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

// Start drone
fun void start() {
    // Init main components
    init();
    
    // Init lfos
    initLfos(0.1, 0.05);

    // Create drone
    createDrone(200.0, 1000.0);
        
    // Spork the modulation
    spork~ modulateFilter(0.0, 100.0);
    
    // Lets do this for a while
    1::day => now;
}

// Start it up
start();

    