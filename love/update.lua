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
        end

        local current_world = player.path[#(player.path)].world
        local cell = current_world.cells[player.cursor.y][player.cursor.x]

        cell.explored = true

        if input == SELECT then
            player_explore(player, cell)
        end

        if input == SPACE then
            player_interact(player, cell)
        end

    end

    player.input = nil

end

function player_interact (player, cell)
    local inventory = player.carry.inventory

    if cell.middle == true then
        local store = player.store.inventory

        while (#(store) < player.store.max and #(inventory) > 0) do
            -- transfer one item

            local item = inventory[1]
            table.remove(inventory, 1)
            table.insert(store, item)
        end

        return
    end

    if #(inventory) >= player.carry.max then return end

    local rand = math.random()
    local ratios = cell.ratios
    local r, g, b = ratios.r, ratios.g, ratios.b

    if rand <= r then
        table.insert(inventory, RED)
    elseif rand <= r + g then
        table.insert(inventory, GREEN)
    elseif rand > g then
        table.insert(inventory, BLUE)
    end
end

function player_consume (player, resource, amount)
    local index = first_index_of(player.carry.inventory, resource)

    if index ~= -1 then
        table.remove(player.carry.inventory, index)
    else
        decrement(player, resource, 1, 0)
    end
end

function player_recover (player, resource)
    local inventory = player.store.inventory

    for i = #(inventory), 1, -1 do
        local item = inventory[i]

        if player[item] < game.constants.stat_max then
            increment(player, item, 1, game.constants.stat_max)

            table.remove(inventory, i)
        end
    end
end

function player_explore (player, cell)
    player_consume(player, BLUE, 1)

    if cell.middle ~= true then
        -- zoom into a cell
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

            player_consume(player, GREEN, 1)

            -- recover from store

            player_recover(player)
        else
            -- zoom out of a cell
            local entrance = player.path[#(player.path)].entrance
            table.remove(player.path)

            player.cursor.x = entrance.x
            player.cursor.y = entrance.y
        end
    end
end

function player_move (player, input)
    local did_move = false

    if input == UP then player.cursor.y = player.cursor.y - 1; did_move = true end
    if input == DOWN then player.cursor.y = player.cursor.y + 1; did_move = true end
    if input == LEFT then player.cursor.x = player.cursor.x - 1; did_move = true end
    if input == RIGHT then player.cursor.x = player.cursor.x + 1; did_move = true end

    if did_move == true then
        player_consume(player, BLUE, 1)

        local length = #(player.path)

        if length == 1 then
            time_update(player, 2)
        elseif length == 2 then
            time_update(player, 1)
        elseif length > 2 then
            -- time dilation: while inside the player does not pass time to take actions
        end
    end
end

function time_update (player, time) 
    local length = #(player.path)

    if game.state.is_day == true then
        if game.state.daylight > game.constants.daylight_min then
            decrement(game.state, DAYLIGHT, time, game.constants.daylight_min)
        else
            game.state.is_day = false
        end
    else
        if game.state.daylight < game.constants.daylight_max then
            increment(game.state, DAYLIGHT, time, game.constants.daylight_max)
            player_consume(player, RED, 1)
        else
            game.state.is_day = true
        end
    end
end
