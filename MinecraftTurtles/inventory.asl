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

@getFuelLevel[priority(100)]
+!observe_fuel_level : true <-
    execs_literal("turtle.getFuelLevel()");
    ?execs_out(FuelLevel);
    -fuel_amount(X);
    +fuel_amount(FuelLevel).

+!keep_fueled : not connected <-
    .wait(5000);
    !keep_fueled.
    
+!keep_fueled :  true <-
    !check_fuel_level;
    .wait(30000);
    !keep_fueled.

+!check_fuel_level : refueling <-
    !observe_fuel_level;
    ?fuel_amount(FuelLevel);
    .print("Checked fuel during refueling: ", FuelLevel).

+!check_fuel_level : minimum_fuel_level(Minimum) <-
    !observe_fuel_level;
    ?fuel_amount(FuelLevel);
    .print("Checked fuel: ", FuelLevel);
    if (FuelLevel <= Minimum) {
        .print("Fuel level low, going to refuel!");
        +refueling;
        !list_intentions("PREINT");
        !refuel;
        !list_intentions("POSTINT");
        -refueling;
        // FIXME un-suspend other intentions
    }.

+!list_intentions(Prefix) : true <-
    // .findall(X, .intend(X), L);
    .findall(X, .intention(_, _, X), L);
    for (.member(X, L)) {
        .print(Prefix, X);
    }.
    
    
@refuelAtom[priority(90)]
+!refuel : fuel_amount(Fuel) & Fuel > 0 <-
    .print("Moving to refuel.");
    !observe_fuel_level;
    !moveTo(fuel);
    execs("turtle.select(16)");
    execs("turtle.suck(4)");
    execs("turtle.refuel()").
    
+!refuel : fuel_amount(Fuel) & Fuel == 0 <-
    .print("Asking to refuel.");
    !observe_fuel_level;
    !ask_for_rescue.

-!refuel : true <-
    !observe_fuel_level;
    !refuel.
