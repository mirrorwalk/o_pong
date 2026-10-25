package main

import "core:fmt"

main :: proc() {
	world := World{}
    init_world(&world)

    id, _ := new_entity(&world)

    add_component(&world.positions, id, Position{x = 10, y = 10})

    fmt.printfln("{}", world.positions.data[id])


    remove_component(&world.positions, id)

    fmt.printfln("{}", world.positions.data[id])
}
