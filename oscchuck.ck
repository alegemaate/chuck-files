OscIn oin;
OscMsg msg;

JCRev rev;
Gain gain;
DelayL del;

10 => int MAX_OSC;

Wurley piano[MAX_OSC];
ADSR adsr[MAX_OSC];

fun void init() {
    oin.port(7500);
    oin.addAddress("/chuck/oscnote");
    del.delay(10::ms);
    rev.mix(0.8);
    gain.gain(0.6);
    rev => del => gain => dac;
    
        
    for(0 => int i; i < MAX_OSC ; i++) {
        piano[i] => adsr[i] => rev;
        piano[i].gain(0.1);
        adsr[i].sustainLevel(0.0);
        adsr[i].decayTime(1000::ms);
        adsr[i].attackTime(500::ms);
        adsr[i].releaseTime(1000::ms);
    }
}

init();

while (true) {
   oin => now;
  
   while (oin.recv(msg) != 0) {
      msg.getFloat(0) => float frequency;
      msg.getFloat(1) => float velocity;
      msg.getFloat(2) $ int => int index;
      
      if (index < MAX_OSC && index >= 0) {  
          piano[index].freq(frequency);
          piano[index].noteOn(velocity);
          adsr[index].keyOn();
      }
      
      <<< index, frequency, velocity >>>;
   }   
}