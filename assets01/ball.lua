local script = require('scriptcomponent'):derive()
local config = require('config')
local game_state = require('game_state')

function script:on_init()
    -- Register self in game state
    game_state.ball_script = self
    
    -- Ball physics state
    self.x = 0
    self.y = 0
    self.vx = 0
    self.vy = 0
    self.active = false
    
    log("Ball initialized at center position")
    
    -- Set initial position
    local transform = getcomponent(self.entity, "transform")
    if transform then
        transform.translation = vec3(self.x, self.y, 0)
    end
    
    -- Cache input for serve
    self.space_key = Input.getbuttonidforname("SPACE")

    -- Cache paddle half height
    self.paddle_half_height = config.paddle.height / 2 
end

function script:reset_ball()
    self.active = false
    self.x = 0
    self.y = 0
    self.vx = 0
    self.vy = 0
    
    -- Update transform
    local transform = getcomponent(self.entity, "transform")
    if transform then
        transform.translation = vec3(self.x, self.y, 0)
    end
    
    log("Ball reset to center")
end

function script:serve_ball(direction)
    self.active = true
    
    -- Random angle using configured range
    local angle_degrees = (engine.math.random() - 0.5) * config.ball.serve_angle_range
    local angle = engine.math.deg2rad(angle_degrees)
    
    -- Serve in specified direction
    self.vx = direction * math.cos(angle) * config.ball.initial_speed
    self.vy = math.sin(angle) * config.ball.initial_speed
    
    log(string.format("Ball served! Direction: %d, Velocity: (%.3f, %.3f)", 
        direction, self.vx, self.vy))
end

function script:check_paddle_collision(paddle_script, paddle_x)
	-- Get paddle position
	local paddle_y = paddle_script.y

	engine.logger.debug(string.format("COLLISION CHECK: ball=(%.3f,%.3f) paddle=(%.3f,%.3f)", self.x, self.y, paddle_x, paddle_y))

	-- Create ball sphere
	local ball_sphere = sphere(vec3(self.x, self.y, 0), config.ball.radius)

	-- Create paddle AABB
	local paddle_aabb = aabb(
		vec3(paddle_x - config.paddle.width / 2, paddle_y - self.paddle_half_height, 0),
		vec3(paddle_x + config.paddle.width / 2, paddle_y + self.paddle_half_height, 0)
	)

	if ball_sphere:intersects(paddle_aabb) then
		--  Calculate hit position on paddle (-1 to 1, where 0 is center)
		local hit_pos = (self.y - paddle_y) / self.paddle_half_height
		hit_pos = engine.math.clamp(hit_pos, -1, 1)

		-- Reverse horizontal direction
		self.vx = -self.vx

        -- Add vertical component based on hit position
        local angle_factor = hit_pos * 0.5  -- Max 50% angle change
		self.vy = self.vy + angle_factor * math.abs(self.vx)

        -- Increase speed slightly using engine vector math
		-- Create a reusable velocity vector
		local velocity = vec2(self.vx, self.vy)

		-- Compute magnitude once
		local current_speed = velocity:magnitude()
		local new_speed = math.min(current_speed * config.ball.speed_increase, config.ball.max_speed)

        -- Normalize and apply new speed using vector operations
		if current_speed > 0 then
			local inv_mag = 1 / current_speed

			-- Normalize and scale
			velocity = velocity:multiply(inv_mag):multiply(new_speed)

			self.vx = velocity.x
			self.vy = velocity.y
		end

        -- Move ball away from paddle to prevent multiple collisions
		if paddle_x < 0 then
            -- Left paddle
			self.x = paddle_x + config.paddle.width / 2 + config.ball.radius
		else
            -- Right paddle
			self.x = paddle_x - config.paddle.width / 2 - config.ball.radius
		end

		log(string.format("Paddle hit! Hit position: %.3f, New velocity: (%.3f, %.3f)",
			hit_pos, self.vx, self.vy))

		return true
	end

	return false
end

function script:on_message(msg, data)
    if msg == "reset_ball" then
        self:reset_ball()
    elseif msg == "serve_ball" then
        self:serve_ball(data.direction or 1)
    end
end

function script:on_update()
    -- Check if game is over
    if game_state.game_over then
        return
    end
    
    -- Handle serving
    if not self.active and not game_state.serving then
        if Input.getbutton(self.space_key) > 0 then
            self:serve_ball(engine.math.random() > 0.5 and 1 or -1)
        end
        return
    end
    
    if self.active then
        local dt = Time.deltaTime
        
        -- Update position using vector math
        local position = vec2(self.x, self.y)
        local velocity = vec2(self.vx, self.vy)
        local delta_position = velocity:multiply(dt)
        local new_position = position:add(delta_position)
        self.x = new_position.x
        self.y = new_position.y
        
        -- Top and bottom wall collisions
        if self.y + config.ball.radius >= config.PLAY_AREA.top then
            self.y = config.PLAY_AREA.top - config.ball.radius
            self.vy = -math.abs(self.vy)
        elseif self.y - config.ball.radius <= config.PLAY_AREA.bottom then
            self.y = config.PLAY_AREA.bottom + config.ball.radius
            self.vy = math.abs(self.vy)
        end
        
        -- Paddle collisions
        local left_paddle = game_state.left_paddle_script
        local right_paddle = game_state.right_paddle_script
        
        -- Paddle collisions
        if left_paddle and self.vx < 0 then
            self:check_paddle_collision(left_paddle, config.paddle.left_x)
        elseif right_paddle and self.vx > 0 then
            self:check_paddle_collision(right_paddle, config.paddle.right_x)
        end
        
        -- Score when ball goes off sides
        if self.x < config.PLAY_AREA.left then
            -- Right player scores
            broadcast("point_scored", {player = "right"})
            self:reset_ball()
        elseif self.x > config.PLAY_AREA.right then
            -- Left player scores
            broadcast("point_scored", {player = "left"})
            self:reset_ball()
        end
    end
    
    -- Update transform
    local transform = getcomponent(self.entity, "transform")
    if transform then
        transform.translation = vec3(self.x, self.y, 0)
    end
end

return script