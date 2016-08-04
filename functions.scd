// UTILITY FUNCTIONS

if(~synth == nil, ~synth = IdentityDictionary());
if(~cable == nil, ~cable = IdentityDictionary());
if(~buffer == nil, ~buffer = IdentityDictionary());
if(~bus == nil, ~bus = IdentityDictionary());
if(~controlBus == nil, ~controlBus = IdentityDictionary());
if(~group == nil, ~group = IdentityDictionary());

~clearUtilityDictionaries = {
    ~synth = IdentityDictionary();
    ~cable = IdentityDictionary();
    ~buffer = IdentityDictionary();
    ~bus = IdentityDictionary();
    ~controlBus = IdentityDictionary();
    ~group = IdentityDictionary();
};

CmdPeriod.add(~clearUtilityDictionaries);

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

~getParentGroup = {
    arg node;
    var group = node.group;
    if(group != s.defaultGroup, {
        ~getParentGroup.value(group);
    }, {
        node;
    });
};

~makeGroup = {
    arg name, target = nil, addAction = \addToTail;
    if(~group[name.asSymbol] == nil, {
        ~group.put(name.asSymbol, Group(target, addAction));
    }, {
        "Group already exists!";
    });
};

~makeBuffer = {
    arg name, seconds, numChannels;

    if(~buffer.at(name.asSymbol) == nil,
    {
        ~buffer.put(name.asSymbol,
            Buffer.alloc(s, seconds * s.sampleRate, numChannels);
        )
    },{
        "Buffer already exists!".postln;
    }
)};

~makeBus = {
    arg name, numChannels, rate = \audio;
    
    if (rate == \audio, {
        if (~bus[name.asSymbol] == nil, {
            ~bus.put(name.asSymbol, Bus.audio(s, max(numChannels,1)));
        }, {
            "Bus already exits!"
        });
    }, {

        if (~controlBus[name.asSymbol] == nil, {
            ~controlBus.put(name.asSymbol, Bus.control(s, max(numChannels,1)));
        }, {
            "Bus already exits!"
        });
    });
};

~makeSynth = {
    arg name, synthDef, arguments,
    numInputs = 0, numOutputs = 1,
    target = nil, addAction = \addToTail,
    extraBusses;

    var inputName = name ++ "input",
    outputName = name ++ "output";


    if (~synth[name.asSymbol] == nil, {
        ~synth.put(name.asSymbol, Synth(synthDef.asSymbol, arguments.asArray,
            target: target, addAction: addAction
        ));
    },
    {"Synth already exists!";});

    ~makeBus.value(inputName, numInputs);
    ~synth[name.asSymbol].set(\input, ~bus[inputName.asSymbol]);

    ~makeBus.value(outputName, numOutputs);
    ~synth[name.asSymbol].set(\output, ~bus[outputName.asSymbol]);

    extraBusses.asArray.do{
        arg item, i;
        var busName = name ++ item.asSymbol;
        ~makeBus.value(busName, 1);
        ~synth[name.asSymbol].set(item.asSymbol, ~bus[busName.asSymbol]);

    }
};

~promiseSynth = {
    arg name, numInputs = 0, numOutputs = 1,
    extraBusses;

    var inputName = name ++ "input",
    outputName = name ++ "output";

    ~makeBus.value(inputName, numInputs);
    ~makeBus.value(outputName, numOutputs);

    extraBusses.asArray.do{
        arg item, i;
        var busName = name ++ item.asSymbol;
        ~bus.put(busName.asSymbol, Bus.audio(s, 1));
    }
};

~makeConversor = {
    arg synthName, busName = \output, offset = 0,
    inMin = -1, inMax = 1, outMin = -1, outMax = 1,
    curve = \linlin;

    var name = synthName ++ busName;
    
    if (~conversors[name.asSymbol] == nil, {
        ~makeBus.value(name, 1, \control);

        ~conversors.put(name.asSymbol, Synth((\a2k ++ curve).asSymbol,
            [
                \input, ~bus[name.asSymbol].subBus(offset, 1),
                \output, ~controlBus[name.asSymbol],
                \inMin, inMin,
                \inMax, inMax,
                \outMin, outMin,
                \outMax, outMax
            ],
            target: ~synth[synthName.asSymbol], addAction: \addAfter
        ));
    },
    {"Conversor already exists!".postln;});
};

~makeCable = {
    arg name, arguments, numChannels = 1, target = nil, addAction = \addToHead;

    if (~cable[name.asSymbol] == nil,
    {
        ~cable.put(name.asSymbol,
            Synth(\cable ++ numChannels.asSymbol,
                arguments.asArray, target: target,
                addAction: addAction.asSymbol
            )
        );
    },
    {"Cable already exists!";}
);
};

~connect = {
    arg from, to, numChannels = 1, inputName = \input,
    outputName = \output, getSubBus = false, offset = 0;

    var cableName = from.asSymbol ++ "->" ++ to.asSymbol ++
    inputName.asSymbol,
    cableGroup = from.asSymbol ++ "Cable",
    input = from.asSymbol ++ outputName.asSymbol,
    output = to.asSymbol ++ inputName.asSymbol, bus;

    if(getSubBus,
        bus = ~bus[input.asSymbol].subBus(offset, numChannels),
        bus = ~bus[input.asSymbol]
    );


    if(~group[from.asSymbol] == nil) {
        ~makeGroup.value(from.asSymbol);
        if(~synth[from.asSymbol] != nil) {
            ~synth[from.asSymbol].moveToHead(~group[from.asSymbol]);
        };
    };

    if (~group[cableGroup.asSymbol] == nil) {
        ~makeGroup.value(cableGroup.asSymbol,
            ~group[from.asSymbol], \addToTail
        );
    };

    if(to.isInteger, {
        ~makeCable.value(cableName.asSymbol, [
            \input, bus,
            \output, to], numChannels,
            target: ~group[cableGroup.asSymbol],
            addAction: \addToTail
        );

    }, {
        ~makeCable.value(cableName.asSymbol, [
            \input, bus,
            \output, ~bus[output.asSymbol]
        ], numChannels,
        target: ~group[cableGroup.asSymbol],
        addAction: \addToTail);

        if (~synth[to.asSymbol] != nil, {
            var parentGroup;
            parentGroup = ~getParentGroup.value(
                ~synth[to.asSymbol]
            );
            parentGroup.moveAfter(
                ~group[from.asSymbol]);
            }, "reserved space")
        }
    );
};


~disconnect = {
    arg from, to, inputName = "input";
    var cableName = from ++ "->" ++ to ++ inputName;
    ~cable[cableName.asSymbol].free;
    ~cable.put(cableName.asSymbol, nil);
};

~checkConnection = {
    arg input, output;
    var cablename;

    ~synth[input.asSymbol].get(\output, {
        arg i;
        (input.asString ++ "'s output is " ++ i.asString).postln;
    });
    ~synth[output.asSymbol].get(\input, {
        arg i;
        (output.asString ++ "'s input is " ++ i.asString).postln;
    });
    cablename = input.asSymbol ++ "->" ++ output.asSymbol;

    if(~cable.at(cablename.asSymbol) != nil) {
        ~cable.at(cablename.asSymbol).getn(0, 2, {
            arg i;
            (input.asString ++ "->" ++ output.asString ++ " is connecting " ++
                i[0].asString ++ " to " ++ i[1].asString).postln;
            }
        );
    }
}
