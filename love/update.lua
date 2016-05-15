function love.update(dt)

    --Update here
    local player = game.player

    if player.input ~= nil then
        local input = player.input

        if input == UP then player.cursor.y = player.cursor.y - 1 end
        if input == DOWN then player.cursor.y = player.cursor.y + 1 end
        if input == LEFT then player.cursor.x = player.cursor.x - 1 end
        if input == RIGHT then player.cursor.x = player.cursor.x + 1 end

    end

    player.input = nil

end
