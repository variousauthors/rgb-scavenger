love.viewport = require('libs/viewport').newSingleton()

function love.draw ()
    love.graphics.push()
    love.graphics.scale(game.constants.scale, game.constants.scale)
    -- Draw here

    board_draw(game.world)

    cursor_draw(game.player.cursor)

    love.graphics.pop()
end

function cursor_draw (cursor)
    love.graphics.push()

    local x = cursor.x
    local y = cursor.y
    local dim = game.constants.cell_dim
    local offset = game.constants.cell_gutter

    -- add a teensy bit to the rectangle size
    x = (x - 1) * dim + (x * offset) - 1
    y = (y - 1) * dim + (y * offset) - 1
    w = dim + 2
    h = dim + 2

    love.graphics.setColor(RGB_COLORS[WHITE])
    love.graphics.rectangle('line', x, y, w, h)

    love.graphics.pop()
end

function board_draw (board)
    love.graphics.push()

    for y = 1, board.height, 1 do
        for x = 1, board.width, 1 do
            local cell = board[y][x]
            local dim = game.constants.cell_dim
            local offset = game.constants.cell_gutter
            local y = (y - 1) * dim + (y * offset)
            local x = (x - 1) * dim + (x * offset)

            local r_width = dim * cell.ratios.r
            local g_width = dim * cell.ratios.g
            local b_width = dim * cell.ratios.b

            love.graphics.setColor(RGB_COLORS[RED])
            local pos_x = x + 0

            love.graphics.rectangle('fill', pos_x, y, r_width, dim)

            love.graphics.setColor(RGB_COLORS[GREEN])
            pos_x = pos_x + r_width

            love.graphics.rectangle('fill', pos_x, y, g_width, dim)

            love.graphics.setColor(RGB_COLORS[BLUE])
            pos_x = pos_x + g_width

            love.graphics.rectangle('fill', pos_x, y, b_width, dim)
            pos_x = pos_x + b_width

        end
    end

    love.graphics.pop()
end
