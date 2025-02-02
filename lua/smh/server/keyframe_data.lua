local InOutQuad = math.ease.InOutQuad
local InQuad = math.ease.InQuad
local OutQuad = math.ease.OutQuad

function SMH.GetClosestKeyframes(keyframes, frame, ignoreCurrentFrame, modname)
    if ignoreCurrentFrame == nil then
        ignoreCurrentFrame = false
    end

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
        return nil, nil, 0
    elseif not prevKeyframe then
        prevKeyframe = nextKeyframe
    elseif not nextKeyframe then
        nextKeyframe = prevKeyframe
    end

    local lerpMultiplier = 0
    if prevKeyframe.Frame ~= nextKeyframe.Frame then
        lerpMultiplier = (frame - prevKeyframe.Frame) / (nextKeyframe.Frame - prevKeyframe.Frame)
        local prevEase = prevKeyframe.Ease[modname]
        local nextEase = nextKeyframe.Ease[modname]
        local nextIn = nextEase == 2 or nextEase == 3
        local prevOut = prevEase == 1 or prevEase == 3
        if prevOut and nextIn then
            lerpMultiplier = InOutQuad(lerpMultiplier)
        elseif prevOut then
            lerpMultiplier = InQuad(lerpMultiplier)
        elseif nextIn then
            lerpMultiplier = OutQuad(lerpMultiplier)
        end
    end

    return prevKeyframe, nextKeyframe, lerpMultiplier
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
