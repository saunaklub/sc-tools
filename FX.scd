SynthDef(\chorus, {
    arg input, output, depth,
    amp = 1;
    var sig, del, maxDelayTime = 0.1;
    sig = In.ar(input, 1);
    del = DelayC.ar(sig, maxDelayTime, min(depth, 1) * maxDelayTime);
    Out.ar(output, [sig, del] * amp);
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

SynthDef(\flanger2,{
	arg input, output, modFreq, modIndex = 0.01,modIndexBus, delayTime = 0.1;
	var sig = LeakDC.ar(In.ar(input,1));
	var delay = DelayC.ar(sig, 1,delayTime + LinLin.ar(SinOsc.ar(modFreq * In.kr(modIndexBus,1)),-1,1, -1 * modIndex,modIndex));
	Out.ar(output,(sig+delay)!2);
}).add;

SynthDef(\stereoReverb, {
    arg input, output, room = 0.7, damp = 0.3, volume = 1;
    var sig = In.ar(input) * volume;
    Out.ar(output, FreeVerb2.ar(sig,sig,1,room,damp));
}).add;

SynthDef(\pitchShifter, {
    arg rate = 1, window = 7500, output = 0,
    bufNum = 0, delTapInput = 0;

    var deltaT, delay1, delay2, 
    trig, delTap, env1, env2, envelopePhase;

    delTap = In.ar(delTapInput);

    
    rate = (1 - rate);
    trig = Impulse.ar(SampleRate.ir/window * rate);
    deltaT = Phasor.ar(trig, rate, 0, window - 1);
    envelopePhase = (deltaT + 1)/window;

    delay1 = DelTapRd.ar(bufNum, delTap, deltaT * SampleDur.ir, 2);
    env1 = SinOsc.ar(0, mod(pi * envelopePhase, pi));

    delay2 = DelTapRd.ar(bufNum, delTap, mod(window/2 + deltaT, window) * SampleDur.ir, 2);
    env2 = SinOsc.ar(0, mod(0.5pi + (pi * envelopePhase), pi));


    delay1 = delay1 * env1;
    delay2 = delay2 * env2;

    Out.ar(output, delay1 + delay2);
}).add;
