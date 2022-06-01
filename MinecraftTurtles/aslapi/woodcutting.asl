// Turtle wood gathering plans and reasoning

{ include("movement.asl") }
// { include("inventory.asl") }
{ include("locations2.asl") }


wood("minecraft:oak_log").
wood("minecraft:birch_log").
wood("minecraft:spruce_log").
sapling("minecraft:oak_sapling").
sapling("minecraft:birch_sapling").
sapling("minecraft:spruce_sapling").
no_block("minecraft:air").

treeInFront :- front_block(Block) & wood(Block).
nothingInFront :- front_block(Block) & no_block(Block).


+!setupTreeLocations : tree_farm_setting(Y, Spacing, XMin, ZMin, XMax, ZMax) <-
    .queue.create(Q);
    for (.range(X,XMin,XMax,Spacing)) {
        for (.range(Z,ZMin,ZMax,Spacing)) {
            .queue.add(Q, t(X-1,Y,Z,east));
        }
    };
    +treeLocations(Q).

+!doTreechopping : not treeLocations(TreeLocations) <-
    !setupTreeLocations.
    !doTreechopping.
    
+!doTreechopping : treeLocations(TreeLocations) <-
    -foundAnyTree;
    for (.member(t(X,Y,Z,Dir), TreeLocations)) {
        !moveTo(X,Y,Z,Dir);
        if (treeInFront) {
            +foundAnyTree;
            !chopTree;
        }
    }
    if (foundAnyTree) {
        !storeWood;
    } else {
        .print("Did not find any grown tree, waiting for a while...");
        !goIdle;
        .wait(30000);
    }
    !doTreechopping.

+!chopTree: front_block(Block) & wood(Block) <-
    execs("turtle.dig()");
    !moveForward(true);
    !keepChopping.

+!keepChopping: above_block(Block) & wood(Block) <-
    execs("turtle.digUp()");
    !moveUp(true);
    !keepChopping;
    !moveDown(_).

+!keepChopping: true <- true.

+!storeWood : true <-
    inv("inv.checkSlots()");
    .findall(Slot, (slot(Slot, Item, Count) & wood(Item)), Slots);
    !storeWood(Slots).

+!storeWood([]) : true <- true.
+!storeWood([Slot|Slots]) : true <-
    !moveTo(log);
    !tryStore(Slot, Suc);
    if (not Suc) {
        .print("Storage full, waiting.");
        !goIdle;
        .wait(30000);
        !storeWood([Slot | Slots]);
    } else {
        !storeWood(Slots);
    }.


// ------- FORESTER -------

+!doForesting : not treeLocations(TreeLocations) <-
    !setupTreeLocations.
    !doForesting.
    
+!doForesting : treeLocations(TreeLocations) <-
    for (.member(t(X,Y,Z,Dir), TreeLocations)) {
        !moveTo(X,Y,Z,Dir);
        if (.random(Rnd) & Rnd < 0.5) {
            !saplingSearch;
        }
        if (nothingInFront) {
            !plantTree;
        }
    }
    !doForesting.

+!plantTree: true <-
	inv("inv.checkSlots()");
	if (slot(Slot, Item, Count) & sapling(Item)) {
        .concat("turtle.select(",Slot,")", SelectSlot);
        execs(SelectSlot);
        execs("turtle.place()");
    } else {
        .print("I dont have any saplings.");
        .fail;
    }.

+!collectAround: true <-
	for( .range(I,1,4)){
		!collect;
		execs("turtle.turnRight()");
	}.
	
+!collect: true <- execs("turtle.suck()").
-!collect: true <- true.

saplingSearchPattern([t(0, 0), t(2, 1), t(3, -1), t(1, -2), t(0, 0)]).

+!saplingSearch : at(X, Y, Z, Dir) & saplingSearchPattern(Pattern) <-
    for (.member(t(DX, DZ), Pattern)) {
        !moveTo(X+DX, Y, Z+DZ, Dir);
        !collectAround;
    }.

