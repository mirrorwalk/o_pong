package main

import ba "core:container/bit_array"

MAX_ENTITIES :: 1024

World :: struct {
	entities:  ba.Bit_Array,

    players: Component_Storage(Player),
    positions: Component_Storage(Position),
    sizes: Component_Storage(Size),
    speeds: Component_Storage(Speed),
    balls: Component_Storage(Ball),
    renders: Component_Storage(Render),
    velocitys: Component_Storage(Velocity),
    colliders: Component_Storage(Collider),

    storages: [dynamic]^Storage_Base,

}

init_world :: proc(world: ^World) {
    init_storage(&world.positions)
    init_storage(&world.players)
    init_storage(&world.sizes)
    init_storage(&world.speeds)
    init_storage(&world.balls)
    init_storage(&world.renders)
    init_storage(&world.velocitys)
    init_storage(&world.colliders)

    append(&world.storages, &world.positions)
    append(&world.storages, &world.players)
    append(&world.storages, &world.sizes)
    append(&world.storages, &world.speeds)
    append(&world.storages, &world.balls)
    append(&world.storages, &world.renders)
    append(&world.storages, &world.velocitys)
    append(&world.storages, &world.colliders)
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
