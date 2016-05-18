function decrement(collection, key, increment, min)
    collection[key] = math.max(min, collection[key] - increment)
end

function increment(collection, key, increment, max)
    collection[key] = math.min(max, collection[key] + increment)
end

function love.update(dt)

    --Update here
    local player = game.player

    if player.input ~= nil then
        local input = player.input

        if input == UP or input == DOWN or input == LEFT or input == RIGHT then
            player_move(player, input)
            time_update(player)
        end

        if did_move == true then
        end

        local current_world = player.path[#(player.path)].world
        local cell = current_world.cells[player.cursor.y][player.cursor.x]

        cell.explored = true

        if input == SELECT then
            player_interact(player, cell)
        end

        if input == SPACE then
            print("YES")
        end

    end

    player.input = nil

end

function player_interact (player, cell)
    decrement(player, "b", 1, 0)

    if cell.middle ~= true then
        table.insert(player.path, {
            world = cell,
            entrance = {
                x = player.cursor.x,
                y = player.cursor.y
            }
        })

        player.cursor.x = game.constants.center_x
        player.cursor.y = game.constants.center_y
    else
        if #(player.path) == 1 then
            -- pass the day
            game.state.daylight = game.constants.daylight_max
            game.state.is_day = true

            if game.state.is_day == true then
                decrement(player, "g", 1, 0)
            end
        else
            -- explore more deeply
            local entrance = player.path[#(player.path)].entrance
            table.remove(player.path)

            player.cursor.x = entrance.x
            player.cursor.y = entrance.y
        end
    end
end

function player_move (player, input)
    if input == UP then player.cursor.y = player.cursor.y - 1; did_move = true end
    if input == DOWN then player.cursor.y = player.cursor.y + 1; did_move = true end
    if input == LEFT then player.cursor.x = player.cursor.x - 1; did_move = true end
    if input == RIGHT then player.cursor.x = player.cursor.x + 1; did_move = true end

    decrement(player, "b", 1, 0)
end

function time_update (player) 
    local length = #(player.path)

    if game.state.is_day == true then
        if game.state.daylight > 0 then
            if length == 1 then
                decrement(game.state, "daylight", 2, 0)
            elseif length == 2 then
                decrement(game.state, "daylight", 1, 0)
            elseif length > 2 then

            end
        else
            game.state.is_day = false
        end
    else
        decrement(player, "r", 1, 0)

        if game.state.daylight < game.constants.daylight_max then
            if length == 1 then
                increment(game.state, "daylight", 2, game.constants.daylight_max)
            elseif length == 2 then
                increment(game.state, "daylight", 1, game.constants.daylight_max)
            elseif length > 2 then

            end
        else
            game.state.is_day = true
        end
    end
end
