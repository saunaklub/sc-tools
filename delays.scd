SynthDef(\recordBuffer, {
    arg input = 1, bufnum = 0, loop = 1, phaseBus = 1, t_sync;
    var sig; 
    sig = SoundIn.ar(input);
    BufWr.ar(sig, bufnum, In.ar(phaseBus), loop);
}).add;

SynthDef(\readBuffer, {
    arg bufnum = 0, loop = 1,
    phaseBus = 1, interpolation = 2, output = 0,
    amp = 1;
    var sig; 
    sig = BufRd.ar(1, bufnum, In.ar(phaseBus), loop, interpolation);
    Out.ar(output, sig * amp);
}).add;

SynthDef(\delTapWr, {
    arg input = 1, output = 0, bufnum = 0;
    var sig; 
    sig = In.ar(input);
    sig = DelTapWr.ar(bufnum, sig);
    Out.ar(output, sig);
}).add;

SynthDef(\delTapWr2, {
    arg input = 0, output = 0, bufnum = 0,
    feedbackInput = 0, amp = 1;
    var sig; 
    sig = In.ar(input);
    sig = sig + InFeedback.ar(feedbackInput);
    sig = DelTapWr.ar(bufnum, sig);
    Out.ar(output, sig * amp);
}).add;

SynthDef(\delTapRd, {
    arg delTapInput = 0, output = 0,
    amp = 1, bufnum = 0, delTime = 1,
    varLagTime = 0.1;
    var sig, delTap; 
    delTap = In.ar(delTapInput);
    sig = DelTapRd.ar(bufnum, delTap,
        VarLag.kr(delTime, varLagTime), 2);
    Out.ar(output, sig * amp);
}).add;

SynthDef(\phasor, {
    arg  minVal, maxVal, output;
    var sig, freq;
    freq = SampleRate.ir/maxVal;
    sig = Phasor.ar(Impulse.ar(freq), 1, minVal, maxVal, minVal);
    Out.ar(output, sig);
}).add;
