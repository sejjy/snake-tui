#!/usr/bin/env bash
#
# snake-tui: A text-based snake game (Bash version)
#
# Author:  sejjy <sejjymvm@gmail.com>
# Date:    October 16, 2026
# License: MIT

TIMEOUT=0.15
GRID_WIDTH=20
GRID_HEIGHT=20
GRID_SIZE=$((GRID_WIDTH * GRID_HEIGHT))
CHAR_EMPTY='.'
CHAR_HEAD='0'
CHAR_BODY='o'
CHAR_APPLE='@'

score=
hiscore=
snake_size=
tail_idx=
head_idx=
prev_tail_pos_x=
prev_tail_pos_y=
snake_x=()
snake_y=()
dir_x=
dir_y=
next_head_pos_x=
next_head_pos_y=
apple_x=
apple_y=
snake_collided=
apple_consumed=
declare -A occupied
finished=
timeout=

init_window()
{
	printf "\e[?1049h" # enable alternative buffer
	printf "\e[?25l"   # make cursor invisible
	stty -echo         # turn off echoing
}

update_apple_pos()
{
	while true; do
		apple_x=$((RANDOM % GRID_WIDTH))
		apple_y=$((RANDOM % GRID_HEIGHT))
		if [[ ${occupied["$apple_y,$apple_x"]} == false ]]; then
			break
		fi
	done
}

init_state()
{
	local x y

	score=0
	snake_size=2
	tail_idx=0
	head_idx=1
	snake_x[tail_idx]=$((GRID_WIDTH / 4))
	snake_y[tail_idx]=$((GRID_HEIGHT / 2))
	snake_x[head_idx]=$((snake_x[tail_idx] + 1))
	snake_y[head_idx]=${snake_y[tail_idx]}
	dir_x=1
	dir_y=0

	for ((y = 0; y < GRID_HEIGHT; y++)); do
		for ((x = 0; x < GRID_WIDTH; x++)); do
			occupied["$y,$x"]=false
		done
	done

	occupied["${snake_y[tail_idx]},${snake_x[tail_idx]}"]=true
	occupied["${snake_y[head_idx]},${snake_x[head_idx]}"]=true

	update_apple_pos
}

mvprintw()
{
	local y=$1
	local x=$2
	local output
	# shellcheck disable=SC2059
	printf -v output "$3" "${@:4}"

	printf "\e[%d;%dH" "$((1 + y))" "$((1 + x))"
	printf "%s" "$output"
}

print_scores()
{
	mvprintw 0 2 "score: %3d   hiscore: %3d" "$score" "$hiscore"
}

draw_walls()
{
	local x y
	local w=$((GRID_WIDTH * 2 + 2))
	local h=$((GRID_HEIGHT + 2))

	mvprintw 1 0 "┌"
	for ((x = 1; x < w; x++)); do
		mvprintw 1 "$x" "─"
	done
	mvprintw 1 "$w" "┐"

	for ((y = 2; y < h; y++)); do
		mvprintw "$y" 0 "│"
		mvprintw "$y" "$w" "│"
	done

	mvprintw "$h" 0 "└"
	for ((x = 1; x < w; x++)); do
		mvprintw "$h" "$x" "─"
	done
	mvprintw "$h" "$w" "┘"
}

draw_char()
{
	local y=$1
	local x=$2
	local c=$3

	printf "\e[%d;%dH" "$((3 + y))" "$((x * 2 + 3))"
	printf "%c" "$c"
}

print_controls()
{
	mvprintw "$((3 + GRID_HEIGHT))" 2 "move: w a s d   exit: esc"
}

init_drawing()
{
	local x y

	printf "\e[2J" # erase entire screen
	print_scores
	draw_walls

	for ((y = 0; y < GRID_HEIGHT; y++)); do
		for ((x = 0; x < GRID_WIDTH; x++)); do
			draw_char "$y" "$x" "$CHAR_EMPTY"
		done
	done

	draw_char "${snake_y[tail_idx]}" "${snake_x[tail_idx]}" "$CHAR_BODY"
	draw_char "${snake_y[head_idx]}" "${snake_x[head_idx]}" "$CHAR_HEAD"
	draw_char "$apple_y" "$apple_x" "$CHAR_APPLE"

	print_controls
}

