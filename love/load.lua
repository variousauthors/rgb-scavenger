RED = "red"
GREEN = "green"
BLUE = "blue"
WHITE = "white"

UP = "up"
DOWN = "down"
LEFT = "left"
RIGHT = "right"

RGB_COLORS = {
    red = { 255, 0, 0 },
    green = { 0, 255, 0 },
    blue = { 0, 0, 255 },
    white = { 255, 255, 255 },
}

function love.load()
    require('game/controls')
    require('game/sounds')

    game.constants = { 
        width = 5,
        height = 5,
        cell_dim = 5,
        cell_gutter = 3,
        scale = 4,
    }
    game.world = { }
    game.state = { }

    game.world = build_world(game.constants.width, game.constants.height, 0)

    game.player = {}
    game.player.cursor = {
        x = math.ceil(game.world.width / 2),
        y = math.ceil(game.world.height / 2),
    }
end

function build_world (width, height, depth)
    local world

    if depth == 0 then
        world = build_board(width, height)
    else
        world = {}

        for y = 1, height, 1 do
            world[y] = {}

            for x = 1, width, 1 do
                world[y][x] = build_world(width, height, depth - 1)

                -- TODO each world cell also needs its r, g, b and ratio values
                -- but these will be averaged across the cells it contains
                -- so iteratenover world[y][x]'s cells and average their rgb ratios
            end
        end
    end

    world.depth = depth

    return world
end

function build_board (width, height)
    local board = {}

    for y = 1, height, 1 do
        board[y] = {}

        for x = 1, width, 1 do
            local cell = {
                r = math.random(255),
                g = math.random(255),
                b = math.random(255),
            }

            local total = cell.r + cell.g + cell.b

            cell.ratios = {
                r = cell.r / total,
                g = cell.g / total,
                b = cell.b / total,
            }

            board[y][x] = cell
        end
    end

    board.height = height
    board.width = width

    return board
end
