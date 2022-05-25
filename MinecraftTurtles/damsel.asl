{ include("rescue.asl") }

at(100, 100, 100).

!start.
// !test_best_response.


+!test_best_response: true <-
    ?best_response(Dist, Id, [t(30, "A"), t(10, "B"), t(2, "C")]);
    .print("best_response: ", Dist, ", ", Id).


+!start : true <-
    .random(WaitTime);
    .wait(1000 + WaitTime*2000);
    !ask_for_rescue.
