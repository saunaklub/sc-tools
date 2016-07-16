SynthDef(\sineGrain, {
    arg grainDur = 0.025, amp = 1.0,
    bufnum = 0, freq = 440, out = 0,
    pan = 0;

    var sig, env;
    env = EnvGen.ar(Env.sine(grainDur,1), doneAction:2);
    sig = SinOsc.ar(freq);
    sig = sig * env * amp;
    sig = Pan2.ar(sig, pan);
    Out.ar(out, sig);
}).add;

SynthDef(\FMGrain, {
    arg grainDur = 0.025, amp = 1.0,
    bufnum = 0, freq = 440, ratio = 2,
    index = 1, out = 0, pan = 0;

    var car, mod, env;
    env = EnvGen.ar(Env.sine(grainDur,1), doneAction:2);
    mod = SinOsc.ar(freq * ratio, mul: index);
    car = SinOsc.ar(freq, mod.wrap2(2pi));
    car = car * env * amp;
    car = Pan2.ar(car, pan);
    Out.ar(out, car);
}).add;

SynthDef(\bufferGrain, {
    arg grainDur = 0.025, amp = 1.0, rate = 1,
    bufnum = 0, out = 0, pan = 0, syncBus = 0;

    var sig, env;

    env = EnvGen.ar(Env.linen(
        grainDur * 0.03, grainDur * 0.94, grainDur * 0.03, 1, \sine
    ), doneAction:2);
    sig = BufRd.ar(1, bufnum, In.ar(syncBus) * rate, loop: 1);
    
    sig = sig * env * amp;
    sig = Pan2.ar(sig, pan);
    Out.ar(out, sig);
}).add;

SynthDef(\PitchShiftGrain, {
    arg grainDur = 0.025, amp = 1.0,
    rate = 1, windowSize = 7500,
    bufnum = 0, output = 0, pan = 0,
    delTapInput = 0; 
    
    var deltaT, delay1, delay2, 
    trig, delTap, sigEnv, sig, env1, env2, envelopePhase;

    delTap = In.ar(delTapInput);
    
    rate = (1 - rate);
    trig = Impulse.ar(SampleRate.ir/windowSize * rate);
    deltaT = Phasor.ar(trig, rate, 0, windowSize - 1);
    envelopePhase = (deltaT + 1)/windowSize;

    delay1 = DelTapRd.ar(bufnum, delTap, deltaT * SampleDur.ir, 2);
    env1 = SinOsc.ar(0, mod(pi * envelopePhase, pi));

    delay2 = DelTapRd.ar(bufnum, delTap, mod(windowSize/2 + deltaT, windowSize) * SampleDur.ir, 2);
    env2 = SinOsc.ar(0, mod(0.5pi + (pi * envelopePhase), pi));

    delay1 = delay1 * env1;
    delay2 = delay2 * env2;

    sigEnv = EnvGen.ar(Env.linen(
        grainDur * 0.03, grainDur * 0.94, grainDur * 0.03, 1, \sine
    ), doneAction:2);

    sig = (delay1 + delay2) * sigEnv * amp;
    sig = Pan2.ar(sig, pan);
    Out.ar(output, sig);
}).add;
