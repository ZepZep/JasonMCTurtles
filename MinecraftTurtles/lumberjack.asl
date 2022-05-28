{ include("aslapi/rescue.asl") }
{ include("aslapi/connection.asl") }
{ include("aslapi/movement.asl") }
{ include("aslapi/inventory.asl") }
{ include("aslapi/locations2.asl") }
{ include("aslapi/woodcutting.asl") }




minimum_fuel_level(100).


!start.
!keep_fueled.

+!start : true <-
    !connect("2");
    .print("connected");
    !storeWood;
    !doTreechopping.

-!start : true <- 
    .print("OOO START FAILED");
    !start.

