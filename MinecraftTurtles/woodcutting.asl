// Turtle wood gathering plans and reasoning

{ include("movement.asl") }
{ include("inventory.asl") }
{ include("locations.asl") }

poi(woodTest, 0, 4, -29, north).
poi(stick, -12,0,-39, east).
poi(tree,-20,4, -39, north).
poi(realTree, -20, 4, -40, north).

wood("minecraft:oak_log").
wood("minecraft:birch_log").
wood("minecraft:spruce_log").
sapling("minecraft:oak_sapling").
sapling("minecraft:birch_sapling").
sapling("minecraft:spruce_sapling").
no_block("minecraft:air").

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
    !moveTo(woodTest);
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
	inv("inv.checkSlots()");
	?slot(SlotNum, "minecraft:spruce_sapling", Count);
	.concat("turtle.select(",SlotNum,")", SelectSlot);
    execs(SelectSlot);
    execs("turtle.place()").
	
+!collectAround: true <-
	for( .range(I,1,4)){
		!collect;
		execs("turtle.turnRight()");
	}.
	
+!collect: true <- execs("turtle.suck()").

-!collect: true <- true.

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
	
	


