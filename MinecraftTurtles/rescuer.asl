{ include("rescue.asl") }
{ include("connection.asl") }
{ include("movement.asl") }
{ include("inventory.asl") }
{ include("locations2.asl") }



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
    for (.intend(Intention)) {
        .print("INT: ", Intention);
    }
    -rescuing(X).


