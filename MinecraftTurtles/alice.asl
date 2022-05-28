/* Agent alice */

{ include("connection.asl") }
{ include("movement.asl") }
{ include("inventory.asl") }
{ include("mining.asl") }
{ include("smelting.asl") }
{ include("woodcutting.asl") }
{ include("crafting.asl") }

/* Initial goal */
!start.

/* Plans */
+!start : true <-
    !connect;
	//execs("inv.idSlot(1)");
	//!craft(turtle, 1).
	//?execs_out(Num);
	//.print(Num).
	//!woodCutting;
	//!smeltGlass(14, 15, 8);
	//!invDebug.
	//inv("inv.checkSlots()").
	//!smeltGlass;
	!moveForward.
	//!saplingSearch(-20,4,-40).
	//!moveTo(tree);
	//!plantTree.
	//!woodCutting.
    //!coalMining.

