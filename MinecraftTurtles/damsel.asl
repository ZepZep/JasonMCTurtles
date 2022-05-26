{ include("rescue.asl") }
{ include("connection.asl") }
{ include("movement.asl") }
{ include("inventory.asl") }
{ include("locations2.asl") }


minimum_fuel_level(0).

!start.
!keep_fueled.

+!start : true <-
    !connect("2");
    !explore(redstone, craftingTable4).
    
-!start : true <-
    .print("Start failed").
