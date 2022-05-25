/* Agent bob */

{ include("connection.asl") }
{ include("movement.asl") }
{ include("inventory.asl") }

/* Initial goal */
!start.
// !test.

// !testFail.
// !testLists.


/* Plans */
+!start : true <-
    !connect;
    !invDebug;
    !exploreFacing.
    // !explore.


+!testLists : true <- true.


+!testFail : true <-
    !inner1;
    .wait(5000);
    !testFail.

+!inner1 : true <-
    .print("start inner1");
    !inner2.

-!inner1 : true <-
    .print("inner1 failed");
    .intention(_,_,S,current);
    .length(S, L);
    .nth(L-1,S,I);
    .print(S).

+!inner2 : true <-
    .print("start inner2");
    .fail.

-!inner2 : true <-
    .print("inner2 failed");
    .fail.


+!test : true <-
    // .print("A" + "B");
    +reason(kocka1)[source(percept)];
    +reason(kocka2)[source(percept)];
    +reason(kocka3)[source(percept)];
    returning;
    ?reason(R);
    .print(R);
    // ?reason(kocka2);
    // ?reason(kocka3);


    +v1(0);
    .print("while");
    while(v1(X) & X < 1) { // where vl(X) is a belief
        .print("loop ", X);
        !testOnce;
        -+v1(X+1);
    }.

+!testOnce : true <-
    returning;
    ?reason(X)[source(S)];
    -reason(X)[source(S)];
    .print(X, " ", S).

