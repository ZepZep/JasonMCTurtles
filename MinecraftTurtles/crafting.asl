{ include("locations.asl") }
{ include("recipes.asl") }
{ include("movement.asl") }
{ include("inventory.asl") }

//coal("minecraft:coal_ore").
//stick("minecraft:stick").

+!getItem(Amount, Pos): true <-
    !moveTo(Pos);
    .concat("turtle.suck(",Amount,")", SuckAmount);
    execs(SuckAmount).

    //execs("inv.idSlot(1)");
    //?execs_out(Num);
    //.print(Num).

+!craft(Item, Amount): recipe(Item, Recipe) <-
    .map.create(R);
    .map.put(R, slot, 0);
    for( .member(I,Recipe) ){
        .map.get(R, slot, N);
        .map.put(R, slot, N+1);
        if( N == 3 | N == 7 ){ .map.put(R, slot, N+2); }
        if( not I == 0 ){
            .map.get(R, slot, M);
            .concat("turtle.select(",M,")", SelectSlot);
            execs(SelectSlot);
            !getItem(Amount, I);
    }}
    !moveTo(craftingTable);
    execs("turtle.select(1)");
    .concat("turtle.craft(",Amount,")", Craft);
    execs(Craft);
    !moveTo(Item);
    .concat("turtle.drop(",Amount,")", Store);
    execs(Store).

// we start the plan if we have the recipe for Item
+!craft(Item, Amount): recipe(Item, Recipe) <-
    //create a java map (~dictionary)
    .map.create(R);
    // we now count the amount we need of each ingredient
    // initialise all ingredients to 0
    for( .member(I,Recipe) ){
        if( not I == 0 ){
            .map.put(R, I, 0);
    }}
    // count them
    for( .member(I,Recipe) ){
        if( not I == 0 ){
            .map.get(R, I, N);
            .map.put(R, I, N+1);
            .print(I);
    }}
    // get desired amount of each ingredient
    for( .map.key(R,K) & .map.get(R,K,V) ){
        for( .range(I,1,K) ){
            !getItem(1, V);
    }}.