read_input()
{
	local pressed

	read -rsn 1 -t "$timeout" pressed

	case $pressed in
		'w')
			if ((dir_y != 1)); then
				dir_x=0
				dir_y=-1
			fi
			;;
		'a')
			if ((dir_x != 1)); then
				dir_x=-1
				dir_y=0
			fi
			;;
		's')
			if ((dir_y != -1)); then
				dir_x=0
				dir_y=1
			fi
			;;
		'd')
			if ((dir_x != -1)); then
				dir_x=1
				dir_y=0
			fi
			;;
		$'\e')
			return 1
			;;
	esac

	return 0
}

update_state()
{
	next_head_pos_x=$((snake_x[head_idx] + dir_x))
	next_head_pos_y=$((snake_y[head_idx] + dir_y))

	snake_collided=false
	if ((next_head_pos_x < 0 || next_head_pos_x >= GRID_WIDTH ||
	     next_head_pos_y < 0 || next_head_pos_y >= GRID_HEIGHT)); then
		snake_collided=true
	elif [[ ${occupied["$next_head_pos_y,$next_head_pos_x"]} == true ]] &&
	     ((next_head_pos_x != snake_x[tail_idx] ||
	       next_head_pos_y != snake_y[tail_idx])); then
		snake_collided=true
	fi

	if ((next_head_pos_x == apple_x &&
	     next_head_pos_y == apple_y)); then
		apple_consumed=true
	else
		apple_consumed=false
	fi

	prev_tail_pos_x=${snake_x[tail_idx]}
	prev_tail_pos_y=${snake_y[tail_idx]}
	prev_head_pos_x=${snake_x[head_idx]}
	prev_head_pos_y=${snake_y[head_idx]}

	if [[ $snake_collided == true ]]; then
		return
	fi

	if [[ $apple_consumed == false ]]; then
		occupied["$prev_tail_pos_y,$prev_tail_pos_x"]=false
		tail_idx=$(((tail_idx + 1) % GRID_SIZE))
	fi

	occupied["$next_head_pos_y,$next_head_pos_x"]=true
	head_idx=$(((head_idx + 1) % GRID_SIZE))

	if [[ $apple_consumed == true ]]; then
		((score += 1))
		((snake_size += 1))
		if ((snake_size == GRID_SIZE)); then
			finished=true
		else
			finished=false
		fi

		if [[ $finished == false ]]; then
			update_apple_pos
		fi
	fi

	snake_x[head_idx]=$next_head_pos_x
	snake_y[head_idx]=$next_head_pos_y
}

update_drawing()
{
	if [[ $apple_consumed == false ]]; then
		draw_char "$prev_tail_pos_y" "$prev_tail_pos_x" "$CHAR_EMPTY"
	fi

	draw_char "$prev_head_pos_y" "$prev_head_pos_x" "$CHAR_BODY"
	draw_char "$next_head_pos_y" "$next_head_pos_x" "$CHAR_HEAD"

	if [[ $apple_consumed == true ]]; then
		if [[ $finished == false ]]; then
			draw_char "$apple_y" "$apple_x" "$CHAR_APPLE"
		fi
		print_scores
	fi
}

end_window()
{
	printf "\e[?1049l" # disable alternative buffer
	printf "\e[?25h"   # make cursor visible
	stty echo          # turn on echoing

	printf "score: %3d   hiscore: %3d\n" "$score" "$hiscore"
}

main()
{
	trap end_window EXIT

	hiscore=0
	timeout=$TIMEOUT

	init_window
	init_state
	init_drawing

	while true; do
		if ! read_input; then
			break
		fi

		update_state
		update_drawing

		if [[ $snake_collided == true || $finished == true ]]; then
			if ((score > hiscore)); then
				hiscore=$score
			fi
			timeout=3600

			if ! read_input; then
				break
			fi

			timeout=$TIMEOUT
			init_state
			init_drawing
		fi
	done
}

main
