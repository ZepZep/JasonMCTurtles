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
	.set.create(Q);                // Q = []
	.set.add(Q,a);                 // Q = [a]
	.set.add(Q,b);
	.set.add(Q,c);
	.set.add(Q,a); 
	.print(Q);
    !connect;
	//execs("inv.idSlot(1)");
	!craft(turtle, 1).
	//?execs_out(Num);
	//.print(Num).
	//!woodCutting;
	//!smeltGlass(14, 15, 8);
	//!invDebug.
	//inv("inv.checkSlots()").
	//!smeltGlass;
	
	//!invDebug;
	//!woodCutting;
    //!coalMining.

