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
