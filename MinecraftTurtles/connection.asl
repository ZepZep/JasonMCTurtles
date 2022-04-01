/* Plans for staying connected to MC turtles */

+!connect : not connected <-
    connect;
    .wait(10);
    ?pc(Pc);
    .print("Connected to ", Pc);
    locate.

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
