/* Agent alice */

{ include("aslapi/connection.asl") }
{ include("aslapi/movement.asl") }
{ include("aslapi/inventory.asl") }
{ include("aslapi/mining.asl") }
{ include("aslapi/smelting.asl") }
{ include("aslapi/woodcutting.asl") }
{ include("aslapi/crafting.asl") }

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

