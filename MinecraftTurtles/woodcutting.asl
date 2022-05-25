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
    //check if current selected slot is a sapling
    execs("turtle.select(2)");
    execs("turtle.place()");
    execs("turtle.select(1)").



