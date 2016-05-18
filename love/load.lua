RED = "red"
GREEN = "green"
BLUE = "blue"
WHITE = "white"

UP = "up"
DOWN = "down"
LEFT = "left"
RIGHT = "right"

SELECT = "select"
ESCAPE = "escape"
SPACE = "space"

TOP = { x = -1, y = -1 }

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
        r_max = 10,
        g_max = 10,
        b_max = 10,
        indicator = {
            w = 3,
            h = 5,
        },
        daylight_max = 20,
        stat_max = 10,
    }

    game.constants.center_x = math.ceil(game.constants.width / 2)
    game.constants.center_y = math.ceil(game.constants.height / 2)

    game.world = { }
    game.state = { 
        daylight = game.constants.daylight_max,
        is_day = true,
    }

    game.world = build_world(game.constants.width, game.constants.height, 2)

    game.player = {
        r = game.constants.stat_max,
        r_thresh = 1,
        g = game.constants.stat_max,
        g_thresh = 6,
        b = game.constants.stat_max,
        b_thresh = 3,
    }

    game.player.carry = {
         w = 2,
         h = 4,
         inventory = { },
    }
    game.player.carry.max = game.player.carry.w * game.player.carry.h

    game.player.store = {
         w = 6,
         h = 4,
         inventory = { },
    }
    game.player.store.max = game.player.store.w * game.player.store.h

    game.player.path = { 
        {
            world = game.world, 
            entrance = { x = -1, y = -1 } 
        }
    }
    game.player.cursor = {
        x = game.constants.center_x,
        y = game.constants.center_y,
    }
end

function board_get_average_rates (board)
    local avgs = {}
    local sums = {r = 0, g = 0, b = 0 }
    local total = board.height * board.width

    for y = 1, board.height, 1 do
        for x = 1, board.width, 1 do
            local cell = board[y][x]

            sums.r = sums.r + cell.r
            sums.g = sums.g + cell.g
            sums.b = sums.b + cell.b
        end
    end

    avgs.r = (sums.r / total) / 255
    avgs.g = (sums.g / total) / 255
    avgs.b = (sums.b / total) / 255

    return avgs
end

function build_world (width, height, depth, rates)
    local rates = rates or { r = 1, g = 1, b = 1 }
    local world = {}

    world.cells = build_board(width, height, rates)
    world.height = world.cells.height
    world.width = world.cells.width
    world.depth = depth

    if depth > 0 then

        for y = 1, height, 1 do
            for x = 1, width, 1 do
                local cell = world.cells[y][x]
                local subworld = build_world(width, height, depth - 1, cell.ratios)

                subworld_extend(subworld, cell)

                world.cells[y][x] = subworld
            end
        end
    end

    return world
end

function subworld_extend (subworld, cell)
    subworld.r = cell.r
    subworld.g = cell.g
    subworld.b = cell.b
    subworld.middle = cell.middle
    subworld.explored = cell.explored
    subworld.ratios = cell.ratios
end

function build_board (width, height, rates)
    local board = {}

    for y = 1, height, 1 do
        board[y] = {}

        for x = 1, width, 1 do
            local cell = {
                r = math.random(255) * rates.r,
                g = math.random(255) * rates.g,
                b = math.random(255) * rates.b,
                middle = false,
                explored = false,
            }

            if y == math.ceil(height/2) and x == math.ceil(width/2) then
                cell.r = 0
                cell.g = 0
                cell.b = 0

                cell.middle = true
                cell.explored = true
            end

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
