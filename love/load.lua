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
        scale = 5,
    }
    game.world = { }
    game.state = { }

    game.world.board = build_board(game.constants.width, game.constants.height)

    game.player = {}
    game.player.cursor = {
        x = math.ceil(game.world.board.width / 2),
        y = math.ceil(game.world.board.height / 2),
    }
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
