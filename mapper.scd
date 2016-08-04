// this file intends to send OSC messages to other applications
"functions.scd".loadRelative;
"conversion.scd".loadRelative;

~receivers = ~receiver ? IdentityDictionary();
~conversors = ~conversors ? IdentityDictionary();
~valuesToSend = ~valuesToSend ? Array();
~rate =  ~rate ? (1/60);

~clearMappers  = {
    ~receivers = IdentityDictionary();
    ~conversors = IdentityDictionary();
    ~valuesToSend = Array();
};

CmdPeriod.add(~clearMappers);

~makeReceiver = {
   arg name, ip = "localhost", port = 6666; 
   if(~receivers.includesKey(name) == false, {
       ~receivers.put(name.asSymbol, NetAddr(ip.asString, port));
   }, {
       "Receiver already exists!"
   });
};

~addValue = {
    arg receiver, address, synthName,
    busName = "output", offset = 0,
    inMin = -1, inMax = 1, outMin = -1, outMax = 1,
    curve = \linlin;

    var array, index, count;

    ~makeConversor.value(
        synthName, busName, offset,
        inMin, inMax, outMin, outMax, curve
    );

    array = [
        receiver.asSymbol, address.asString, synthName.asSymbol,
        busName.asSymbol, offset
    ];

    count = 0;

    ~valuesToSend.do{
        arg item;
        if(item == array, {
            count = count + 1;
        });
    };
    if (count == 0, {
        ~valuesToSend = ~valuesToSend.add(array);
    }, {
        "Message already exists!"
    });
};

~removeValue = {
    arg receiver, address, synthName,
    busName = "output", offset = 0;
    var name, array;

    name = synthName ++ busName;

    array = [
        receiver.asSymbol, address.asString, synthName.asSymbol,
        busName.asSymbol, offset;
    ];

    ~valuesToSend.do{
        arg item, i;
        if (item == array) {
            ~valuesToSend.takeAt(i);
            ~conversors[name.asSymbol].free;
            ~conversors.put(name.asSymbol, nil);
            ~controlBus[name.asSymbol].free;
            ~controlBus.put(name.asSymbol, nil);
        };
    };
};

~sendValue = {
    arg receiver, address,
    synthName, busName = "output", offset;
    var return, name;

    name = synthName ++ busName;

    if(~controlBus[name.asSymbol] != nil) {
        ~controlBus[name.asSymbol].get({
            arg val;
            ~receivers[receiver.asSymbol].sendMsg(address, val);
        });
    };
};

~sendValues = Task({
    loop{
        ~valuesToSend.do({
            arg item;
            ~sendValue.value(
                item[0], item[1],
                item[2], item[3],
                item[4]
        );
        });
        ~rate.wait;
    }
});
