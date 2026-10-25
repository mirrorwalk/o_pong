package main

import ba "core:container/bit_array"

MAX_ENTITIES :: 1024

World :: struct {
	entities: ba.Bit_Array,
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
}
