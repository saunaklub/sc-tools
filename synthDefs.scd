// SYNTH DEFS

SynthDef(\click, {
    arg bpm = 0.8, volume = 0.2, output;
    Out.ar(output,{WhiteNoise.ar(volume) * EnvGen.ar(Env.perc(0.001,0.01),Impulse.ar(bpm/60))});
};).add;

SynthDef(\audioInput, {
    arg hardwareInput = 0, output = 0, volume = 1.0;
    Out.ar(output,LeakDC.ar(SoundIn.ar(hardwareInput, volume)));
}).add;

~makeCableDef = {
    arg numChannels = 1;
    SynthDef(\cable ++ numChannels.asSymbol, {
        arg input, output, volume = 1;
        Out.ar(output, In.ar(input, numChannels) * volume);
    }).add;
};

20.do{
    arg i;
    ~makeCableDef.value(i+1);
};

SynthDef(\stereoReverb, {
    arg input, output, room = 0.7, damp = 0.3, volume = 1;
    var sig = In.ar(input) * volume;
    Out.ar(output, FreeVerb2.ar(sig,sig,1,room,damp));
}).add;

SynthDef(\distortion, {
    arg input, output, volume = 1, amount = 0.99, hpFreq = 300, midEqFreq = 120;
    var amCoef, sig;
    sig = In.ar(input, 1);
    sig = HPF.ar(sig, hpFreq);
    amCoef= 2*amount/(1-amount);
    sig = MidEQ.ar(LPF.ar((1+amCoef)*sig/(1+(amCoef*sig.abs)), 3900)*0.5, midEqFreq, 0.7, 10);
    Out.ar(output, sig * volume);
}).add;

SynthDef(\flanger, {
    arg input, output, delayTime = 0.5, rate = 0.1, depth = 0.1;
    var delayL, delayR, sig;

    sig = In.ar(input, 1);

    delayL = DelayC.ar(sig, 1,
        (delayTime + SinOsc.ar(rate,0,depth));
    );
    delayR = DelayC.ar(sig, 1,
        (delayTime + SinOsc.ar(rate,pi,depth));
    );
    Out.ar(output, (delayL + delayR)/2);
}).add;

SynthDef(\FM, {
    arg freq = 440, ratio = 2, atk=0.01, rel=10, 
    pos = 0, amp = 0.1, output = 0, index = 1;
    var sig, mod,  env;
    mod = SinOsc.ar(freq * ratio, mul:index);
    sig = SinOsc.ar(freq, mod)!2;
    env = EnvGen.ar(Env (times:[atk,rel]),doneAction:2);
    sig = Pan2.ar(sig*amp*env, pos)*0.5;
    Out.ar(output,sig);
}).add;

SynthDef(\drone, {
    arg freq = 100, rate = 0.5, index = 5, volume = 0.0,
    output = 0, amount=0.99,
    vibratoCoef=20, vibratoFreq=0.03;
    var modulator, modulatorFrequency, carrier, amCoef;

    freq = freq + SinOsc.ar(0.05, mul:freq/20);
    modulatorFrequency = freq * rate;
    modulator = SinOsc.ar(modulatorFrequency, mul:index);
    carrier = SinOsc.ar(freq, modulator.mod(2pi)) * 0.2 * volume;
    amCoef= 2*amount/(1-amount);
    carrier = MidEQ.ar(LPF.ar((1+amCoef)*carrier/(1+(amCoef*carrier.abs)), 3900)
    * 0.5, 120, 0.7, 10);
    carrier = carrier * volume;
    Out.ar(output, {carrier}!2);
}).add;

SynthDef(\noise, {
    arg output = 0, sinOsc1Mul = 300, sinOsc1Add = 35,
    sawFreq = 1, sawMul = 100, baseModFreq = 100,
    modWidthFreq = 50, baseFreq = 75, amp = 0.3,
    baseDelay = 1.0, freq = 0.5, depth = 0.01, mul = 1, 
    add = 0, volume = 0;
    var sig, env, flangerCount;
    var lfpulse, lfsaw;
    var sinosc1, sinosc2, sinosc3;

    sinosc1 = SinOsc.ar(300, 0, sinOsc1Mul, sinOsc1Add);
    sinosc2 = SinOsc.ar(sinosc1, mul:0.5, add:0.5);

    lfsaw = LFSaw.ar(sawFreq, 0, sawMul, 1);

    sinosc3 = SinOsc.ar(lfsaw, mul:0.5, add:0.5);

    lfpulse = LFPulse.ar(
        baseModFreq, width:sinosc3,
        mul:modWidthFreq
    );

    sig = LFPulse.ar( baseFreq + lfpulse, width:sinosc2, mul:2, add:-1) * amp;

    env = EnvGen.ar(Env.adsr(0.01, 0, 1, 0.1));

    sig * env;

    flangerCount = 7;

    sig = sig!(flangerCount);
    sig.do {
        arg harmonic, index;
        if(index > 0, {
            sig[index] = DelayC.ar(harmonic, 5, baseDelay +
                SinOsc.ar(freq, index/flangerCount, mul:0.5 ,add:0.5) *
                depth * index/flangerCount, mul,add
            );
        });
    };
    sig = LeakDC.ar(sig);
    sig = Splay.ar(sig) * volume;
    Out.ar(output, sig);
}).add;
