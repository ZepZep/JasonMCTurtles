#!/bin/bash

for target in turtles2/*; do
#     rm $target/inv.lua $target/json.lua $target/startup.lua $target/tst.lua
    ln -s /home/peta/skola/MASD/MinecraftTurtles/computercraft/lua_turtle/* $target/
done
