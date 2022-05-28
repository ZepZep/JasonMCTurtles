{ include("movement.asl") }
{ include("inventory.asl") }
{ include("crafting.asl") }

poi(furnace,      -3, 4, -29, north).
poi(coalStorage, -10, 4, -29, north).
poi(sandStorage,  -8, 4, -29, north).
poi(glassStorage,  0, 4, -29, north).

+!smelt(Pos, SelectFuel, SelectMaterial, Amount): poi(Pos, X, Y, Z, Dir) <-
    !moveTo(Pos);
    execs(SelectFuel);
    .concat("turtle.drop(",Amount/8,")", DropAmount1);
    execs(DropAmount1);
    ?dirVec(Dir, Vx, Vz);
    !moveTo(X+Vx,Y+1,Z+Vz, Dir);
    execs(SelectMaterial);
    .concat("turtle.dropDown(",Amount,")", DropAmount2);
    execs(DropAmount2).

//add condition that slots are empty
+!smeltGlass(FuelSlot, MaterialSlot, Amount): true <-
    .concat("turtle.select(",FuelSlot,")", SelectFuel);
    .concat("turtle.select(",MaterialSlot,")", SelectMaterial);
    execs(SelectFuel);
    !getItem(Amount/8, coalStorage);
    execs(SelectMaterial);
    !getItem(Amount, sandStorage);
    !smelt(furnace, SelectFuel, SelectMaterial, Amount).
    //execs("turtle.turnRight()");
    //execs("turtle.forward()");
    //execs("turtle.down()");
    //execs("turtle.turnRight()");
    //execs("turtle.turnRight()");
    //.wait(100000);
    //execs("turtle.suck(8)");
    //!moveTo(glassStorage);
    //execs("turtle.drop(8)").
