local pl = Native.PlayerId()

Thread:new(function()
    while true do 
        Native.RestorePlayerStamina(pl, 100)
        Thread:Wait(5000)
    end
end)