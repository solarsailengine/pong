local script = require('scriptcomponent'):derive()
local config = require('config')
local game_state = require('game_state')

function script:on_init()
    -- Register self in game state
    game_state.game_controller_script = self
    
    -- Initialize scores
    game_state.left_score = 0
    game_state.right_score = 0
    game_state.game_over = false
    game_state.winner = nil
    game_state.serving = false
    game_state.serve_timer = 0
    
    log("Game controller initialized")
    log("Controls: Left paddle (W/S), Right paddle (Up/Down), Serve (Space)")
    log("First to " .. config.game.win_score .. " points wins!")
end

function script:on_message(msg, data)
    if msg == "point_scored" then
        local player = data.player
        
        if player == "left" then
            game_state.left_score = game_state.left_score + 1
            log("Left player scores! Score: " .. game_state.left_score .. " - " .. game_state.right_score)
        elseif player == "right" then
            game_state.right_score = game_state.right_score + 1
            log("Right player scores! Score: " .. game_state.left_score .. " - " .. game_state.right_score)
        end
        
        -- Check for win condition
        if game_state.left_score >= config.game.win_score then
            game_state.game_over = true
            game_state.winner = "left"
            log("GAME OVER! Left player wins " .. game_state.left_score .. " - " .. game_state.right_score .. "!")
        elseif game_state.right_score >= config.game.win_score then
            game_state.game_over = true
            game_state.winner = "right"
            log("GAME OVER! Right player wins " .. game_state.right_score .. " - " .. game_state.left_score .. "!")
        else
            -- Start serve delay
            game_state.serving = true
            game_state.serve_timer = config.game.serve_delay
        end
    end
end

function script:on_update()
    -- Handle serve timer with engine math safety
    if game_state.serving then
        game_state.serve_timer = math.max(0, game_state.serve_timer - Time.deltaTime)
        
        if game_state.serve_timer <= 0 then
            game_state.serving = false
            log("Ready to serve! Press Space to serve the ball.")
        end
    end
    
    -- Handle game restart
    if game_state.game_over then
        -- You could add restart logic here with R key or similar
    end
end

return script