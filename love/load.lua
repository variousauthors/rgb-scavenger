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

    game.world = build_world(game.constants.width, game.constants.height, 1)

    game.player = {}
    game.player.cursor = {
        x = math.ceil(game.constants.width / 2),
        y = math.ceil(game.constants.height / 2),
    }
end

function board_get_average_values (board)
    local avgs = {}
    local sums = {r = 0, g = 0, b = 0 }
    local total = board.height * board.width

    print("board", inspect(board))
    print("board[y]", inspect(board[1]))
    print("board[1][1]", inspect(board[1][1]))

    for y = 1, board.height, 1 do
        for x = 1, board.width, 1 do
            local cell = board[y][x]

            sums.r = sums.r + cell.r
            sums.g = sums.g + cell.g
            sums.b = sums.b + cell.b
        end
    end

    avgs.r = sums.r / total
    avgs.g = sums.g / total
    avgs.b = sums.b / total

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
                local avgs = board_get_average_values(world.cells)
                local cell = world.cells[y][x]
                local subworld = build_world(width, height, depth - 1, avgs)

                subworld.r = cell.r
                subworld.g = cell.g
                subworld.b = cell.b
                subworld.ratios = cell.ratios

                world.cells[y][x] = subworld
            end
        end
    end

    return world
end

function build_board (width, height, rates)
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
