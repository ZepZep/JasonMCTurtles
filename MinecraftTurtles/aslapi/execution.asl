
// @execsAtom[atomic]
+!execs(What, Suc, Out, Err) : true <-
    .wait(not locked);
    // lock;
    +locked;
    // .print("executing ", What);
    What;
    .wait(execs_out(Out)[source(percept)]);
    -execs_out(Out)[source(percept)];
    Suc = true;
    // .print("unlocking");
    // unlock;
    -locked.
    // .print("unlocked").
    
+!execs(What) : true <- !execs(What, true, _, _).

-!execs(What, false, Out, Err) : true <-
    .wait(execs_out(Out)[source(percept)]);
    -execs_out(Out)[source(percept)];
    .wait(execs_err(Err));
    -execs_err(Err)[source(percept)];
    // .print("unlocking");
    // unlock;
    -locked.
    // .print("unlocked").
