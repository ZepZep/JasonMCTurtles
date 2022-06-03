distance(X1, Y1, Z1, X2, Y2, Z2, Dist) :- Dist = (X1-X2)**2 + (Y1-Y2)**2 + (Z1-Z2)**2.

other_rescue_responses(Name, []) :- not other_rescue_responses_encountered(Name).

best_response(Dist, Id, [t(Dist, Id)]).
best_response(BestDist, BestId, [t(CurDist, CurId) | Tail]) :-
    best_response(PreDist, PreId, Tail) &
    unify_best_response(BestDist, BestId, CurDist, CurId, PreDist, PreId).

unify_best_response(BestDist, BestId, CurDist, CurId, PreDist, PreId) :-
    CurDist < PreDist & BestDist = CurDist & BestId = CurId.
unify_best_response(BestDist, BestId, CurDist, CurId, PreDist, PreId) :-
    CurDist >= PreDist & BestDist = PreDist & BestId = PreId.

rescuers(X) :- .findall(A, is_rescuer(A), X).
is_rescuer(XT) :- .all_names(Names) &.member(XT, Names) & .term2string(XT, XS) & .prefix("rescuer", XS).

is_fuel("minecraft:charcoal").
can_pickup_more_fuel(X) :- is_fuel(X).
can_pickup_more_fuel("empty").


+!ask_for_rescue : at(X,Y,Z) & .my_name(Name) & rescuers(Rescuers) <-
    .print("Help!");
    -rescue_responses(_);
    +rescue_responses([]);
    +asking_for_rescue;
    .send(Rescuers, tell, rescue_request(Name, X, Y, Z));

     .wait(1000);
     -asking_for_rescue;
     ?rescue_responses(Responses);
     if ( .empty(Responses) ) {
        .print("There is nobody to rescue me.");
        .fail;
     };
     ?best_response(Dist, Id, Responses);
     .print("Accepting rescue from ", Id);
     .send(Id, tell, accept_rescue(Name, X,Y,Z));
     !wait_for_fuel.

-!ask_for_rescue : not at(X,Y,Z) <-
    .print("Asking for rescue but dont know my position.");
    .fail.

-!ask_for_rescue : true <-
    // .drop_intention(ask_for_rescue);
    .wait(2000);
    !ask_for_rescue.
    
+!wait_for_fuel : fuel_transfered[source(_)] & is_fuel(Fuel)<-
    .print("Finally got fuel!");
    inv("inv.checkSlots()");
    ?slot(Slot, "minecraft:charcoal", Count);
    .concat("turtle.select(",Slot,")",Fcn);
    execs(Fcn);
    execs("turtle.refuel()");
    -fuel_transfered[source(_)].
    
-!wait_for_fuel : true <-
    !invDebug.
 
+!wait_for_fuel : true <-
    // .print("Awaiting fuel");
    .wait(1000);
    !wait_for_fuel.

@rescue_received_atom[priority(1000)]
+rescue_request(Name, X, Y, Z) :
    role(rescuer) & not rescuing(Turtle) &
    not refueling &
    not awaiting_response & at(MX, MY, MZ)
  <-
    +awaiting_response;
    ?distance(X,Y,Z,MX,MY,MZ,Dist);
    .my_name(MyName);
    .term2string(MyName, MyNameString);
    .send(Name, tell, i_can_rescue(Name, Dist, MyNameString));
    .wait(1500);
    if (not rescuing(Name)) {
        .print("will not rescue ", Name);
    }
    -rescue_request(Name, X, Y, Z)[source(_)];
    -awaiting_response.

+rescue_request(Name, X, Y, Z) : true <-
    -rescue_request(Name, X, Y, Z)[source(_)].

+accept_rescue(Name, X,Y,Z): not rescuing(Turtle) <-
    +rescuing(Name);
    .at("now +500", {+!go_rescue(Name, X,Y,Z)});
    -accept_rescue(Name, X,Y,Z)[source(_)].

+accept_rescue(Name, X,Y,Z): rescuing(Turtle) <-
    .print(Name, " accepted rescue while I was rescuing ", Turtle);
    -accept_rescue(Name, X,Y,Z)[source(_)].

@i_can_rescue_plan[priority(900)]
+i_can_rescue(Name, Dist, Id) : asking_for_rescue <-
    // .print("RR ", Name, " ", Id);
    ?rescue_responses(CurResp);
    -rescue_responses(_);
    +rescue_responses([t(Dist, Id) | CurResp]);
    -i_can_rescue(Name, Dist, Id)[source(_)].

+i_can_rescue(Name, Dist, Id) : not asking_for_rescue <-
    -i_can_rescue(Name, Dist, Id)[source(_)].


+!pickupFuel: true <- 
    inv("inv.checkSlot(1)");
    execs("turtle.select(1)");
    ?slot(1, Item, Count);
    !finishPickupFuel(Item, Count).
    
+!finishPickupFuel(Item, Count) : not can_pickup_more_fuel(Item)  <-
    execs("turtle.dropUp()");
    !pickupFuel.
    
+!finishPickupFuel(Item, Count) : pickup_amount(PA) & Count < PA <-
    !moveTo(fuel);
    .concat("turtle.suck(",PA-Count,")",Fcn);
    execs(Fcn).
    
+!finishPickupFuel(Item, Count) : true <- true.

+!go_rescue(Name, X,Y,Z) : refueling <-
    .wait(1000);
    !go_rescue(Name, X,Y,Z).

+!go_rescue(Name, X,Y,Z) : .my_name(MyName) <-
    .print("Rescuing ", Name);
    .concat("tst.speak(\"",MyName,"\", \"Rescuing ", Name, "\")",RescueMsg);
    !execs(execs(RescueMsg));
    !moveToFace(X,Y,Z);
    execs("turtle.select(1)");
    execs("turtle.drop()");
    // send message to Name
    .send(Name, tell, fuel_transfered);
    !pickupFuel;
    !goIdle;
    -rescuing(Name).

