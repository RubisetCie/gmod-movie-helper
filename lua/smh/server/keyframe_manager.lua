local function GetExistingKeyframe(player, entity, frame, modnames)
    if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Entities[entity] then
        return nil
    end
    if not modnames then
        modnames = { "world" }
        for name, mod in pairs(SMH.Modifiers) do
            table.insert(modnames, name)
        end
    end

    local keyframes = SMH.KeyframeData.Players[player].Entities[entity]
    for _, keyframe in pairs(keyframes) do
        for _, name in ipairs(modnames) do
            if keyframe.Frame == frame and keyframe.Modifiers[name] then
                return keyframe
            end
        end
    end

    return nil
end

local function Record(keyframe, player, entity, modnames)
    local recorded = false
    for _, name in ipairs(modnames) do
        if not SMH.Modifiers[name] then continue end
        local data = SMH.Modifiers[name]:Save(entity)
        if not data then continue end
        recorded = true
        keyframe.Modifiers[name] = data
        keyframe.Ease[name] = keyframe.Ease[name] and keyframe.Ease[name] or 0
    end
    return recorded
end

local function ClearModifier(keyframe, modname)
    keyframe.Modifiers[modname] = nil
    keyframe.Ease[modname] = nil
end

hook.Add("EntityRemoved", "SMHKeyframesEntityRemoved", function(entity)

    for _, player in pairs(player.GetAll()) do
        if SMH.KeyframeData.Players[player] and SMH.KeyframeData.Players[player].Entities[entity] then
            local keyframesToDelete = {}
            for _, keyframe in pairs(SMH.KeyframeData.Players[player].Entities[entity]) do
                table.insert(keyframesToDelete, keyframe.ID)
            end

            SMH.KeyframeData.Players[player].Entities[entity] = nil

            for _, keyframeId in pairs(keyframesToDelete) do
                SMH.KeyframeData:Delete(player, keyframeId)
            end
        end
    end

end)

local MGR = {}

function MGR.GetAll(player)
    if not SMH.KeyframeData.Players[player] then
        return {}
    end
    local keyframes = SMH.KeyframeData.Players[player].Keyframes

    local result = {}
    for _, keyframe in pairs(keyframes) do
        table.insert(result, table.Copy(keyframe))
    end
    return result
end

function MGR.GetAllForEntity(player, entities)
    local keyframes = {}

    for _, entity in ipairs(entities) do
        if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Entities[entity] then
            continue
        end

        for k, keyframe in pairs(SMH.KeyframeData.Players[player].Entities[entity]) do
            table.insert(keyframes, keyframe)
        end
    end

    return keyframes
end

function MGR.Create(player, entities, frame, timeline)
    local keyframes = {}

    for _, entity in ipairs(entities) do
        if player ~= entity then
            local modnames = SMH.Properties.Players[player].TimelineSetting.TimelineMods[timeline]
            local keyframe = GetExistingKeyframe(player, entity, frame)

            if keyframe ~= nil then
                local check = Record(keyframe, player, entity, modnames)
                if check then
                    table.insert(keyframes, keyframe)
                end
            else
                keyframe = SMH.KeyframeData:New(player, entity)
                keyframe.Frame = frame
                local check = Record(keyframe, player, entity, modnames)
                if check then
                    table.insert(keyframes, keyframe)
                end
            end
        else
            local keyframe = GetExistingKeyframe(player, entity, frame, {"world"})

            if keyframe ~= nil then return {keyframe} end

            keyframe = SMH.KeyframeData:New(player, entity)
            keyframe.Frame = frame
            keyframe.Ease["world"] = 0
            keyframe.Modifiers["world"] = {
                Console = "",
                Push = "",
                Release = "",
            }
            table.insert(keyframes, keyframe)
        end
    end

    return keyframes
end

function MGR.Update(player, keyframeIds, updateData, timeline)
    local keyframes, movingkeyframes = {}, {}

    for id, keyframeId in ipairs(keyframeIds) do
        if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Keyframes[keyframeId] then
            error("Invalid keyframe ID")
        end

        local keyframe = SMH.KeyframeData.Players[player].Keyframes[keyframeId]
        local modnames = player == keyframe.Entity and {"world"} or SMH.Properties.Players[player].TimelineSetting.TimelineMods[timeline]
        local updateableFields = {
            "Frame",
            "Ease",
        }
        for _, field in pairs(updateableFields) do
            if updateData[id][field] then
                if field == "Frame" then
                    if updateData[id][field] == keyframe.Frame then continue end
                    local remainmods, Ease, frame = table.Copy(keyframe.Modifiers), table.Copy(keyframe.Ease), updateData[id][field]
                    for _, name in ipairs(modnames) do
                        remainmods[name] = nil
                        Ease[name] = nil
                    end

                    if next(remainmods) then -- if there are any modifiers remaining, then we create another keyframe that will stay there
                        local remainkeyframe = SMH.KeyframeData:New(player, keyframe.Entity)

                        for name, _ in pairs(remainmods) do
                            ClearModifier(keyframe, name)
                        end
                        remainkeyframe.Frame = keyframe.Frame
                        remainkeyframe.Modifiers = remainmods
                        remainkeyframe.Ease = Ease
                    end

                    movingkeyframes[keyframe] = frame
                else
                    for _, name in ipairs(modnames) do
                        if not keyframe[field][name] then continue end
                        keyframe[field][name] = updateData[id][field]
                    end
                    table.insert(keyframes, keyframe)
                end
            end
        end
    end

    for keyframe, frame in pairs(movingkeyframes) do
        local replacekey = GetExistingKeyframe(player, keyframe.Entity, frame)

        if replacekey ~= nil and not movingkeyframes[replacekey] then
            for name, data in pairs(replacekey.Modifiers) do

                if not keyframe.Modifiers[name] then
                    keyframe.Modifiers[name] = data
                    keyframe.Ease[name] = replacekey.Ease[name]
                end
            end
            SMH.KeyframeData:Delete(player, replacekey.ID)
        end
        keyframe.Frame = frame
        table.insert(keyframes, keyframe)
    end

    return keyframes
