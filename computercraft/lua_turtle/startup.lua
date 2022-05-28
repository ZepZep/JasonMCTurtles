os.loadAPI("json.lua")
os.loadAPI("tst.lua")
os.loadAPI("inv.lua")
os.loadAPI("jconfig.lua")


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
            os.setComputerLabel("[terminated]")
            error("Terminated")
        end
        return false, "Receive failed: " .. tostring(msg)
    end
    local obj = json.decode(msg)
    if obj ~= nil then
        exec(obj, ws)
    else
        if string.sub(msg, 0, 9) == "Connected" then
            local label = string.sub(msg, 14)
            os.setComputerLabel(label)
            print("  "..msg)
        elseif msg == "Acknowledged." then
            os.setComputerLabel("[ack]")
            print("  "..msg)
        else
            print(" unk: " .. msg)
        end
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
        local myheaders = {
            turtleid=tostring(os.getComputerID()),
            turtlechannel=tostring(jconfig.channel)
        }
        local ws, err = http.websocket(addr, myheaders)
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
    print(" turtle: "..os.getComputerID().." channel: "..jconfig.channel)
end

function checkFuel()
    if (turtle.getFuelLevel() == 0) then
        print("   Out of fuel, trying to refuel")
        turtle.select(16)
        turtle.refuel()
    end
end

function calibrate()
    print(" Getting location with GPS")
    if not tst.calibrate() then
        print_color("   Failed to calibrate", colors.red)
    else
        print("   Located at " .. tst.fullLocate())
    end
end

hello()
checkFuel()
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
    os.setComputerLabel("[...]")
    print(" Reconnecting")
end
