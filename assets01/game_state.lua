-- Pong Game State - shared state between scripts
local game_state = {}

-- Paddle references
game_state.left_paddle_script = nil
game_state.right_paddle_script = nil
game_state.ball_script = nil
game_state.game_controller_script = nil

-- Game state
game_state.left_score = 0
game_state.right_score = 0
game_state.game_over = false
game_state.winner = nil
game_state.serving = false
game_state.serve_timer = 0

return game_state