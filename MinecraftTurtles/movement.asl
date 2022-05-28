// Turtle movement plans and reasonong

faceMap(east, 0).
faceMap(south, 1).
faceMap(west, 2).
faceMap(north, 3).

faceDelta(east,  delta(1, 0)).
faceDelta(south, delta(0, 1)).
faceDelta(west,  delta(-1, 0)).
faceDelta(north, delta(0, -1)).

facingW(Dir) :- faceMap(Dir, X) & facing(X).

poi(chest, -135, 65, 145, west).
poi(furnace, -129, 67, 149, east).

// poiFuel(fuel1, ).
// poiFuel(fuel2, ).
// poiFuel(fuel3, ).

at(X, Y, Z, Dir) :- at(X, Y, Z) & facingW(Dir).

facingBlock(X,Y,Z) :- at(CX, Y, CZ, Dir) & atFacingBlock(X, Z, CX, CZ, Dir).
atFacingBlock(X, Z, CX, CZ, Dir) :- faceDelta(Dir, delta(DX, DZ)) &
    X = CX + DX & Z = CZ+DZ.

+!moveTo(POI) : poi(POI, X, Y, Z, Dir) <-
    !moveTo(X, Y, Z, Dir).

+!moveTo(X, Y, Z, Dir) : at(X, Y, Z, Dir) <-
    true.

+!moveTo(X, Y, Z, Dir) : not at(X, Y, Z, Dir) <-
    ?faceMap(Dir, DirNum);
    .concat("tst.moveTowards(",X,",",Y,",",Z,",",DirNum,")",Fcn);
    // .print(Fcn);
    !move_check(Fcn);	
    !moveTo(X, Y, Z, Dir).
	
+!moveForward: true <-
	?facingW(Dir);
	?faceDelta(Dir, delta(DX, DZ));
	?at(X, Y, Z, Dir);
	!moveTo(X+DX, Y, Z+DZ, Dir).

+!moveToTimeout(X, Y, Z, Dir, Trials, true) : at(X, Y, Z, Dir) <-
    true.

+!moveToTimeout(X, Y, Z, Dir, Trials, Suc) : not at(X, Y, Z, Dir) <-
    ?faceMap(Dir, DirNum);
    .concat("tst.moveTowards(",X,",",Y,",",Z,",",DirNum,")",Fcn);
    !execsLocate(Fcn);
    !moveToTimeout(X, Y, Z, Dir, Trials, Suc).

@execLocateAtom[atomic]
+!execsLocate(Fcn) : true <-
    execs(Fcn);
    locate.

-!moveTo(X, Y, Z, Dir) : execs_err(Err) & Err == "Movement obstructed" <-
    execs("tst.randomMove()");
    !moveTo(X, Y, Z, Dir).

-!moveTo(X, Y, Z, Dir) : execs_err(Err) <-
    .print("Failed moveTo with: ", Err);
    .fail.

-!moveToTimeout(X, Y, Z, Dir, Trials, Suc) : Trials > 0  & execs_err(Err) & Err == "Movement obstructed" <-
    execs("tst.randomMove()");
    !moveToTimeout(X, Y, Z, Dir, Trials-1, Suc).

-!moveToTimeout(X, Y, Z, Dir, Trials, false) : execs_err(Err) & Err == "Movement obstructed" <-
    .print("Failed moveTo: ran out of trials").

-!moveToTimeout(X, Y, Z, Dir, Trials) : execs_err(Err) <-
    .print("Failed moveTo with: ", Err);
    .fail.


+!moveToFace(POI) : poi(POI, X, Y, Z, Dir) <-
    !moveToFace(X, Y, Z).

+!moveToFace(X, Y, Z) : not facingBlock(X,Y,Z) <-
    for (faceDelta(Dir, delta(MDX, MDZ))) {
        .print("Trying to go to ", X-MDX,", ",Y,", ",Z-MDZ," facing ",Dir);
        !moveToTimeout(X-MDX,Y,Z-MDZ,Dir,20,Success);
        if (Success) {
            .succeed_goal(moveToFace(X, Y, Z));
        }
    }.

+!moveToFace(X, Y, Z) : true <- true.

+!explore : true <-
    !moveTo(chest);
    .print("I am at the chest.");
    .wait(3000);
    !moveTo(furnace);
    .print("I am at the furnace.");
    .wait(3000);
    !explore.


+!exploreFacing : true <-
    !moveToFace(chest);
    .print("I am facing near the chest.");
    .wait(3000);
    !moveToFace(furnace);
    .print("I am facing near the furnace.");
    .wait(3000);
    !exploreFacing.


@lookAroundAtom[atomic]
+!lookAround : true <-
    execs("tst.inspect()");
    ?execs_out(FrontBlock);
    -+front_block(FrontBlock);
    execs("tst.inspectUp()");
    ?execs_out(AboveBlock);
    -+above_block(AboveBlock);
    execs("tst.inspectDown()");
    ?execs_out(BelowBlock);
    -+below_block(BelowBlock).

@move_checkAtom[atomic]
+!move_check(Fcn): true <-
    execs(Fcn);
    !check_front;
    !check_above;
    !check_below;
    locate.

+!check_front: true <-
    execs("tst.inspect()");
    ?execs_out(FrontBlock);
    -+front_block(FrontBlock).

-!check_front: true <- .print("front").

+!check_above: true <-
    execs("tst.inspectUp()");
    ?execs_out(AboveBlock);
    -+above_block(AboveBlock).

+!check_below: true <-
    execs("tst.inspectDown()");
    ?execs_out(BelowBlock);
    -+below_block(BelowBlock).
