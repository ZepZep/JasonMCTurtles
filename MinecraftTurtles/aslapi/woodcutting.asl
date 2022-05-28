// Turtle wood gathering plans and reasoning

{ include("movement.asl") }
{ include("inventory.asl") }
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

@tryAtomic[atomic]
+!try(Fcn, Suc, Out, Err) : true <-
    Fcn;
    .wait(execs_out(Out));
    Suc = true.
    
-!try(Fcn, false, Out, Err) : true <-
    ?execs_out(Out);
    ?execs_err(Err).
    

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

    
+!tryStore(Slot, Suc) : true <-
    .concat("turtle.select(",Slot,")", SelectSlot);
    execs(SelectSlot);
    !try(execs("turtle.drop()"), ESuc, Out, Err);
    .concat("inv.checkSlot(",Slot,")", CheckSlot);
    inv(CheckSlot);
    if (not ESuc & Err == "No space for items") {
        Suc = false;
    } elif (not ESuc) {
        .print("Unable to store: ", Err);
        .fail;
    } elif (slot(Slot, _, 0)) {
        Suc=true;
    } else {
        Suc = false;
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

    
    
    

+!woodCutting: true <-
    !moveTo(tree);
    !chopTree;
    .wait(3000);
    !storeWood;
    !woodCutting.
    
+!saplingSearch(X,Y,Z): true <-
	//receive message that tree has been planted in (X, Y, Z)
	!moveTo(X-1, Y, Z-1, east);
	for( .range(I,1,3)){
		!collectAround;
		!moveForward;
		!collectAround;
		!moveForward;
		execs("turtle.turnRight()");
	}
	!collectAround.
	
+!storeSticks: true <-
	inv("inv.checkSlots()");
	?slot(SlotNum, "minecraft:stick", Amount);
	!moveTo(stick);
	.concat("turtle.select(",SlotNum,")", SelectSlot);
	execs(SelectSlot);
	.concat("turtle.drop(",Amount,")", Store);
    execs(Store).
	
	


