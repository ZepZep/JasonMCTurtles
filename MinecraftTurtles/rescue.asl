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


+!ask_for_rescue : at(X,Y,Z) & .my_name(Name) & rescuers(Rescuers) <-
    .print("Help!");
    -rescue_responses(X);
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
     .send(Id, tell, accept_rescue(Name, X,Y,Z)).

-!ask_for_rescue:
    .at("now +1000", {+!ask_for_rescue}).


+rescue_request(Name, X, Y, Z) :
    role(rescuer) & not rescuing(Turtle) &
    not awaiting_response & at(MX, MY, MZ)
  <-
    +awaiting_response;
    ?distance(X,Y,Z,MX,MY,MZ,Dist);
    .my_name(MyName);
    .term2string(MyName, MyNameString);
    .send(Name, tell, i_can_rescue(Name, Dist, MyNameString));
    .wait(1200);
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

@i_can_rescue_plan[atomic]
+i_can_rescue(Name, Dist, Id) : asking_for_rescue <-
    ?rescue_responses(CurResp);
    -rescue_responses(_);
    +rescue_responses([t(Dist, Id) | CurResp]);
    -i_can_rescue(Name, Dist, Id)[source(_)].

+i_can_rescue(Name, Dist, Id) : not asking_for_rescue <-
    -i_can_rescue(Name, Dist, Id)[source(_)].

+!go_rescue(Name, X,Y,Z) : true <-
    .print("Rescuing ", Name);
    .wait(3000);
    // .print("Rescue done");
    // send message to Name
    // go next_to block XYZ
    // transfer resources
    // get fuel
    -rescuing(Name).

