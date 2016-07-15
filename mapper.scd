// this file intends to send OSC messages to other applications

~receivers = ~receiver ? IdentityDictionary();
~messagesToSend = ~messagesToSend ? Array();
~rate =  ~rate ? (1/60);

CmdPeriod.add(~receivers);
CmdPeriod.add(~messagesToSend);

~makeReceiver = {
   arg name, ip = "localhost", port = 6666; 
   if(~receivers.includesKey(name.asSymbol) == false, {
       ~receivers = ~receivers.add(name.asSymbol, NetAddr(ip.asString, port));
   }, {
       "Receiver already exists!"
   });
};

~getBusValue = {

}

~sendMessage = {
    arg receiver, address, message;

    ~receivers[receiver.asSymbol].sendMsg(address.asString, message);
};

~addMessage = {
    arg receiver, address, message;
    var array = [receiver.AsSymbol, adress.asString, message];

    if(~messagesToSend.indexOf(array) == nil, {
        ~messagesToSend = ~messagesToSend.add(array);
    }, {
        "Message already exists!"
    });
};

~sendMessages = Task({
    loop{
        ~messagesToSend.do({
            arg item;
            ~sendMessage.value(item);
        })
        ~rate.wait;
    }
});

~getBusValue = {
    arg synthName, busName = "output", offset;
    var value, name;
    name = synthName ++ busName;
    if(~bus[name.asSymbol] != nil) {
        var subBus = ~bus[name.asSymbol].subBus(offset, 1);
        subBus.get({
            arg val;
            value = val;
        })
    };
};
