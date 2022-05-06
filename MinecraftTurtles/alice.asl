/* Agent alice */

{ include("connection.asl") }
{ include("movement.asl") }
{ include("inventory.asl") }


/* Initial goal */
!start.

/* Plans */
+!start : true <-
    !connect;
    !invDebug;
    !explore.

