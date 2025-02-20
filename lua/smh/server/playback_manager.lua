local ActivePlaybacks = {}

local MGR = {}
local SMH = SMH

local math = math
local pairs = pairs
local FrameTime = FrameTime

local function PlaybackSmooth(player, playback, settings)
    if not SMH.KeyframeData.Players[player] then
        return
    end

    playback.Timer = playback.Timer + FrameTime()
    local timePerFrame = 1 / playback.PlaybackRate

    playback.CurrentFrame = playback.Timer / timePerFrame + playback.StartFrame
    if playback.CurrentFrame > playback.EndFrame then
        playback.CurrentFrame = 0
        playback.StartFrame = 0
        playback.Timer = 0
    end

    for entity, keyframes in pairs(SMH.KeyframeData.Players[player].Entities) do
        if entity ~= player then
            for name, mod in pairs(SMH.Modifiers) do
                local prevKeyframe, nextKeyframe = SMH.GetBetweenKeyframes(keyframes, playback.CurrentFrame, false, name)

                if not prevKeyframe then continue end

                if prevKeyframe.Frame == nextKeyframe.Frame then
                    if prevKeyframe.Modifiers[name] and nextKeyframe.Modifiers[name] then
                        mod:Load(entity, prevKeyframe.Modifiers[name], settings)
                    end
                else
                    local lerpMultiplier = ((playback.Timer + playback.StartFrame * timePerFrame) - prevKeyframe.Frame * timePerFrame) / ((nextKeyframe.Frame - prevKeyframe.Frame) * timePerFrame)
                    local nextEase = nextKeyframe.Ease[name]
                    local prevEase = prevKeyframe.Ease[name]

                    if prevEase > 3 or nextEase > 3 then
                        local anteKeyframe, postKeyframe = SMH.GetSurroundKeyframes(keyframes, prevKeyframe, prevEase, nextKeyframe, nextEase, name)
                        mod:LoadInterpolated(entity, anteKeyframe.Modifiers[name], prevKeyframe.Modifiers[name], nextKeyframe.Modifiers[name], postKeyframe.Modifiers[name], lerpMultiplier, settings)
                    else
                        lerpMultiplier = SMH.ApplyLinearEasing(prevEase, nextEase, lerpMultiplier)
                        mod:LoadBetween(entity, prevKeyframe.Modifiers[name], nextKeyframe.Modifiers[name], lerpMultiplier, settings)
                    end
                end
            end
        else
            if settings.EnableWorld then
                SMH.WorldKeyframesManager.Load(player, math.Round(playback.CurrentFrame), keyframes)
            end
        end
    end
end

function MGR.SetFrame(player, newFrame, settings)
    if not SMH.KeyframeData.Players[player] then
        return
    end

    for entity, keyframes in pairs(SMH.KeyframeData.Players[player].Entities) do
        if entity ~= player then
            for name, mod in pairs(SMH.Modifiers) do
                local prevKeyframe, nextKeyframe, lerpMultiplier = SMH.GetClosestKeyframes(keyframes, newFrame, false, name)
                if not prevKeyframe then
                    continue
                end

                if lerpMultiplier <= 0 or settings.TweenDisable then
                    mod:Load(entity, prevKeyframe.Modifiers[name], settings)
                elseif lerpMultiplier >= 1 then
                    mod:Load(entity, nextKeyframe.Modifiers[name], settings)
                else
                    local prevEase = prevKeyframe.Ease[name]
                    local nextEase = nextKeyframe.Ease[name]
                    if prevEase > 3 or nextEase > 3 then
                        local anteKeyframe, postKeyframe = SMH.GetSurroundKeyframes(keyframes, prevKeyframe, prevEase, nextKeyframe, nextEase, name)
                        mod:LoadInterpolated(entity, anteKeyframe.Modifiers[name], prevKeyframe.Modifiers[name], nextKeyframe.Modifiers[name], postKeyframe.Modifiers[name], lerpMultiplier, settings)
                    else
                        lerpMultiplier = SMH.ApplyLinearEasing(prevEase, nextEase, lerpMultiplier)
                        mod:LoadBetween(entity, prevKeyframe.Modifiers[name], nextKeyframe.Modifiers[name], lerpMultiplier, settings)
                    end
                end
            end
        else
            if settings.EnableWorld then
                SMH.WorldKeyframesManager.Load(player, newFrame, keyframes)
            end
        end
    end
end

function MGR.SetFrameIgnore(player, newFrame, settings, ignored)
    if not SMH.KeyframeData.Players[player] then
        return
    end

    for entity, keyframes in pairs(SMH.KeyframeData.Players[player].Entities) do
        if ignored[entity] then continue end
        for name, mod in pairs(SMH.Modifiers) do
            local prevKeyframe, nextKeyframe, lerpMultiplier = SMH.GetClosestKeyframes(keyframes, newFrame, false, name)
            if not prevKeyframe then
                continue
            end

            if lerpMultiplier <= 0 or settings.TweenDisable then
                mod:Load(entity, prevKeyframe.Modifiers[name], settings)
            elseif lerpMultiplier >= 1 then
                mod:Load(entity, nextKeyframe.Modifiers[name], settings)
            else
                local prevEase = prevKeyframe.Ease[name]
                local nextEase = nextKeyframe.Ease[name]
                if prevEase > 3 or nextEase > 3 then
                    local anteKeyframe, postKeyframe = SMH.GetSurroundKeyframes(keyframes, prevKeyframe, prevEase, nextKeyframe, nextEase, name)
                    mod:LoadInterpolated(entity, anteKeyframe.Modifiers[name], prevKeyframe.Modifiers[name], nextKeyframe.Modifiers[name], postKeyframe.Modifiers[name], lerpMultiplier, settings)
                else
                    lerpMultiplier = SMH.ApplyLinearEasing(prevEase, nextEase, lerpMultiplier)
                    mod:LoadBetween(entity, prevKeyframe.Modifiers[name], nextKeyframe.Modifiers[name], lerpMultiplier, settings)
                end
            end
        end
    end
end

function MGR.StartPlayback(player, startFrame, endFrame, playbackRate, settings)
    ActivePlaybacks[player] = {
        StartFrame = startFrame,
        EndFrame = endFrame,
        PlaybackRate = playbackRate,
        CurrentFrame = startFrame,
        PrevFrame = startFrame - 1,
        Timer = 0,
        Settings = settings,
    }
    MGR.SetFrame(player, startFrame, settings)
end

function MGR.StopPlayback(player)
    ActivePlaybacks[player] = nil
end

hook.Add("Think", "SMHPlaybackManagerThink", function()
    for player, playback in pairs(ActivePlaybacks) do
        if playback.Settings.SmoothPlayback and not playback.Settings.TweenDisable then
            PlaybackSmooth(player, playback, playback.Settings)
        else

            playback.Timer = playback.Timer + FrameTime()
            local timePerFrame = 1 / playback.PlaybackRate

            if playback.Timer >= timePerFrame then

                playback.CurrentFrame = math.floor(playback.Timer / timePerFrame) + playback.StartFrame
                if playback.CurrentFrame > playback.EndFrame then
                    playback.CurrentFrame = 0
                    playback.StartFrame = 0
                    playback.Timer = 0
                end

                if playback.CurrentFrame ~= playback.PrevFrame then
                    playback.PrevFrame = playback.CurrentFrame
                    MGR.SetFrame(player, playback.CurrentFrame, playback.Settings)
                end

            end
        end
    end
end)

SMH.PlaybackManager = MGR
