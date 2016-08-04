MIDIIn.connectAll;
MIDIClient.init

MIDIdef.cc(\midiCC,{
     arg val, cc, chan;
    [val,cc,chan].postln;
}).free;


MIDIdef.cc(\nano1,{
    arg val;
    Ndef(\play).set(\bitMask, val.linlin(0, 127, 0, 2 ** 14));
}, 0);

MIDIdef.cc(\nano2,{
    arg val;
    Ndef(\play).set(\rate, val + 1);
}, 1);

MIDIdef.cc(\nano3,{
    arg val;
    Ndef(\play).set(\bitshiftL, val.linlin(0,127, 0, 16));
}, 2);

MIDIdef.cc(\nano4,{
    arg val;
    Ndef(\play).set(\bitshiftR, val.linlin(0,127, 0, 16));
}, 3);

MIDIOut

OSCdef(\receiveTrig, {
    arg msg, time;
    ~drums.midiClock;
},'/tr', s.addr);
)

~drums =  MIDIOut.newByName("Pro40", "MIDI");

~drums.start

Pdef(\midiClock, 
    Pbind(
        \type, \midi,
        \midiCmd, \midiClock,
        \dur, 1/24,
        \midiout, ~drums
    )
).quant_(4);

Quarks.gui

Pdef(\midiClock).play

m = MIDIClockOut.new
