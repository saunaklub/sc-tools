SynthDef(\envelopeFollower,{
    arg input, output, minThresh = 0.1, maxThresh = 0.6;

    var sig = In.ar(input);
    var amp = Peak.kr(sig,Impulse.kr(10));

    var trigger = Changed.kr(Schmidt.kr(amp,minThresh,maxThresh));
    SendTrig.kr(amp, 0, trigger);
    Out.kr(output, amp);
}).add;

SynthDef(\lmhEnvFollower, {
    arg input, output, lowFreq = 100, midFreq = 1000,
    highFreq = 5000, rq = 0.5, decay = 0.5;

    var sig, outArray,
    low, mid, high;

    sig = In.ar(input);

    low = LPF.ar(sig, lowFreq);
    mid = BPF.ar(sig, midFreq, rq);
    high = HPF.ar(sig, highFreq);
    low = PeakFollower.kr(low, decay);
    mid = PeakFollower.kr(mid, decay);
    high = PeakFollower.kr(high, decay);

    Out.kr(output, [low, mid, high]);
}).add;

SynthDef(\pitchDetection, {
    arg input = 0;
    var sig = In.ar(input);
    sig = Pitch.kr(sig);
    SendTrig.kr(sig[1], 0, sig[0]);
}).add;
