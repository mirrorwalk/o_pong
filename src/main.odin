package main

import ba "core:container/bit_array"
import rl "vendor:raylib"

main :: proc() {
	world := World{}
	init_world(&world)

	player, _ := new_entity(&world)

	add_component(&world.players, player, Player{})
	add_component(&world.positions, player, Position{x = 10, y = 50})
	add_component(&world.sizes, player, Size{height = 100, width = 13})
	add_component(&world.speeds, player, Speed{y = 10, x = 0})

	rl.InitWindow(800, 600, "PONG")
	rl.SetTargetFPS(60)
	defer rl.CloseWindow()

	for !rl.WindowShouldClose() {
		get_input(&world)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		render_player(&world)

		rl.EndDrawing()
	}

}

get_input :: proc(world: ^World) {
	if rl.IsKeyDown(.S) {
		it := ba.make_iterator(&world.players.present)

		for id in ba.iterate_by_set(&it) {
			if has_component(&world.positions, id) &&
			   has_component(&world.speeds, id) &&
			   has_component(&world.sizes, id) {
				player_position := get_component(&world.positions, id)
				player_speed := get_component(&world.speeds, id)
                player_size := get_component(&world.sizes, id)

				window_height := cast(int)rl.GetScreenHeight()

                max_y := window_height - player_size.height

				new_y := min(player_position.y + player_speed.y, max_y)

				player_position.y = new_y

			}
		}
	}

	if rl.IsKeyDown(.W) {
		it := ba.make_iterator(&world.players.present)

		for id in ba.iterate_by_set(&it) {
			if has_component(&world.positions, id) && has_component(&world.speeds, id) {
				player_position := get_component(&world.positions, id)
				player_speed := get_component(&world.speeds, id)

				new_y := max(player_position.y - player_speed.y, 0)

				player_position.y = new_y

			}
		}
	}
}

render_player :: proc(world: ^World) {
	it := ba.make_iterator(&world.players.present)

	for id in ba.iterate_by_set(&it) {
		if has_component(&world.positions, id) && has_component(&world.sizes, id) {
			player_size := get_component(&world.sizes, id)
			player_position := get_component(&world.positions, id)

			rl.DrawRectangle(
				auto_cast player_position.x,
				auto_cast player_position.y,
				auto_cast player_size.width,
				auto_cast player_size.height,
				rl.WHITE,
			)
		}
	}
}
