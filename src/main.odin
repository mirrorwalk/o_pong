package main

import ba "core:container/bit_array"
import "core:math/rand"
import rl "vendor:raylib"

import "core:fmt"

main :: proc() {
	world := World{}
	init_world(&world)

	player, _ := new_entity(&world)


	add_component(&world.players, player, Player{})
	add_component(&world.positions, player, Position{x = 10, y = 50})
	add_component(&world.sizes, player, Size{height = 100, width = 13})
	add_component(&world.speeds, player, Speed{y = 10, x = 0})
	add_component(&world.renders, player, Render{})
	add_component(&world.colliders, player, Box_Collider{half = {7.5, 7.5}})
	add_component(&world.velocitys, player, Velocity{y = 0, x = 0})

	ball, _ := new_entity(&world)
	add_component(&world.balls, ball, Ball{})
	add_component(&world.positions, ball, Position{x = 100, y = 100})
	add_component(&world.sizes, ball, Size{height = 15, width = 15})
	add_component(&world.speeds, ball, Speed{y = 10, x = 10})
	add_component(&world.velocitys, ball, Velocity{y = 0, x = 10})
	add_component(&world.colliders, ball, Sphere_Collider{radius = 15 / 2})
	add_component(&world.renders, ball, Render{})

	enemy, _ := new_entity(&world)
	add_component(&world.enemies, enemy, Enemy{})
	add_component(&world.positions, enemy, Position{x = 800 - 30, y = 200})
	add_component(&world.sizes, enemy, Size{height = 100, width = 13})
	add_component(&world.speeds, enemy, Speed{y = 10, x = 0})
	add_component(&world.renders, enemy, Render{})
	add_component(&world.colliders, enemy, Box_Collider{half = {7.5, 7.5}})
	add_component(&world.velocitys, enemy, Velocity{y = 0, x = 0})

	rl.InitWindow(800, 600, "PONG")
	rl.SetTargetFPS(60)
	defer rl.CloseWindow()

	for !rl.WindowShouldClose() {
		get_input(&world)
		ball_move(&world)
		enemy_move(&world)
		win_con(&world)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		render(&world)

		rl.EndDrawing()
	}

}

get_input :: proc(world: ^World) {
	if rl.IsKeyDown(.S) {
		it := ba.make_iterator(&world.players.present)

		for id in ba.iterate_by_set(&it) {
			if has_component(&world.positions, id) &&
			   has_component(&world.speeds, id) &&
			   has_component(&world.sizes, id) &&
			   has_component(&world.velocitys, id) {
				player_position := get_component(&world.positions, id)
				player_speed := get_component(&world.speeds, id)
				player_size := get_component(&world.sizes, id)
				player_vel := get_component(&world.velocitys, id)

				window_height := cast(int)rl.GetScreenHeight()

				max_y := window_height - player_size.height

				new_y := min(player_position.y + player_speed.y, max_y)

				if new_y != max_y {
					player_vel.y += player_speed.y
				}

				player_position.y = new_y

			}
		}
	}

	if rl.IsKeyDown(.W) {
		it := ba.make_iterator(&world.players.present)

		for id in ba.iterate_by_set(&it) {
			if has_component(&world.positions, id) &&
			   has_component(&world.speeds, id) &&
			   has_component(&world.velocitys, id) {
				player_position := get_component(&world.positions, id)
				player_speed := get_component(&world.speeds, id)
				player_vel := get_component(&world.velocitys, id)

				new_y := max(player_position.y - player_speed.y, 0)

				if new_y != 0 {
					player_vel.y -= player_speed.y
				}

				player_position.y = new_y

			}
		}
	}
}

win_con :: proc(world: ^World) {
	it := ba.make_iterator(&world.balls.present)

	for id in ba.iterate_by_set(&it) {
		if has_component(&world.positions, id) && has_component(&world.sizes, id) {
			pos := get_component(&world.positions, id)
			size := get_component(&world.sizes, id)
			screen_width := rl.GetScreenWidth()

			if pos.x - size.width <= 0 {
				world.score -= 1
				reset_state(world)
			} else if pos.x + size.width >= auto_cast screen_width {
				world.score += 1
				reset_state(world)
			}

		}
	}
}

reset_state :: proc(world: ^World) {
	player_it := ba.make_iterator(&world.players.present)
	for id in ba.iterate_by_set(&player_it) {
		if has_component(&world.positions, id) && has_component(&world.velocitys, id) {
			pos := get_component(&world.positions, id)
			vel := get_component(&world.velocitys, id)

			pos.y = 50
			vel.x = 0
			vel.y = 0
		}
	}

	enemy_it := ba.make_iterator(&world.enemies.present)
	for id in ba.iterate_by_set(&enemy_it) {
		if has_component(&world.positions, id) && has_component(&world.velocitys, id) {
			pos := get_component(&world.positions, id)
			vel := get_component(&world.velocitys, id)

			pos.y = 50
			vel.x = 0
			vel.y = 0
		}
	}

	ball_it := ba.make_iterator(&world.balls.present)
	for id in ba.iterate_by_set(&ball_it) {
		if has_component(&world.positions, id) &&
		   has_component(&world.velocitys, id) &&
		   has_component(&world.speeds, id) {
			pos := get_component(&world.positions, id)
			vel := get_component(&world.velocitys, id)
			speed := get_component(&world.speeds, id)

			pos.y = 50
			pos.x = 400
			vel.x = rand.int_range(-speed.x, speed.x)
			vel.y = rand.int_range(-speed.y, speed.y)

            if vel.x == 0 do vel.x += 1
            if vel.y == 0 do vel.y += 1
		}
	}
}