end

function MGR.Copy(player, keyframeIds, frame, timeline)
    local copiedKeyframes, movingkeyframes = {}, {}

    for id, keyframeId in ipairs(keyframeIds) do
        if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Keyframes[keyframeId] then
            error("Invalid keyframe ID")
        end

        local keyframe = SMH.KeyframeData.Players[player].Keyframes[keyframeId]
        local modnames = player == keyframe.Entity and {"world"} or SMH.Properties.Players[player].TimelineSetting.TimelineMods[timeline]

        local Ease, Mods = {}, {}
        for _, name in ipairs(modnames) do
            if not keyframe.Modifiers[name] then continue end
            Ease[name] = keyframe.Ease[name]
            if istable(keyframe.Modifiers[name]) then
                Mods[name] = table.Copy(keyframe.Modifiers[name]) -- in case if we copy things like world keyframes
            else
                Mods[name] = keyframe.Modifiers[name]
            end
        end

        local copiedKeyframe = SMH.KeyframeData:New(player, keyframe.Entity)
        copiedKeyframe.Ease = Ease
        copiedKeyframe.Modifiers = Mods

        movingkeyframes[copiedKeyframe] = frame[id]
    end

    for keyframe, frame in pairs(movingkeyframes) do
        local replacekey = GetExistingKeyframe(player, keyframe.Entity, frame)

        if replacekey ~= nil and not movingkeyframes[replacekey] then
            for name, data in pairs(replacekey.Modifiers) do
                if not keyframe.Modifiers[name] then
                    keyframe.Modifiers[name] = data
                    keyframe.Ease[name] = replacekey.Ease[name]
                end
            end
            SMH.KeyframeData:Delete(player, replacekey.ID)
        end

        keyframe.Frame = frame
        table.insert(copiedKeyframes, keyframe)
    end

    return copiedKeyframes
end

function MGR.Delete(player, keyframeId, timeline)
    if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Keyframes[keyframeId] then
        error("Invalid keyframe ID")
    end

    local entity = SMH.KeyframeData.Players[player].Keyframes[keyframeId].Entity

    local keyframe = SMH.KeyframeData.Players[player].Keyframes[keyframeId]
    local modnames = player == keyframe.Entity and {"world"} or SMH.Properties.Players[player].TimelineSetting.TimelineMods[timeline]

    for _, name in ipairs(modnames) do
        ClearModifier(keyframe, name)
    end

    if not next(keyframe.Modifiers) then
        SMH.KeyframeData:Delete(player, keyframeId)
    end
    return entity
end

function MGR.ImportSave(player, entity, serializedKeyframes, entityProperties)
    if SMH.KeyframeData.Players[player] and SMH.KeyframeData.Players[player].Entities[entity] then
        local deletethis = table.Copy(SMH.KeyframeData.Players[player].Entities[entity])
        for _, keyframe in pairs(deletethis) do
            SMH.KeyframeData:Delete(player, keyframe.ID)
        end
    end

    SMH.PropertiesManager.SetProperties(player, entity, entityProperties)

    for _, skf in pairs(serializedKeyframes) do
        local keyframe = GetExistingKeyframe(player, entity, skf.Position) -- check for SMH 3.0 save stuff as it has a system with multiple keyframes occupying same frame

        if keyframe ~= nil then
            for name, _ in pairs(skf.EntityData) do
                keyframe.Ease[name] = type(skf.Ease) == "table" and skf.Ease[name] or skf.Ease
                keyframe.Modifiers[name] = skf.EntityData[name]
            end
        else
            local keyframe = SMH.KeyframeData:New(player, entity)
            keyframe.Frame = skf.Position
            for name, _ in pairs(skf.EntityData) do
                keyframe.Ease[name] = type(skf.Ease) == "table" and skf.Ease[name] or skf.Ease
                keyframe.Modifiers[name] = skf.EntityData[name]
            end
        end
    end
end

function MGR.GetWorldData(player, frame)
    local keyframe = GetExistingKeyframe(player, player, frame, {"world"})
    local modifiers = keyframe.Modifiers["world"]

    return modifiers.Console, modifiers.Push, modifiers.Release
end

function MGR.UpdateWorldKeyframe(player, frame, str, key)
    local keyframe = GetExistingKeyframe(player, player, frame, {"world"})
    if not keyframe then return end
    keyframe.Modifiers["world"][key] = str
end

SMH.KeyframeManager = MGR
