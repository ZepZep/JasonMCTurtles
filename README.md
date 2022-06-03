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
* `Java-WebSocket` - websocket library for communication with the turtles (tested with v1.5.2) ([link](https://github.com/TooTallNate/Java-WebSocket), [direct link](https://github.com/TooTallNate/Java-WebSocket/releases/download/v1.5.2/Java-WebSocket-1.5.2.jar))
* `slf4j-api` - reequired by `Java-WebSocket` (tested with v1.7.36) ([link](https://www.slf4j.org/), [direct link](https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.7.36/slf4j-api-1.7.36.jar))
* `json` - for serialization of the communication (tested with v20220320) ([link](https://mvnrepository.com/artifact/org.json/json), [direct link](https://repo1.maven.org/maven2/org/json/json/20220320/json-20220320.jar))


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


## Code structure
The `computercraft/lua_turtle` folder contains all the scripts that the turtles use to connect the WebSocket server and interpret the Jason actions.

The `MinecraftTurtles` directory contains the Jason project.

* `MinecraftTurtles/MinecraftTurtles.mas2j`: main project file
* `MinecraftTurtles/*.asl`: agent definitions
* `MinecraftTurtles/aslapi/*.asl`: common capabilities definitions
* `MinecraftTurtles/env/*.java`: Environment definitions
* `MinecraftTurtles/agent/PriorityAgent.java`: Intention selection function which can use plan priorities. (not used in the end)


## TODO
- [x] send commands to specific turtle
- [x] synchronous external actions (`execs`)
- [x] return values from Minecraft
- [x] turtle moveTowards function
- [x] return values to Jason
- [x] Jason `moveTo` goal
- [x] inventory management
- [x] block perception
- [x] chatting
- [x] turtle filesystem scripts



