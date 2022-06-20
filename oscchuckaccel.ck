OscIn oin;
OscMsg msg;

JCRev rev;
Gain gain;
DelayL del;


SinOsc op1;
SinOsc op2;
SinOsc op3;
SinOsc op4;
Gain feedback;
ADSR adsr;

// Init program
fun void init() {
    oin.port(7500);
    oin.addAddress("/chuck/oscnote/accel");
    oin.addAddress("/chuck/oscnote/tap");
    del.delay(10::ms);
    rev.mix(0.8);
    gain.gain(0.05);
    rev => del => gain => dac;
    
    // Set up OP 2
    op1 => op2 => op3 => rev;
    op1 => op4 => rev;
    op4 => feedback => op4;
    
    // Feedback
    feedback.gain(10000);
    
    // Frequency
    op1.freq(440 * 0.5);
    op2.freq(440 * 1.5);
    op3.freq(440 * 1.49);
    op4.freq(440 * 3.02);
    
    // Output
    op1.gain(990);
    op2.gain(690);
    op3.gain(0.62);
    op4.gain(0.41);
    
    // Adsr
    adsr.sustainLevel(1.0);
    adsr.decayTime(1000::ms);
}

// Accelerometer input
fun void accelInput() {
    while (true) {
        oin => now;
        while (oin.recv(msg) != 0) {
            if (msg.address == "/chuck/oscnote/accel") {
                msg.getFloat(0) => float alpha;
                msg.getFloat(1) => float beta;
                msg.getFloat(2) => float gamma;
                
                
                op1.gain((beta + 180) * 2);
                op2.gain((gamma + 90) * 2);
                // op1.freq(alpha / 10);
                // op2.freq((beta + 180) / 180);
                // op3.freq((gamma + 90) * 10);
                
                op1.freq(alpha * 0.5);
                op2.freq(alpha * 1.5);
                op3.freq(alpha * 1.49);
                op4.freq(alpha * 3.02);

                <<< "Accel:", alpha, beta, gamma >>>;
            }
            
            else if (msg.address == "/chuck/oscnote/tap") {   
                msg.getString(0) => string status;
                                 
                if (status == "on") {
                    adsr.keyOn();
                } else {
                    adsr.keyOff();
                }
                
                <<< "Tapped", status >>>;
            }
        }   
    }
}

// Start    
fun void start() {  
    // Init
    init();
      
    // Spork the modulation 
    spork~ accelInput();
    
    // Lets do this for a while
    1::day => now;
}

// Start it up
start();