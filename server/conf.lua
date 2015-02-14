is_client = false
enable_console = true

config = {
    public = true,
    port = 6788,
    max_peers = 64,
    max_down = 0,
    max_up = 0
}

function love.conf(t)
    t.identity = "ss13-server"
    t.version = "0.9.1"
    t.console = enable_console

    t.modules.audio    = false
    t.modules.font     = false
    t.modules.graphics = false
    t.modules.image    = false
    t.modules.joystick = false
    t.modules.keyboard = false
    t.modules.mouse    = false
    t.modules.physics  = false
    t.modules.sound    = false
    t.modules.window   = false
end
