// the `inv` Jason action creates the correct percepts for the return values
//   of turtle inv.checkSlot* methods
//   The created percept is slot(SlotNumber, ItemName, ItemCount)
//   In case of an empty slot, the percept is slot(SlotNumber, "empty", 0)
//
// turtles support methods:
//      inv.checkSlots() - check all slots and report them, takes ~1 second
//      inv.checkSlot(i) - checks slot `i`
//      inv.checkSlots_(i, j) - checks slots from `i` to `j` (`j` included)

// check the inventory and get the percepts
// print info about all non-empty slots
+!invDebug : true <-
    inv("inv.checkSlots()");
    for ( slot(Slot, Item, Count) & Count > 0 ) {
        .print("I have ", Count, " ", Item, " in slot ", Slot, ".");
    }.

// check fuel level and talk about it
+!fuelDebug : true <-
    execs_literal("turtle.getFuelLevel()");
    ?execs_out(FuelLevel);
    .print("My fuel level is ", FuelLevel, ".");
    if (FuelLevel < 100) {
        .print(FuelLevel, " fuel is not enough, I should get a refuel.");
    } else {
        .print(FuelLevel, " fuel is plenty, I don't have to worry.");
    }.

@getFuelLevel[atomic]
+!check_fuel_level : true <-
    execs_literal("turtle.getFuelLevel()");
    ?execs_out(FuelLevel);
    -+fuel_amount(FuelLevel).


+!keep_fueled : not connected <-
    .wait(10000);
    !keep_fueled.

+!keep_fueled : refueling <-
    !check_fuel_level;
    ?fuel_amount(FuelLevel);
    .print("Checked fuel during refueling: ", FuelLevel);
    .wait(60000);
    !keep_fueled.


+!keep_fueled : minimum_fuel_level(Minimum) <-
    !check_fuel_level;
    ?fuel_amount(FuelLevel);
    .print("Checked fuel: ", FuelLevel);
    if (FuelLevel < Minimum) {
        .print("Fuel level low, going to refuel!");
        +refueling;
        // FIXME suspend other intentions
        !refuel;
        -refueling;
        // FIXME un-suspend other intentions
    }
    .wait(60000);
    !keep_fueled.


// FIXME implement refueling
+!refuel : true <- true.

// -!refuel : fuel_amount(Fuel) & Fuel == 0 <-
    // call for help.
    //
// -!refuel : fuel_amount(Fuel) & Fuel > 0 <-
    // go get fuel.
