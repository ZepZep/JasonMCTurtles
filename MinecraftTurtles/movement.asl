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

at(X, Y, Z, Dir) :- at(X, Y, Z) & facingW(Dir).

facingBlock(X,Y,Z) :- at(CX, Y, CZ, Dir) & atFacingBlock(X, Z, CX, CZ, Dir).
atFacingBlock(X, Z, CX, CZ, Dir) :- faceDelta(Dir, delta(DX, DZ)) &
    X = CX + DX & Z = CZ+DZ.

+!tryGoalErr(G, Suc, Err) : true <-
    !G;
    Suc = true.

-!tryGoalErr(G, false, Err) : true <-
    if (execs_err(CurErr)) {
        Err = CurErr;
    } else {
        Err = "NO_ERR";
    }.

+!moveTo(POI) : poi(POI, X, Y, Z, Dir) <-
    !moveTo(X, Y, Z, Dir).

+!moveTo(POI) : true <-
    .print("Unknown POI: ", POI);
    fail.

+!moveTo(X, Y, Z, Dir) : at(X, Y, Z, Dir) <-
    true.

+!moveTo(X, Y, Z, Dir) : not at(X, Y, Z, Dir) <-
    ?faceMap(Dir, DirNum);
    .concat("tst.moveTowards(",X,",",Y,",",Z,",",DirNum,")",Fcn);
    // .print(Fcn);
    !tryGoalErr(move_check(Fcn), Suc, Err);
    if (Suc) {
        !moveTo(X, Y, Z, Dir);
    } else {
        !moveToError(X, Y, Z, Dir, Err);
    }.


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
    !tryGoalErr(move_check(Fcn), ESuc, Err);
    if (ESuc) {
        !moveToTimeout(X, Y, Z, Dir, Trials, Suc);
    } else {
        !moveToTimeoutError(X, Y, Z, Dir, Trials, Suc, Err);
    }.


@execLocateAtom[atomic]
+!execsLocate(Fcn) : true <-
    execs(Fcn);
    locate.

+!tryCalibrate : true <-
    !tryGoalErr(calibrate, Suc, Err);
    if (not Suc) {
        .wait(5000);
        !tryCalibrate;
    }.

+!calibrate : true <-
    execs("tst.calibrate()");
    .print("callibration succesfull").

+!moveToError(X, Y, Z, Dir, "Movement obstructed") : true <-
    execs("tst.randomMove()");
    !moveTo(X, Y, Z, Dir).

+!moveToError(X, Y, Z, Dir, "Not calibrated") : true <-
    .print("Failed moveTo with: Not calibrated. Trying to callibrate");
    !tryCalibrate;
    !moveTo(X, Y, Z, Dir).

+!moveToError(X, Y, Z, Dir, "Out of fuel") : true <-
    !check_fuel_level;
    !moveTo(X, Y, Z, Dir).

+!moveToError(X, Y, Z, Dir, "NO_ERR") : true <-
    .print("Failed moveTo without execs_err");
    !moveTo(X, Y, Z, Dir).

+!moveToError(X, Y, Z, Dir, Err) : true <-
    .print("Failed moveTo with: ", Err);
    .fail.

+!moveToTimeoutError(X, Y, Z, Dir, Trials, Suc, "Movement obstructed") : Trials > 0  <-
    execs("tst.randomMove()");
    !moveToTimeout(X, Y, Z, Dir, Trials-1, Suc).

+!moveToTimeoutError(X, Y, Z, Dir, Trials, false, "Movement obstructed") : true  <-
    .print("Failed moveToTimeout: ran out of trials").

+!moveToTimeoutError(X, Y, Z, Dir, Trials, Suc, Err == "Not calibrated") : true <-
    .print("Failed moveToTimeout with: ", Err, " Trying to callibrate");
    !tryCalibrate;
    !moveToTimeout(X, Y, Z, Dir, Trials, Suc).

+!moveToTimeoutError(X, Y, Z, Dir, Trials, Suc, "Out of fuel") : true <-
    !check_fuel_level;
    !moveToTimeout(X, Y, Z, Dir, Trials, Suc).

+!moveToTimeoutError(X, Y, Z, Dir, Trials, Suc,  "NO_ERR") : true <-
    .print("Failed moveToTimeout without execs_err");
    !moveToTimeout(X, Y, Z, Dir, Trials, Suc).

+!moveToTimeoutError(X, Y, Z, Dir, Trials, Suc, Err) : true <-
    .print("Failed moveToTimeout with: ", Err);
    .drop_intention.

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

+!explore(POI1, POI2) : true <-
    !moveTo(POI1);
    .print("I am at the ",POI1);
    .wait(1000);
    !moveTo(POI2);
    .print("I am at the ",POI2);
    .wait(1000);
    !explore(POI1, POI2).


+!exploreFacing : true <-
    !moveToFace(chest);
    .print("I am facing near the chest.");
    .wait(1000);
    !moveToFace(furnace);
    .print("I am facing near the furnace.");
    .wait(1000);
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

+!check_above: true <-
    execs("tst.inspectUp()");
    ?execs_out(AboveBlock);
    -+above_block(AboveBlock).

+!check_below: true <-
    execs("tst.inspectDown()");
    ?execs_out(BelowBlock);
    -+below_block(BelowBlock).

randomNearby(CX,CY,CZ,Radius,X,Y,Z) :-
    .random(DX) & X = math.round(CX + (DX-0.5) * 2 * Radius) &
    .random(DY) & Y = math.round(CY + (DY-0.5) * 2 * Radius) &
    .random(DZ) & Z = math.round(CZ + (DZ-0.5) * 2 * Radius).

+!goIdle : poi(idle, CX,CY,CZ,Dir) <-
    ?randomNearby(CX,CY,CZ,3,X,Y,Z);
    .print("Going to idle at ",X," ", Y, " ", Z);
    !moveToTimeout(X,Y,Z,Dir,20,Success);
    if (not Success) {
        !goIdle;
    }.
