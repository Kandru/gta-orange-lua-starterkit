local pl = Native.PlayerPedId()
local camshaketype = {'DEATH_FAIL_IN_EFFECT_SHAKE','DRUNK_SHAKE','FAMILY5_DRUG_TRIP_SHAKE','HAND_SHAKE'}
local deathmessage = 'WASTED'

Thread:new(function()
	while true do
		if Native.IsEntityDead(pl) then
			Native.StartScreenEffect('DeathFailOut', 5000, 0)
			Native.PlaySoundFrontend(-1, 'Bed', 'WastedSounds', 1)
			local scaleform = Native.RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')
			while not 
				Native.HasScaleformMovieLoaded(scaleform) do Thread:Wait()
			end
			Native.PushScaleformMovieFunction(scaleform, 'SHOW_SHARD_WASTED_MP_MESSAGE')
			Native.BeginTextComponent('STRING')
			Native.AddTextComponentString(deathmessage)
			Native.EndTextComponent()
			Native.PopScaleformMovieFunctionVoid()
			Native.ShakeGameplayCam(camshaketype[math.random(1,4)], 1.0)
			while Native.IsEntityDead(pl) do
				Native.DrawScaleformMovieFullscreen(scaleform, 255, 0, 0, 255, 0)
				Thread:Wait() 
			end
			Native.StopScreenEffect('DeathFailOut')
			Native.StopGameplayCamShaking(true)
		end
		Thread:Wait()
	end
end)