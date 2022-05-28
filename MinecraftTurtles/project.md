## Ideas for what the turtles can do
* refueling
* fuel rescue (communication!)
* tree farm for fuel
    * plant (+ grow with bonemeal?)
    * chop + deliver
    * smelt
* farming
* breeding animals
* cobblestone generator
* quarry
* build tower / brige
* defending villagers
* hunting in groups

### End goal: self replication
* stone
    * cobblestone
* redstone
* glass
    * sand
* gold
    * gold ore
* chest
    * wood
* fuel
    * wood



* rescuing
    * communication
        * rescue sent
        *
* fuelmaking
* tree-chopping / mining

```dot
digraph G {
    rankdir=LR
    // splines=ortho

    node [shape=rectangle]

    // inputs
    subgraph cluster_0 {
        style=filled;
        color=lightgrey;
        node [style=filled,color=white];

        "Mine"
        "Tree Farm"
        label = "Inputs";
    }

    //outputs
    subgraph cluster_1 {
        style=filled;
        color=lightgrey;
        node [style=filled,color=white];
        Charcoal
        "Advanced turtle"
        // labelloc="b";
        label = "Outputs";
    }

    Mine -> "Gold Ore" [color=brown]
    Mine -> "Redstone" [color=brown]
    Mine -> Sand [color=brown]
    "Tree Farm" -> "Wood Log" [color=brown]

    "Gold Ore" -> "Gold Ingot" [color=red]
    Sand -> Glass [color=red]

    "Wood Log" -> "Wood Plank" [color=green]
    "Wood Plank" -> "Chest" [color=green]

    Glass -> "Glass Pane" [color=green]

    "Gold Ingot" -> "Advanced computer" [color=green]
    "Redstone" -> "Advanced computer" [color=green]
    "Glass Pane" -> "Advanced computer" [color=green]


    "Gold Ingot" -> "Advanced turtle" [color=green]
    "Advanced computer" -> "Advanced turtle" [color=green]
    Chest -> "Advanced turtle" [color=green]


    "Wood Log" -> Charcoal [color=red]
}
```
