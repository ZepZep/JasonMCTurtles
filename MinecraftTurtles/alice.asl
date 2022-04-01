/* Agent alice */

{ include("connection.asl") }
{ include("movement.asl") }

/* Initial goal */
!start.

/* Plans */
+!start : true <-
    !connect;
    !explore.

