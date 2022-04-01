# Minecraft Turtles
Jason multi-agent project for controlling Minecraft computercraft turtles.

We use WebSocket to communicate with the turtles.

Authors: Petr Zelina, Jordan Ortiz Thorogood, Haroun Ben Ameur

Computercraft wiki: https://tweaked.cc/<br>
Inspired by https://github.com/LarsChristianK/WebsocketsTurtleMoveTutorial


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
