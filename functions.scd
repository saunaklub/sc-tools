// UTILITY FUNCTIONS

if(~synth == nil, ~synth = IdentityDictionary());
if(~buffer == nil, ~buffer = IdentityDictionary());
if(~bus == nil, ~bus = IdentityDictionary());
if(~group == nil, ~group = IdentityDictionary());

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

~makeSynth = {
    arg name, synthDef, arguments, 
    numInputs = 0, numOutputs = 1,
    target = nil, addAction = \addToTail;

    var inputName = name ++ "Input",
    outputName = name ++ "Output";


    if (~synth[name.asSymbol] == nil, {
        ~synth.put(name.asSymbol, Synth(synthDef.asSymbol, arguments.asArray, target: target, addAction: addAction));
    },
    {"Synth already exists!";});

    if (~bus[inputName.asSymbol] == nil && (numInputs > 0)) {
        ~bus.put(inputName.asSymbol, Bus.audio(s, numInputs));
        ~synth[name.asSymbol].set(\input, ~bus[inputName.asSymbol]);
    };

    if (~bus[outputName.asSymbol] == nil && (numOutputs > 0)) {
        ~bus.put(outputName.asSymbol, Bus.audio(s, numOutputs));
        ~synth[name.asSymbol].set(\output, ~bus[outputName.asSymbol]);
    };
};


~promiseSynth = {
    arg name, numInputs = 0, numOutputs = 1;

    var inputName = name ++ "Input",
    outputName = name ++ "Output";

    if (~bus[inputName.asSymbol] == nil && numInputs > 0) {
        ~bus.put(inputName.asSymbol, Bus.audio(s, numInputs));
    };

    if (~bus[outputName.asSymbol] == nil && numOutputs > 0) {
        ~bus.put(outputName.asSymbol, Bus.audio(s, numOutputs));
    };
};

~makeCable = {
    arg name, arguments, numChannels = 1, target = nil, addAction = \addToHead;

    if (~synth[name.asSymbol] == nil, 
    {
        ~synth.put(name.asSymbol, 
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
    arg from, to, numChannels = 1;

    var cableName = from.asSymbol ++ "->" ++ to.asSymbol,
    cableGroup = from.asSymbol ++ "Cable",
    inputName = from.asSymbol ++ "Output",
    outputName = to.asSymbol ++ "Input";

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
            \input, ~bus[inputName.asSymbol],
            \output, to], numChannels, 
            target: ~group[cableGroup.asSymbol],
            addAction: \addToTail
        );

    }, {
        ~makeCable.value(cableName.asSymbol, [
            \input, ~bus[inputName.asSymbol],
            \output, ~bus[outputName.asSymbol]
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
    arg from, to;
    var cableName = from ++ "->" ++ to;
    ~synth[cableName.asSymbol].free;
    ~synth.put(cableName.asSymbol, nil);
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

    if(~synth.at(cablename.asSymbol) != nil) {
        ~synth.at(cablename.asSymbol).getn(0, 2, {
            arg i; 
            (input.asString ++ "->" ++ output.asString ++ " is connecting " ++
                i[0].asString ++ " to " ++ i[1].asString).postln;
            }
        );
    }
}
