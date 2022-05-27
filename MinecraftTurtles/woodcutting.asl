// Turtle wood gathering plans and reasoning

{ include("movement.asl") }
{ include("inventory.asl") }

poi(storage, 0, 4, -29, north).

wood("minecraft:oak_log").
wood("minecraft:birch_log").
wood("minecraft:spruce_log").
sapling("minecraft:oak_sapling").
sapling("minecraft:birch_sapling").
sapling("minecraft:spruce_sapling").
no_block("minecraft:air").

poi(tree,-20,4, -39, north).

treeInFront :- front_block(Block) & wood(Block).
nothingInFront :- front_block(Block) & no_block(Block).

+!keep_chopping: above_block(Block) & wood(Block) <-
    .wait(1000);
    execs("turtle.digUp()");
    !move_check("tst.up()");
    !keep_chopping.

+!keep_chopping: true <- true.

+!chopTree: front_block(Block) & wood(Block) <-
    .wait(1000);
    execs("turtle.dig()");
    !move_check("tst.forward()");
    !keep_chopping.

+!storeWood : true <-
    !moveTo(storage);
    // ADD select wood ######################
    execs("turtle.select(2)");
    exec("tst.store(1)");
    execs("turtle.select(1)").

+!woodCutting: true <-
    !moveTo(tree);
    !chopTree;
    .wait(3000);
    !storeWood;
    !woodCutting.

+!plantTree: front_block(Block) & no_block(Block) <-
    //look for a slot with a sapling
	inv("inv.checkSlots()");
	?slot(SlotNum, "minecraft:spruce_sapling", Count);
    execs("turtle.select(2)");
    execs("turtle.place()");
    execs("turtle.select(1)").
	
+!collectAround: true <-
	for( .range(I,1,4)){
		execs("turtle.suck()");
		execs("turtle.turnRight()");
	}.
	
+!saplingSearch(X,Y,Z): true <-
	//receive message that tree has been planted in (X, Y, Z)
	!moveTo(X-1, Y, Z-1, east);
	for( .range(I,1,4)){
		!collectAround;
		execs("turtle.forward()");
		!collectAround;
		execs("turtle.forward()");
		execs("turtle.turnLeft()");
	}
	!collectAround.
	


