package main

import ba "core:container/bit_array"

Position :: struct {
	x: int,
	y: int,
}

Player :: struct {}

No :: struct {}

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
