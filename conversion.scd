SynthDef(\a2kLinLin, {
    arg input, output, minIn = -1, maxIn = 1,
    minOut = -1, maxOut = 1;
    var sig = In.ar(input);
    sig = LinLin.ar(sig, 0, 1, minIn, maxIn, minOut, maxOut);
    Out.kr(output, A2K.kr(sig));
}).add;

SynthDef(\a2kLinExp, {
    arg input, output, minIn = -1, maxIn = 1,
    minOut = -1, maxOut = 1;
    var sig = In.ar(input);
    sig = LinExp.ar(sig, 0, 1, minIn, maxIn, minOut, maxOut);
    Out.kr(output, A2K.kr(sig));
}).add;
