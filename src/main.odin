package main

import "core:fmt"
main :: proc() {
	world := World{}
    init_world(&world)

    id, _ := new_entity(&world)
    kill_entity(&world, id)

    fmt.printfln("{}", id)
}
