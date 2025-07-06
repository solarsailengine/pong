-- Math utility functions for Pong game
local math_utils = {}

-- Clamp a value between min and max
function math_utils.clamp(value, min_val, max_val)
    return math.max(min_val, math.min(value, max_val))
end

return math_utils