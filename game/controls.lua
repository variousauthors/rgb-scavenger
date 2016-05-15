-- Just an example to help

local controls = {
    select = {'k_return', 'j1_a'},
    up = { 'k_w', 'k_up' },
    down = { 'k_s', 'k_down' },
    left = { 'k_a', 'k_left' },
    right = { 'k_d', 'k_right' },
}

love.inputman.setStateMap(controls)
