os.loadAPI("json.lua")

local empty ={ name="empty", count=0 }

function checkSlots_(l, r)
    local prev_slot = turtle.getSelectedSlot()
    local slots = {}
    for i = l,r do
        turtle.select(i)
        local detail = turtle.getItemDetail()
        if detail == nil then
            detail = { name="empty", count=0 }
        end
        slots[tostring(i)] = detail
--         slots[tostring(i)] = { name="empty", count=0 }

    end
    turtle.select(prev_slot)
    return slots
end

function checkSlots()
    return checkSlots_(1, 16)
end

function checkSlot(i)
    return checkSlots_(i, i)
end