enemy_move :: proc(world: ^World) {
	it := ba.make_iterator(&world.enemies.present)

	for id in ba.iterate_by_set(&it) {
		if has_component(&world.positions, id) &&
		   has_component(&world.speeds, id) &&
		   has_component(&world.velocitys, id) {
			ball_it := ba.make_iterator(&world.balls.present)

			for ball_id in ba.iterate_by_set(&ball_it) {
				if has_component(&world.positions, ball_id) {
					ball_position := get_component(&world.positions, ball_id)

					pos := get_component(&world.positions, id)
					size := get_component(&world.sizes, id)
					speed := get_component(&world.speeds, id)

					// fmt.printfln("{}, {}", ball_position.y, pos.y)

					if ball_position.y > pos.y + size.height {
						pos.y += speed.y
					} else if ball_position.y < pos.y {
						pos.y -= speed.y
					}
				}
			}
		}
	}
}

ball_move :: proc(world: ^World) {
	it := ba.make_iterator(&world.balls.present)

	for id in ba.iterate_by_set(&it) {
		if has_component(&world.positions, id) &&
		   has_component(&world.speeds, id) &&
		   has_component(&world.velocitys, id) {
			ball_position := get_component(&world.positions, id)
			ball_speed := get_component(&world.speeds, id)
			ball_velocity := get_component(&world.velocitys, id)

			window_width: int = auto_cast rl.GetScreenWidth()
			window_height: int = auto_cast rl.GetScreenHeight()

			new_velocity := [2]int{ball_velocity.x, ball_velocity.y}

			new_pos := [2]int{ball_position.x + new_velocity.x, ball_position.y + new_velocity.y}

			if new_pos.x >= window_width || new_pos.x <= 0 {
				new_velocity.x *= -1
			}
			if new_pos.y >= window_height || new_pos.y <= 0 {
				new_velocity.y *= -1
			}

			col_it := ba.make_iterator(&world.colliders.present)

			for col_id in ba.iterate_by_set(&col_it) {
				if col_id == id {continue}

				if has_component(&world.colliders, col_id) &&
				   has_component(&world.positions, col_id) &&
				   has_component(&world.velocitys, id) {
					col_pos := get_component(&world.positions, col_id)
					col_col := get_component(&world.colliders, col_id)
					col_vel := get_component(&world.velocitys, col_id)

					col := get_component(&world.colliders, id).(Sphere_Collider)

					switch other in col_col {
					case Box_Collider:
						col_size := get_component(&world.sizes, col_id)

						cx := f32(new_pos.x)
						cy := f32(new_pos.y)

						// position is the top-left corner, same as in render()
						left := f32(col_pos.x)
						top := f32(col_pos.y)
						right := left + f32(col_size.width)
						bottom := top + f32(col_size.height)

						closest_x := clamp(cx, left, right)
						closest_y := clamp(cy, top, bottom)

						dx := cx - closest_x
						dy := cy - closest_y

						if dx * dx + dy * dy <= col.radius * col.radius {
							new_velocity *= -1
							new_vel_y := new_velocity.y + col_vel.y
							new_velocity.y = clamp(new_vel_y, -ball_speed.y, ball_speed.y)
						}
					case Sphere_Collider:
					}

				}
			}

			ball_velocity.x = new_velocity.x
			ball_velocity.y = new_velocity.y

			ball_position.x += new_velocity.x
			ball_position.y += new_velocity.y
		}
	}
}

render :: proc(world: ^World) {
	it := ba.make_iterator(&world.renders.present)

	for id in ba.iterate_by_set(&it) {
		if has_component(&world.positions, id) && has_component(&world.sizes, id) {
			size := get_component(&world.sizes, id)
			position := get_component(&world.positions, id)

			if has_component(&world.players, id) || has_component(&world.enemies, id) {
				rl.DrawRectangle(
					auto_cast position.x,
					auto_cast position.y,
					auto_cast size.width,
					auto_cast size.height,
					rl.WHITE,
				)
			}

			if has_component(&world.balls, id) {
				rl.DrawEllipse(
					auto_cast position.x,
					auto_cast position.y,
					auto_cast size.height / 2,
					auto_cast size.width / 2,
					rl.WHITE,
				)
			}
		}
	}

    screen_width := rl.GetScreenWidth()
    screen_height := rl.GetScreenHeight()

    s := fmt.ctprintf("%d", world.score)
    rl.DrawText(s, screen_width / 2 - 50, screen_height / 2 - 50, 100, rl.WHITE)
}
