{ include("aslapi/rescue.asl") }
{ include("aslapi/connection.asl") }
{ include("aslapi/movement.asl") }
{ include("aslapi/inventory.asl") }
{ include("aslapi/locations2.asl") }



role(rescuer).
rescuing(init).
minimum_fuel_level(1000).
pickup_amount(1).


!start.
!keep_fueled.

+!start : true <-
    !connect("1");
    .print("connected");
    !pickupFuel;
    .print("Going Idle");
    !goIdle;
    .print("Able to rescue.");
    -rescuing(init);
    .suspend(start).


