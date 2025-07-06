local script = require('scriptcomponent'):derive()
local config = require('config')
local math_utils = require('math_utils')

function script:on_init()
    -- Register self in game state based on transform position
    local game_state = require('game_state')
    
    -- Get transform to determine which paddle this is
    local transform = getcomponent(self.entity, "transform")
    if transform then
        local x = transform.translation.x
        
        -- Determine paddle side from X position
        if x < 0 then
            -- Left paddle
            self.is_left = true
            game_state.left_paddle_script = self
            self.x_position = config.paddle.left_x
            -- Cache input keys for W/S controls
            self.up_key = Input.getbuttonidforname("W")
            self.down_key = Input.getbuttonidforname("S")
            log("Left paddle initialized")
        else
            -- Right paddle
            self.is_left = false
            game_state.right_paddle_script = self
            self.x_position = config.paddle.right_x
            -- Cache input keys for Up/Down controls
            self.up_key = Input.getbuttonidforname("UP")
            self.down_key = Input.getbuttonidforname("DOWN")
            log("Right paddle initialized")
        end
    end
    
    -- Initialize paddle position
    self.y = 0  -- Center vertically
    
    -- Cache frequently used values
    self.half_height = config.paddle.height * 0.5
    
    -- Set initial position
    if transform then
        transform.translation = vec3(self.x_position, self.y, 0)
    end
end

function script:on_update()
    local dt = Time.deltaTime
    local movement = 0
    
    -- Check for input
    if Input.getbutton(self.up_key) > 0 then
        movement = config.paddle.speed * dt  -- Move up
    elseif Input.getbutton(self.down_key) > 0 then
        movement = -config.paddle.speed * dt  -- Move down
    end
    
    -- Apply movement
    if movement ~= 0 then
        self.y = self.y + movement
        
        -- Keep paddle within play area bounds using clamp utility
        self.y = math_utils.clamp(self.y, 
                                 config.PLAY_AREA.bottom + self.half_height,
                                 config.PLAY_AREA.top - self.half_height)
        
        -- Update transform
        local transform = getcomponent(self.entity, "transform")
        if transform then
            transform.translation = vec3(self.x_position, self.y, 0)
        end
    end
end

return script