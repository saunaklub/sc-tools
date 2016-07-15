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
