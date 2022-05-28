{ include("aslapi/rescue.asl") }
{ include("aslapi/connection.asl") }
{ include("aslapi/movement.asl") }
{ include("aslapi/inventory.asl") }
{ include("aslapi/locations2.asl") }


minimum_fuel_level(0).

!start.
!keep_fueled.

+!start : true <-
    !connect("2");
    !explore(redstone, craftingTable4).

