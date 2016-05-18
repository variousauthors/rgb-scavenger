love.viewport = require('libs/viewport').newSingleton()

function love.draw ()
    love.graphics.push()
    love.graphics.scale(game.constants.scale, game.constants.scale)
    -- Draw here

    world_draw(game.player)

    status_draw(game.player)

    love.graphics.pop()
end

function world_draw (player)
    love.graphics.push()
    local length = #(player.path)

    for i = 1, length, 1 do

        local world = player.path[i].world

        board_draw(world.cells)

        if i == length then
            cursor_draw(game.player.cursor)
        end

        love.graphics.translate(50, 0)
    end
    love.graphics.pop()
end

function status_draw (player)
    love.graphics.push()

    local indicator = game.constants.indicator
    local base_y = 50
    local increment = 9

    for i = 1, player.r, 1 do
        love.graphics.setColor(RGB_COLORS[RED])
        love.graphics.rectangle("fill", (i - 1)*indicator.w + i, base_y, indicator.w, indicator.h)
    end

    love.graphics.setColor(RGB_COLORS[WHITE])
    love.graphics.rectangle("fill", (player.r_thresh - 1)*indicator.w + player.r_thresh + 1, base_y - 2, 1, 1)

    for i = 1, player.g, 1 do
        love.graphics.setColor(RGB_COLORS[GREEN])
        love.graphics.rectangle("fill", (i - 1)*indicator.w + i, base_y + increment, indicator.w, indicator.h)
    end

    love.graphics.setColor(RGB_COLORS[WHITE])
    love.graphics.rectangle("fill", (player.g_thresh - 1)*indicator.w + player.g_thresh + 1, base_y + increment - 2, 1, 1)

    for i = 1, player.b, 1 do
        love.graphics.setColor(RGB_COLORS[BLUE])
        love.graphics.rectangle("fill", (i - 1)*indicator.w + i, base_y + 2*increment, indicator.w, indicator.h)
    end

    love.graphics.setColor(RGB_COLORS[WHITE])
    love.graphics.rectangle("fill", (player.b_thresh - 1)*indicator.w + player.b_thresh + 1, base_y + 2*increment - 2, 1, 1)

    for i = 1, game.state.daylight, 1 do
        love.graphics.setColor(RGB_COLORS[WHITE])
        love.graphics.rectangle("fill", (i - 1) + i, base_y + 3*increment, 1, 1)
    end

    base_x = game.constants.stat_max * indicator.w + game.constants.stat_max + 2

    love.graphics.setColor(RGB_COLORS[WHITE])
    love.graphics.rectangle("line", base_x, base_y + 0.5, player.store.w * (indicator.w) + player.store.w + 1, player.store.h * (indicator.h) + player.store.h + 1)

    for i = 0, #(player.store.inventory) - 1, 1 do
        local ix = (i % player.store.w)
        local iy = math.floor(i / player.store.w)

        print(i, ix, iy)
        love.graphics.setColor(RGB_COLORS[BLUE])
        love.graphics.rectangle("fill", base_x + ix * indicator.w + ix + 1, base_y + (iy * indicator.h) + iy + 1.5, indicator.w, indicator.h)
    end

    base_x = base_x + player.store.w * (indicator.w) + player.store.w + 3

    love.graphics.setColor(RGB_COLORS[WHITE])
    love.graphics.rectangle("line", base_x, base_y + 0.5, player.carry.w * (indicator.w), player.carry.h * (indicator.h))



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

            if cell.explored == true then
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
            else
                love.graphics.setColor({ cell.r, cell.g, cell.b })
                love.graphics.rectangle('fill', x, y, dim, dim)
            end

        end
    end

    love.graphics.pop()
end
