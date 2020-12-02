// Bubbles (Sine)
fun void start() {
    init(0.2, 0.5, 200);
    initLfos(1, 0.1);
    createDrone(100.0, 100.0);
    spork~ modulateFilter(100.0, 1000.0);
    spork~ modulateFrequency(0);
    1::day => now;
}

// Bell (Sine)
fun void start() {
    init(0.2, 0.5, 300);
    initLfos(0.01, 0);
    createDrone(100.0, 100.0);
    spork~ modulateFilter(1000.0, 10.0);
    spork~ modulateFrequency(0);
    1::day => now;
}

// Better bubbles (Sine)
fun void start() {
    init(0.0, 0.1, 40);
    initLfos(0.4, 0.1);
    createDrone(100.0, 10.0);
    spork~ modulateFilter(0.0, 1000.0);
    spork~ modulateFrequency(0);
    1::day => now;
}

// Rising (Saw)
fun void start() {
    init(0.5, 0.4, 5);
    initLfos(0.005, 0.01);
    createDrone(1000.0, 1000.0);
    spork~ modulateFilter(100.0, 50.0);
    spork~ modulateFrequency(0.01);
    1::day => now;
}

// Boring (Saw)
fun void start() {
    init(0.5, 0.8, 1);
    initLfos(0.05, 0.01);
    createDrone(1000.0, 10000.0);
    spork~ modulateFilter(100.0, 200.0);
    spork~ modulateFrequency(0.0);
    1::day => now;
}


// Scary (Saw)
fun void start() {
    init(0.8, 0.8, 10);
    initLfos(0.05, 0.1);
    createDrone(100.0, 100.0);
    spork~ modulateFilter(10.0, 20.0);
    spork~ modulateFrequency(0.0);
    1::day => now;
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


