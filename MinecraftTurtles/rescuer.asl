{ include("rescue.asl") }

role(rescuer).
at(150,150,150).

!start.

+!start : true <-
    .print("Hi, I am ready to rescue!").
