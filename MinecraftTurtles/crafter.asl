{ include("aslapi/rescue.asl") }
{ include("aslapi/connection.asl") }
{ include("aslapi/movement.asl") }
{ include("aslapi/inventory.asl") }
{ include("aslapi/locations2.asl") }
{ include("aslapi/crafting.asl") }

minimum_fuel_level(0).
role(crafter).

get_my_station(Station) :- .my_name(Station).

!start.
!keep_fueled.

+!getStation : my_station(Station) <- true.
+!getStation : get_my_station(Station) <- +my_station(Station).

+!start : true <-
    !connect("4");
    !getStation;
    .print("connected");
    !keep_crafting.

craft_items([wood, glass_pane, chest]).
+!keep_crafting: craft_items(Items) <-
    .random(Items, Item);
    .print("Crafting ", Item);
    !craft(Item, 1);
    !goIdle;
    !keep_crafting.
    
-!keep_crafting : true <-
    .print("Something went wrong.");
    !keep_crafting.
