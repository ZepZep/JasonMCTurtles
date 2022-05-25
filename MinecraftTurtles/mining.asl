// Turtle mining plans and reasoning

{ include("movement.asl") }
{ include("inventory.asl") }

poi(mine,-20,4, -29, north).
poi(storage, 0, 4, -29, north).

coal("minecraft:coal_ore").


+!mineCoal : front_block(Block) & coal(Block) <-
    execs("turtle.dig()");
    .print("Dug some coal ore.").

//+!mineCoal : front_block(Block) & coal(Block) <-
//    ?front_block(FrontBlock);
//    if( FrontBlock == "minecraft:coal_ore"){
//        execs("tst.dig()");
//    }
//    else{
//        .print("no coal ore! block: ", X);
//    }.

-!mineCoal : front_block(Block) <-
    .print("not coal ore! block: ", Block).

+!storeCoal : true <-
    !moveTo(storage);
    // ADD select coal ######################
    exec("tst.store(1)").

//+!refuel: exec("tst.fuel_level()") < 30 <-

+!coalMining : true <-
    !moveTo(mine);
    .wait(3000);
    !mineCoal;
    !storeCoal;
    .wait(3000);
    !coalMining.








