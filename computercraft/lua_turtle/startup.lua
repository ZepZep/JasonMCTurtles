os.loadAPI("json.lua")
os.loadAPI("tst.lua")

local port = "8887"
local addr = "ws://localhost:"..port
local retry_time = 1

function term_back()
    local xPos, yPos = term.getCursorPos()
    term.setCursorPos(1, yPos-1)
end

function print_color(msg, color)
    local old = term.getTextColor()
    term.setTextColour(color)
    print(msg)
    term.setTextColour(old)
end

function loop(ws)
    local ok, msg = pcall(ws.receive)
--     print(msg)
    if not ok or not msg then
        if msg == "Terminated" then
            error(msg)
        end
        return false, "Receive failed: " .. tostring(msg)
    end
    local obj = json.decode(msg)
    if obj ~= nil then
        exec(obj, ws)
    else
        print(" unk: " .. msg)
    end
    return true
end

function exec(obj, ws)
    local func = loadstring(obj["func"])
    local out, err = func()
    if obj["sync"] then
        local msg = json.encode({
            finished=obj["func"], out=out, err=err
        })
        pcall(function () ws.send(msg) end)
    end
end

function connect()
    local counter = 1
    print()
    while true do
        local ws, err = http.websocket(addr)
        if err then
            term_back()
            print(" " .. err .. " " .. tostring(counter))
            counter = counter + 1
            sleep(retry_time)
        else
            return ws;
        end
    end
end


function hello()
    term.clear()
    term.setCursorPos(1,1)
    print_color("Jason turtle agent v.0.42", colors.orange)
end

function calibrate()
    print(" Getting location with GPS")
    if not tst.calibrate() then
        error("Failed to calibrate")
    end
    print("   Located at " .. tst.fullLocate())
end

hello()
calibrate()

while true do
    local ws = connect()
    local ok = true
    local err
    while ok do
        ok, err = loop(ws)
    end
    print_color(err, colors.red)
    ws.close()
    print(" Reconnecting")
end
