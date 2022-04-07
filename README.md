# Minecraft Turtles with Jason
[Jason](http://jason.sourceforge.net/wp/) multi-agent project for controlling Minecraft computercraft turtles.

We use WebSocket to communicate with the turtles.

Authors: Petr Zelina, Jordan Ortiz Thorogood, Haroun Ben Ameur

Computercraft wiki: https://tweaked.cc/<br>
Inspired by https://github.com/LarsChristianK/WebsocketsTurtleMoveTutorial

## Installation
I dont know how propper java dependences should be handled, especcialy for them to work with Jason.

I just put the `.jar` files into the `json-3.0/libs` directory in the JEdit distibution of Jason and it worked.

For the environment to work the following packages are needed:
* `Java-WebSocket` - websocket library for communication with the turtles ([link](https://github.com/TooTallNate/Java-WebSocket))
* `slf4j-api` - reequired by `Java-WebSocket` ([link](https://www.slf4j.org/))
* `json` - for serialization of the communication ([link](https://mvnrepository.com/artifact/org.json/json))


Tested on Minecraft 1.16.5 with forge 36.2.33 and the following mods:
* `cc-tweaked-1.16.5-1.100.4.jar`
* `advancedperipherals-1.16.5-0.7.7.1r.jar`

By default computercraft blocks localhost websockets, it needs to be enabled in the server config. In `.minecraft/saves/<world>/serverconfig/computercraft-server.toml` delete or change this http rule 
```tmol
	[[http.rules]]
		host = "$private"
		action = "deny"
```

Code in `computercraft/lua_turtle` should be present in each turtle you want to connect to Jason.

## TODO
- [x] send commands to specific turtle
- [x] synchronous external actions (`execs`)
- [x] return values from Minecraft
- [x] turtle moveTowards function
- [x] return values to Jason
- [x] Jason `moveTo` goal
- [ ] inventory management
- [ ] block perception
- [ ] chatting
- [ ] turtle filesystem scripts

## Bugs
- [x] investigate empty HashMap
- [x] server port sometimes full after restart


