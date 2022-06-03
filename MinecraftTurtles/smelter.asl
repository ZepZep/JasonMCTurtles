{ include("aslapi/rescue.asl") }
{ include("aslapi/connection.asl") }
{ include("aslapi/movement.asl") }
{ include("aslapi/inventory.asl") }
{ include("aslapi/locations2.asl") }
{ include("aslapi/crafting.asl") }

minimum_fuel_level(0).
role(smelter).

get_my_station(Station) :- .my_name(Station).

!start.
!keep_fueled.

+!getStation : my_station(Station) <- true.
+!getStation : get_my_station(Station) <- +my_station(Station).

+!start : true <-
    !connect("5");
    !getStation;
    .print("connected");
    !keep_smelting.

smelt_items([glass, gold, fuel]).
+!keep_smelting: smelt_items(Items) <-
    .random(Items, Item);
    .print("Smelting ", Item);
    !smelt(Item, 8);
    !goIdle;
    !keep_smelting.
    
-!keep_smelting : true <-
    .print("Something went wrong.");
    !keep_smelting.
    
    
    
