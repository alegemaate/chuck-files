// Define constants
40 => int MAX_PARTS;

// Create oscillators
SinOsc drones[MAX_PARTS];

// Create lfos
SinOsc lfos[MAX_PARTS];

// Create pans
Pan2 pans[MAX_PARTS];

// Create filters
LPF filters[MAX_PARTS];

// Create drone
fun void createDrone(float freq, float spread) {
    // Loop over oscs
    for(0 => int i; i < MAX_PARTS ; i++) {
        // Generate detune
        i => float fi;
        freq + Math.sin(fi / MAX_PARTS * Math.PI * 2.0) * spread => float newFreq;
               
        // Adjst freq
        drones[i].freq(newFreq);
    }
}

// Modulate Filter (lfo)
fun void modulateFilter(float filterBaseFreq, float filterModAmt) {
    while(100::samp => now) {
        // Loop over lfos and update filters
        for(0 => int i; i < MAX_PARTS ; i++) {
            // Calc new frequency
            (lfos[i].last() + 1) * filterModAmt + filterBaseFreq => float f;
                         
            // Set it
            filters[i].freq(f);
            
            // Set pan
            pans[i].pan(lfos[i].last());
        }
    }
}

// Modulate Frequency (drones)
fun void modulateFrequency(float drift) {
    Std.rand2f( -drift, drift) => float randDrift;

    while(100::samp => now) {
        // Loop over oscs and update freq
        for(0 => int i; i < MAX_PARTS ; i++) {
            // Adjst freq
            drones[i].freq() + randDrift => float newFreq;
            drones[i].freq(newFreq);
        }
    }
}

// Init drones
fun void init(float rmix, float fgain, float fq) {
    // Connect gain to dac
    Gain lgain => dac.left;
    lgain.gain(0.8);
    Gain rgain => dac.right;
    rgain.gain(0.8);
        
    // Reverb
    PRCRev lreverb;
    lreverb => lgain;
    lreverb.mix(rmix);
    
    PRCRev rreverb;
    rreverb => rgain;
    rreverb.mix(rmix);

    // Adjust gain of drone parts and attach to gain
    for(0 => int i; i < MAX_PARTS ; i++) {
        // Set gain
        drones[i].gain(1.0 / MAX_PARTS);
                
        // Init filter
        filters[i].Q(fq);
        filters[i].gain(fgain);
        filters[i].freq(0);
        
        // Connect drone
        drones[i] => filters[i] => pans[i].left => lreverb;
        drones[i] => filters[i] => pans[i].right => rreverb;
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
    init(0.8, 0.4, 8);
    initLfos(0.05, 0.01);
    createDrone(100.0, 100.0);
    spork~ modulateFilter(0.0, 1000.0);
    spork~ modulateFrequency(0.0);
    1::day => now;
}


// Start it up
start();

    