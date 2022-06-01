{ include("aslapi/rescue.asl") }
{ include("aslapi/connection.asl") }
{ include("aslapi/movement.asl") }
{ include("aslapi/inventory.asl") }
{ include("aslapi/locations2.asl") }
{ include("aslapi/crafting.asl") }

minimum_fuel_level(100).
role(smelter).

get_my_station(Station) :- .my_name(Station).

!start.
!keep_fueled.

+!getStation : my_station(Station) <- true.
+!getStation : get_my_station(Station) <- +my_station(Station).

+!start : true <-
    !getStation;
    !connect("5");
    .print("connected");
    !smelt(glass, 8).

