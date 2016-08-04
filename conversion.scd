SynthDef(\a2klinlin, {
    arg input, output, inMin = -1, inMax = 1,
    outMin = -1, outMax = 1;
    var sig = In.ar(input);
    sig = LinLin.ar(sig, inMin, inMax, outMin, outMax);
    Out.kr(output, A2K.kr(sig));
}).add;

SynthDef(\a2klinexp, {
    arg input, output, minIn = -1, maxIn = 1,
    minOut = -1, maxOut = 1;
    var sig = In.ar(input);
    sig = LinExp.ar(sig, minIn, maxIn, minOut, maxOut);
    Out.kr(output, A2K.kr(sig));
}).add;
