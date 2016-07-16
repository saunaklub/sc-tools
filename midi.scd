p = "/Users/claudiocabral/SuperCollider/"
(p++"SynthMap.scd").load;

if (~midiBus == nil) {~midiBus = Array.fill(128,Bus.control(s,1))};

if (~midi == nil) {~midi = ()};

Environment.push(~midi);

currentEnvironment
~ccmap = Array.newClear(127);

~map = {
    arg cc, synthkey, minval, maxval;
    ~midi.ccmap[cc.asInteger] = [synthkey.asSymbol, minval, maxval];
};

Environment.pop;
~midi.map.value(1,\banana,0,0)
MIDIIn.connectAll;
// MIDIClient.restart
MIDIdef.cc(\midiCC,{
    // arg val, cc, chan;
    [val/127,cc,chan].postln;
    ~midiBus[cc].set(val/127);
});

MIDIdef.noteOn(\noteIn, {
    arg vel = 0, nn = 0;
    // [nn,channel].postln;
    // ~midiKeyboard[nn] =Synth(\FM, [\freq, nn.midicps]);
});


MIDIdef.noteOff(\noteIn, {
    arg nn = 0, channel = 0;
    //[nn,channel].postln;

    ~midiKeyboard[nn].set(\gate,0);
    ~midiKeyboard[nn] = nil;
});
