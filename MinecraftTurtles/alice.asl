// Agent alice in project Room.mas2j

!start.

facing(north) :- facing(4).
facing(east)  :- facing(1).
facing(south) :- facing(2).
facing(west)  :- facing(3).

poi(chest, -128, 65, 145, north).

at(X, Y, Z, Dir) :- at(X, Y, Z) & facing(Dir).


+moveTo(POI) : poi(POI, X, Y, Z, Dir) <-
    !moveTo(X, Y, Z, Dir).

+!moveTo(X, Y, Z, Dir) : at(X, Y, Z, Dir) <- true.

+!moveTo(X, Y, Z, Dir)
    :   not at(X, Y, Z, Dir) &
        at(CX, CY, CZ, CDir)
    <- true.


/* Plans */

+!start : true <-
    connect;
    ?pc(Pc);
    .wait(50);
    .print("Connected to ", Pc).


    // .print("Hello, i am Alice");
    // .wait(100);
    // .print("Alice acting");
    // longAction;
    // .print("Alice done").
    //

