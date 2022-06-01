/* Agent bob */

{ include("aslapi/connection.asl") }
{ include("aslapi/movement.asl") }
{ include("aslapi/inventory.asl") }
{ include("aslapi/woodcutting.asl") }
{ include("aslapi/execution.asl") }


/* Initial goal */
// !start.
// !test.

// !testFail.
// !testLists.

// !testIntentionPriority1.
// !testIntentionPriority2.
// !failN(3).
// !tryQueue.

// !testTryGoal.

!testExecs.

+!testExecs : true <-
    connect;
    !!waitdo(500, execs("tst.forward()"));
    !!waitdo(520, execs("tst.turnLeft()"));
    !!waitdo(530, execs("tst.back()"));
    !!waitdo(540, execs("tst.turnRight()")).

+!waitdo(W, A): true <-
    .wait(W);
    .print("started ", A, " at ", W);
    !execs(A, Suc, Out, Err);
    .print("ended ", A, " with: ", Suc, " | ", Out, " | ", Err).

craftingSlots([1,2,3,5,6,7,9,10,11]).

recipe(turtle,[iron,    iron,        iron,
               iron,    computer,    iron,
               iron,    chest,       iron]).

queueRecipe([], [], Q) :- true.
queueRecipe([Item | Items], [Slot|Slots], Q) :- .queue.add(Q, t(Item, Slot)) & queueRecipe(Items, Slots, Q).

+!tryQueue : true <-
    ?recipe(turtle, Items);
    ?craftingSlots(Slots);
    .queue.create(Q,priority); 
    ?queueRecipe(Items, Slots, Q);
    for ( .member(t(Item, Slot),Q) ) {           // iteration
       .print(Item, " ", Slot);
    }.
    
+!tryGoal(G, Suc) : true <-
    !G;
    Suc = true.
    
-!tryGoal(G, false) : true <- true.

+!failGoal : true <- true.

+!testTryGoal : true <-
    !tryGoal(failGoal, Suc);
    .print(Suc).
    
    
// +!ensureGoTo(X) :
    // !tryGoal(goTo(X), Suc, Error);
    // if (not Suc) {
    // 
    // }
    

/* Plans */
+!start : true <-
    !connect;
    !invDebug;
    !exploreFacing.
    // !explore.
    
+!failN(0) : true <-
    for (.intention(_, _, Stack)) {
        .print(Stack);
    }.
    
+!failN(N) : true <- .fail.

-!failN(N) : true <- !failN(N-1).

// @i1[priority(10)]
// +!testIntentionPriority1 : true <-
    // .print("i1");
    // .wait(2000);
    // !testIntentionPriority1.
    // 
// +!testIntentionPriority2 : true <-
    // .print("i2");
    // .wait(2000);
    // !testIntentionPriority2.

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

