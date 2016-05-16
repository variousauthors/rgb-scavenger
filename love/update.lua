function love.update(dt)

    --Update here
    local player = game.player

    if player.input ~= nil then
        local input = player.input

        if input == UP then player.cursor.y = player.cursor.y - 1 end
        if input == DOWN then player.cursor.y = player.cursor.y + 1 end
        if input == LEFT then player.cursor.x = player.cursor.x - 1 end
        if input == RIGHT then player.cursor.x = player.cursor.x + 1 end

        local current_world = player.path[#(player.path)].world
        local cell = current_world.cells[player.cursor.y][player.cursor.x]

        cell.explored = true

        if input == SELECT then

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
                    -- NOP
                else
                    local entrance = player.path[#(player.path)].entrance
                    table.remove(player.path)

                    player.cursor.x = entrance.x
                    player.cursor.y = entrance.y
                end
            end
        end

    end

    player.input = nil

end
