/* Agent alice */

{ include("connection.asl") }
{ include("movement.asl") }
{ include("inventory.asl") }

minimum_fuel_level(100).


/* Initial goal */
!start.
!keep_fueled.

/* Plans */
+!start : true <-
    !connect;
    !invDebug;
    !fuelDebug;
    !explore.

