// the `inv` Jason action creates the correct percepts for the return values
//   of turtle inv.checkSlot* methods
//   The created percept is slot(SlotNumber, ItemName, ItemCount)
//   In case of an empty slot, the percept is slot(SlotNumber, "empty", 0)
//
// turtles support methods:
//      inv.checkSlots() - check all slots and report them, takes ~1 second
//      inv.checkSlot(i) - checks slot `i`
//      inv.checkSlots_(i, j) - checks slots from `i` to `j` (`j` included)

{ include("execution.asl") }

// check the inventory and get the percepts
// print info about all non-empty slots
+!invDebug : true <-
    inv("inv.checkSlots()");
    for ( slot(Slot, Item, Count) & Count > 0 ) {
        .print("I have ", Count, " ", Item, " in slot ", Slot, ".");
    }.

// check fuel level and talk about it
+!fuelDebug : true <-
    !execs(execs_literal("turtle.getFuelLevel()"), true, FuelLevel, _);
    .print("My fuel level is ", FuelLevel, ".");
    if (FuelLevel < 100) {
        .print(FuelLevel, " fuel is not enough, I should get a refuel.");
    } else {
        .print(FuelLevel, " fuel is plenty, I don't have to worry.");
    }.

+!selectSlot(Slot) : true <-
    .concat("turtle.select(",Slot,")", SelectSlot);
    !execs(execs(SelectSlot), true, _, _).
    
+!currentSlot(Slot) : true <-
    !execs(execs_literal("turtle.getSelectedSlot()"), true, Slot, _).
    
+!updateSlot(Slot) : true <-
    .concat("inv.checkSlot(",Slot,")", CheckSlot);
    !execs(inv(CheckSlot), true, _, _).
     
    
+!emptyOutInventory: true <-
    inv("inv.checkSlots()");
     for ( slot(Slot, Item, Count) & Count > 0 ) {
        !selectSlot(Slot);
        !execs(execs("turtle.dropUp()"), true, _, _);
    };
    inv("inv.checkSlots()").
    
    
// -----------------------------------
// ----------  STORE things  ---------
+!tryStore(Slot, Suc) : true <-
    !selectSlot(Slot);
    !execs(execs("turtle.drop()"), ESuc, Out, Err);
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
    
// -----------------------------------
// ----------  FUEL handling  ---------

// @getFuelLevelAtom[atomic]
+!observe_fuel_level : true <-
    !execs(execs_literal("turtle.getFuelLevel()"), true, FuelLevel, _);
    -+fuel_amount(FuelLevel).

+!keep_fueled : not connected <-
    .wait(5000);
    !keep_fueled.
    
+!keep_fueled :  true <-
    .wait(1000);
    !check_fuel_level;
    .wait(30000);
    !keep_fueled.

+!check_fuel_level : refueling <-
    !observe_fuel_level;
    ?fuel_amount(FuelLevel);
    if (FuelLevel == 0 & not refueling_ask) {
        .print("Ran out of fuel during attempting to refuel.");
        -refueling;
        !check_fuel_level;
    } else {
        .print("Checked fuel during refueling: ", FuelLevel);
    }.

+!check_fuel_level : minimum_fuel_level(Minimum) <-
    !observe_fuel_level;
    ?fuel_amount(FuelLevel);
    .print("Checked fuel: ", FuelLevel);
    if (FuelLevel <= Minimum & not rescuing(Turtle)) {
        // .print("Fuel level low, going to refuel!");
        +refueling;
        .intention(ICur,_,_,current);
        if (.intend(start, IStart) & ICur \== IStart) {
            // .print("Suspending start");
            .wait(not locked);
            // lock;
            +locked;
            .suspend(start);
            // unlock;
            -locked;
        }
        !refuel;
        -refueling;
    }.

+!list_intentions(Prefix) : true <-
    .findall(X, .intend(X), L);
    for (.member(X, L)) {
        .print(Prefix, X);
    }.

@refuelAtom[priority(90)]
+!refuel : fuel_amount(Fuel) & Fuel > 0 & at(X, Y, Z, Dir) <-
    .print("Moving to refuel.");
    !observe_fuel_level;
    !currentSlot(Slot);
    !moveTo(fuel);
    !selectSlot(16);
    !execs(execs("turtle.suck(4)"));
    !execs(execs("turtle.refuel()"));
    !selectSlot(Slot);
    !moveTo(X, Y, Z, Dir);
    .resume(start).
    
+!refuel : fuel_amount(Fuel) & Fuel == 0 <-
    .print("Asking to refuel.");
    !observe_fuel_level;
    +refueling_ask;
    !ask_for_rescue;
    -refueling_ask;
    .resume(start).

-!refuel : true <-
    !observe_fuel_level;
    !refuel.

