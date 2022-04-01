// Turtle movement plans and reasonong

faceMap(east, 0).
faceMap(south, 1).
faceMap(west, 2).
faceMap(north, 3).


facing(east)  :- facing(0).
facing(south) :- facing(1).
facing(west)  :- facing(2).
facing(north) :- facing(3).

poi(chest, -135, 65, 145, west).
poi(furnace, -129, 67, 149, east).

at(X, Y, Z, Dir) :- at(X, Y, Z) & facing(Dir).


+!moveTo(POI) : poi(POI, X, Y, Z, Dir) <-
    !moveTo(X, Y, Z, Dir).

+!moveTo(X, Y, Z, Dir) : at(X, Y, Z, Dir) <- 
    true.

+!moveTo(X, Y, Z, Dir) : not at(X, Y, Z, Dir) <-
    ?faceMap(Dir, DirNum);
    .concat("tst.moveTowards(",X,",",Y,",",Z,",",DirNum,")",Fcn);
    // .print(Fcn);
    !execsLocate(Fcn);
    !moveTo(X, Y, Z, Dir).

@execLocateAtom[atomic]
+!execsLocate(Fcn) : true <-
    execs(Fcn);
    locate.
    
-!moveTo(X, Y, Z, Dir) : execs_err(Err) <-
    .print("Failed moveTo with: ", Err);
    execs("tst.randomMove()");
    !moveTo(X, Y, Z, Dir).
    
+!explore : true <-
    !moveTo(chest);
    .print("I am at the chest.");
    .wait(3000);
    !moveTo(furnace);
    .print("I am at the furnace.");
    .wait(3000);
    !explore.
