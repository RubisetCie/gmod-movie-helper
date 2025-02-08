local InOutQuad = math.ease.InOutQuad
local InQuad = math.ease.InQuad
local OutQuad = math.ease.OutQuad

function SMH.ApplyLinearEasing(prevEase, nextEase, lerp)
    local nextIn = nextEase == 2 or nextEase == 3
    local prevOut = prevEase == 1 or prevEase == 3
    if prevOut and nextIn then
        return InOutQuad(lerp)
    elseif prevOut then
        return InQuad(lerp)
    elseif nextIn then
        return OutQuad(lerp)
    end
    return lerp
end

function SMH.GetBetweenKeyframes(keyframes, frame, ignoreCurrentFrame, modname)
    local prevKeyframe = nil
    local nextKeyframe = nil
    for _, keyframe in pairs(keyframes) do
        if keyframe.Frame == frame and keyframe.Modifiers[modname] and not ignoreCurrentFrame then
            prevKeyframe = keyframe
            nextKeyframe = keyframe
            break
        end

        if keyframe.Frame < frame and (not prevKeyframe or prevKeyframe.Frame < keyframe.Frame) and keyframe.Modifiers[modname] then
            prevKeyframe = keyframe
        elseif keyframe.Frame > frame and (not nextKeyframe or nextKeyframe.Frame > keyframe.Frame) and keyframe.Modifiers[modname] then
            nextKeyframe = keyframe
        end
    end

    if not prevKeyframe and not nextKeyframe then
        return nil, nil
    elseif not prevKeyframe then
        prevKeyframe = nextKeyframe
    elseif not nextKeyframe then
        nextKeyframe = prevKeyframe
    end

    return prevKeyframe, nextKeyframe
end

function SMH.GetSurroundKeyframes(keyframes, prevKeyframe, prevEase, nextKeyframe, nextEase, modname)
    local anteKeyframe = nil
    local postKeyframe = nil
    for _, keyframe in pairs(keyframes) do
        if keyframe.Frame < prevKeyframe.Frame and (not anteKeyframe or anteKeyframe.Frame < keyframe.Frame) and keyframe.Modifiers[modname] then
            anteKeyframe = keyframe
        elseif keyframe.Frame > nextKeyframe.Frame and (not postKeyframe or postKeyframe.Frame > keyframe.Frame) and keyframe.Modifiers[modname] then
            postKeyframe = keyframe
        end
    end
    -- Correct the surrounding keyframes depending on the ease
    if prevEase == 1 then
        anteKeyframe = nextKeyframe
    elseif prevEase < 4 or anteKeyframe == nil then
        anteKeyframe = prevKeyframe
    end
    if nextEase == 2 then
        postKeyframe = prevKeyframe
    elseif nextEase < 4 or postKeyframe == nil then
        postKeyframe = nextKeyframe
    end

    return anteKeyframe, postKeyframe
end

local GetBetweenKeyframes = SMH.GetBetweenKeyframes

function SMH.GetClosestKeyframes(keyframes, frame, ignoreCurrentFrame, modname)
    local prevKeyframe, nextKeyframe = GetBetweenKeyframes(keyframes, frame, ignoreCurrentFrame, modname)
    if not prevKeyframe then
        return nil, nil, 0
    end
    local lerp = 0
    if prevKeyframe.Frame ~= nextKeyframe.Frame then
        lerp = (frame - prevKeyframe.Frame) / (nextKeyframe.Frame - prevKeyframe.Frame)
    end

    return prevKeyframe, nextKeyframe, lerp
end

local META = {}
META.__index = META

function META:New(player, entity)
    local keyframe = {
        ID = self.NextKeyframeId,
        Entity = entity,
        Frame = -1,
        Ease = {},
        Modifiers = {}
    }
    self.NextKeyframeId = self.NextKeyframeId + 1

    if not self.Players[player] then
        self.Players[player] = {
            Keyframes = {},
            Entities = {},
        }
    end

    self.Players[player].Keyframes[keyframe.ID] = keyframe

    if not self.Players[player].Entities[entity] then
        self.Players[player].Entities[entity] = {}
    end

    table.insert(self.Players[player].Entities[entity], keyframe)

    return keyframe
end

function META:Delete(player, id)
    if not self.Players[player] or not self.Players[player].Keyframes[id] then
        return
    end

    local keyframe = self.Players[player].Keyframes[id]
    if self.Players[player].Entities[keyframe.Entity] then
        table.RemoveByValue(self.Players[player].Entities[keyframe.Entity], keyframe)
    end
    self.Players[player].Keyframes[id] = nil
end

SMH.KeyframeData = {
    NextKeyframeId = 0,
    Players = {},
}
setmetatable(SMH.KeyframeData, META)
