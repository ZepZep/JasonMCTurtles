!start.

shouldMove.

+!start : true <-
    !connect;
    !move.

+!connect : not connected <-
    connect.

-!connect : not connected <-
    .print("Failed to connect, will try again 5 seconds.");
    .wait(5000);
    !connect.

+connected : true <-
    .wait(50);
    ?pc(Pc);
    .print("Connected to ", Pc).

-connected : true <-
    .print("Disconnected, dropping everything, trying to reconnect.");
    .drop_all_desires;
    !start.

+!move : shouldMove <-
    execs("turtle.forward()");
    execs("turtle.turnRight()");
    !move.

+!move : not shouldMove <-
    true.
