-- Pong Game Configuration
local config = {}

-- Play area bounds (normalized coordinates)
config.PLAY_AREA = {
    left = -1.5,
    right = 1.5,
    top = 1.0,
    bottom = -1.0
}

-- Paddle configuration
config.paddle = {
    width = 0.05,
    height = 0.3,
    speed = 1.5,
    -- Left paddle position
    left_x = -1.2,
    -- Right paddle position  
    right_x = 1.2
}

-- Ball configuration
config.ball = {
    radius = 0.03,
    initial_speed = 0.8,
    max_speed = 2.5,
    speed_increase = 1.05,  -- Speed multiplier on paddle hit
    serve_angle_range = 60  -- Max serve angle in degrees (±30 degrees)
}

-- Game configuration
config.game = {
    win_score = 11,  -- First to 11 points wins
    serve_delay = 2.0  -- Delay between points
}

-- Colors (RGBA)
config.colors = {
    paddle = {1, 1, 1, 1},  -- White
    ball = {1, 1, 1, 1},    -- White
    background = {0, 0, 0, 1}  -- Black
}

return config