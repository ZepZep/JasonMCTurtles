{ include("locations.asl") }
{ include("recipes.asl") }
{ include("movement.asl") }
{ include("inventory.asl") }

craftingSlots([1,2,3,5,6,7,9,10,11]).
queueRecipe([], [], Q) :- true.
queueRecipe([Item | Items], [Slot|Slots], Q) :- Item == 0 & queueRecipe(Items, Slots, Q).
queueRecipe([Item | Items], [Slot|Slots], Q) :- .queue.add(Q, t(Item, Slot)) & queueRecipe(Items, Slots, Q).

prepareRecipe(Result, Q) :- recipe(Result, Items) & craftingSlots(Slots) &
    .queue.create(Q,priority) & queueRecipe(Items, Slots, Q).

+!getItem(Item, Slot, Amount): true <-
    !moveTo(Item);
    !selectSlot(Slot);
    .concat("turtle.suck(",Amount,")", SuckAmount);
    !execs(execs(SuckAmount), Suc, Out, Err);
    if (not Suc) {
        .print("Unable to get item ", Item, " error: ", Err);
        !goIdle;
        .wait(3000);
        !getItem(Item, Slot, Amount);
    }.

+!craft(Result, Amount): my_station(Station) & prepareRecipe(Result, Q) <-
    !emptyOutInventory;
    for ( .member(t(Item, Slot),Q) ) {
        .print("Getting ", Item, " x ", Amount);
        !getItem(Item, Slot, Amount);
    };
    !selectSlot(1);
    !moveTo(Station);
    .concat("turtle.craft(",Amount,")", Craft);
    .wait(1000);
    !execs(execs(Craft), Suc, Out, Err);
    if (not Suc) {
        .print("Failed to craft with: ", Err);
        .fail;
    };
    !moveTo(Result);
    !tryStore(1, Suc);
    if (not Suc) {
        .print("Storage full.");
    };
    !goIdle.
    
+!smelt(Result, Amount) : my_station(Station) & smelt_recipe(Result, Ingredient) <-
    !emptyOutInventory;
    !getItem(Ingredient, 1, Amount);
    !getItem(fuel, 2, Amount/8);
    !attendFurnace(Station, Amount);
    !moveTo(Result);
    !tryStore(1, Suc);
    if (not Suc) {
        .print("Storage full.");
    };
    !goIdle.  

+!attendFurnace(Station, Amount) : poi(Station, X, Y, Z, Dir) <-
    !moveTo(X, Y, Z, Dir);
    !selectSlot(2);
    !execs(execs("turtle.drop()"));
    
    ?faceDelta(Dir,  delta(DX, DZ));
    !moveCheck("tst.up()", _, _, _);
    !moveCheck("tst.forward()", _, _, _);
    !moveTo(X+DX,Y+1,Z+DZ, Dir);
    !selectSlot(1);
    !execs(execs("turtle.dropDown()"));
    
    !moveCheck("tst.back()", _, _, _);
    !moveCheck("tst.down()", _, _, _);
    !moveCheck("tst.down()", _, _, _);
    !moveCheck("tst.forward()", _, _, _);
    !moveTo(X+DX,Y-1,Z+DZ, Dir);
    !suckWaitForAmount(1, Amount).

+!suckWaitForAmount(Slot, Amount) : true <-
     !execs(execs("turtle.suckUp()"), _, _, _);
     !updateSlot(Slot);
     ?slot(Slot, _, SAmount);
     if (SAmount < Amount) {
        .print("Got only ", SAmount, " from ", Amount, ". Waiting");
        .wait(5000);
        !suckWaitForAmount(Slot, Amount);
     }.
    


