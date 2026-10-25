package main

import ba "core:container/bit_array"

MAX_ENTITIES :: 1024

World :: struct {
	entities:  ba.Bit_Array,

	prints: Component_Storage(Print),
    players: Component_Storage(Player),
    nos: Component_Storage(No),

    storages: [dynamic]^Storage_Base,

}

init_world :: proc(world: ^World) {
    init_storage(&world.prints)
    init_storage(&world.players)
    init_storage(&world.nos)

    append(&world.storages, &world.prints)
    append(&world.storages, &world.players)
}

new_entity :: proc(world: ^World) -> (id: int, ok: bool) {
	it := ba.make_iterator(&world.entities)

	id, ok = ba.iterate_by_unset(&it)
	if !ok {
		id = ba.len(&world.entities)
	}

	if id > 1024 {
		return 0, false
	}

	ba.set(&world.entities, id)

	return id, true
}

kill_entity :: proc(world: ^World, id: int) {
	ba.unset(&world.entities, id)

    for s in world.storages {
        s.remove(s, id)
    }
}
