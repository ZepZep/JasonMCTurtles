/* Agent bob */

{ include("connection.asl") }
{ include("movement.asl") }

/* Initial goal */
!start.
// !test.

/* Plans */
+!start : true <-
    !connect;
    !explore.

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

