package main

import ba "core:container/bit_array"

Enemy :: struct{}
Player :: struct {}
Position :: struct {
	x: int,
	y: int,
}
Size :: struct {
	width:  int,
	height: int,
}
Speed :: struct {
	x: int,
	y: int,
}
Velocity :: struct {
	x: int,
	y: int,
}
Ball :: struct {}
Render :: struct {}
Collider :: union {
	Box_Collider,
    Sphere_Collider,
}

Box_Collider :: struct {
	half: [2]f32,
}

Sphere_Collider :: struct {
    radius: f32
}

Component_Storage :: struct($T: typeid) {
	using base: Storage_Base,
	present:    ba.Bit_Array,
	data:       [MAX_ENTITIES]T,
}

Storage_Base :: struct {
	remove: proc(base: ^Storage_Base, id: int),
}

init_storage :: proc(s: ^Component_Storage($T)) {
	s.remove = proc(base: ^Storage_Base, id: int) {
		remove_component(cast(^Component_Storage(T))base, id)
	}
}

add_component :: proc(storage: ^Component_Storage($T), id: int, data: T) {
	ba.set(&storage.present, id)
	storage.data[id] = data
}

remove_component :: proc(storage: ^Component_Storage($T), id: int) {
	ba.unset(&storage.present, id)
	storage.data[id] = T{}
}

get_component :: proc(storage: ^Component_Storage($T), id: int) -> ^T {
	return &storage.data[id]
}

has_component :: proc(storage: ^Component_Storage($T), id: int) -> bool {
	is_set, ok := ba.get(&storage.present, id)
	return is_set && ok
}

has_not_component :: proc(storage: ^Component_Storage($T), id: int) -> bool {
	is_set, ok := ba.get(&storage.present, id)
	return !is_set || !ok
}
