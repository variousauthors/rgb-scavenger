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
            -- consume 0.5 BLUE
            -- spend time based on zoom level
        end

        local current_world = player.path[#(player.path)].world
        local cell = current_world.cells[player.cursor.y][player.cursor.x]

        cell.explored = true

        if input == EXPLORE then
            player_explore(player, cell)
            -- at home: eat and sleep
            --   consumes 1 GREEN
            --   heals from store
            -- outside: explore
            --   goes deeper
        end

        if input == INTERACT then
            player_interact(player, cell)
            -- at home: drop carry
            -- outside: get items
            --   spend 1 time
        end

    end

    player.input = nil
end

function player_store_items (player)
    local inventory = player.carry.inventory
    local store = player.store.inventory

    while (#(store) < player.store.max and #(inventory) > 0) do
        -- transfer one item

        local item = inventory[1]
        table.remove(inventory, 1)
        table.insert(store, item)
    end
end

function player_collect_items (player, cell)
    local inventory = player.carry.inventory
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

function player_interact (player, cell)
    if cell.middle == true then
        if #(player.path) == 1 then
            player_store_items(player)
        end
    else
        player_collect_items(player, cell)
        time_update(player, 1)
    end
end

function player_consume (player, resource)
    local index = first_index_of(player.carry.inventory, resource)

    if resource == BLUE then
        if player.thirsty == true then
            player.thirsty = false
        else
            player.thirsty = true
            return
        end
    end

    if index ~= -1 then
        table.remove(player.carry.inventory, index)
    else

        if player[resource] < player.thresh[resource] then
            if resource == RED then
                error("YOU DIED")
            else
                player_consume(player, RED)
            end
        end

        decrement(player, resource, 1, 0)

    end
end

function player_recover (player, collection)

    for i = #(collection), 1, -1 do
        local item = collection[i]

        if player[item] < game.constants.stat_max then
            increment(player, item, 1, game.constants.stat_max)

            table.remove(collection, i)
        end
    end
end

function player_explore (player, cell)

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

            player_consume(player, GREEN)

            -- recover from store

            player_recover(player, player.store.inventory)
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
        player_consume(player, BLUE)

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
            player_consume(player, RED)
        else
            game.state.is_day = true
        end
    end
end
