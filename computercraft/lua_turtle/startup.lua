os.loadAPI("json.lua")
os.loadAPI("tst.lua")
local port = "8887"
local ws,err = http.websocket("ws://localhost:"..port)
print(err)

function loop()
    local msg = ws.receive()
    print(msg)
    local obj = json.decode(msg)
    if obj ~= nil then
        exec(obj)
    else
        print("could not decode")
    end
end

function exec(obj)
    local func = loadstring(obj["func"])
    func()
end

if ws then
    while true do
        loop()
    end
end
