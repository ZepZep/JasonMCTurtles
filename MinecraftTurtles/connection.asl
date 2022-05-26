/* Plans for staying connected to MC turtles */

+!connect : true <- !connect("0").

+!connect(Channel) : not connected <-
    connect(Channel);
    .wait(10);
    locate.

-!connect(Channel) : not connected <-
    .print("Failed to connect, will try again 5 seconds.");
    .wait(5000);
    !connect(Channel).
    
-!connect(Channel) : true <-
    .print("Failed to connect while being connected").

+connected : true <-
    .wait(50);
    ?pc(Pc);
    .print("Connected to ", Pc).

-connected : true <-
    .print("Disconnected, dropping everything, trying to reconnect.");
    .drop_all_desires;
    !start.
