-- utils/logger.lua
local Logger = {}

Logger.debug = false

local colors = {
    info = "^3[INFO]^0 ",
    error = "^1[ERROR]^0 ",
    success = "^2[SUCCESS]^0 ",
    warning = "^3[WARN]^0 ",
    reset = "^0"
}

function Logger.log(level, message, ...)
    if not Logger.debug then return end
    level = level or "info"

    local prefix = colors[level] or colors.info
    local finalMessage = message

    -- Si le message contient des formats
    if select("#", ...) > 0 then
        local success, formatted = pcall(string.format, message, ...)
        finalMessage = success and formatted or message
    end

    print(prefix .. finalMessage .. colors.reset)
end

return Logger
