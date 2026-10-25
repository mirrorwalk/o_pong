package main

import ba "core:container/bit_array"
import "core:fmt"

main :: proc() {
	world := World{}
	init_world(&world)

	player1, _ := new_entity(&world)
	player2, _ := new_entity(&world)

	add_component(&world.prints, player1, Print{})
	add_component(&world.players, player1, Player{})

	add_component(&world.prints, player2, Print{})
	add_component(&world.players, player2, Player{})
	add_component(&world.nos, player2, No{})

	print_player(&world)
}


print_player :: proc(world: ^World) {
	it := ba.make_iterator(&world.players.present)

	for id in ba.iterate_by_set(&it) {
		if has_component(&world.prints, id) && has_not_component(&world.nos, id) {
			fmt.printfln("{}", id)
		}
	}
}
