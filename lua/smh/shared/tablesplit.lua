local keyframesAssembling = {}
local timelineAssembling = {}
local listAssembling = {}

local MGR = {} -- btw D stands for "deconstruct", A for "Assemble"

function MGR.DKeyframes(keyframes)
    local IDs, ents, Frame, Ease, ModCount, Modifiers = {}, {}, {}, {}, {}, {}
    local i = 0
    for _, keyframe in pairs(keyframes) do
        i = i + 1

        IDs[i] = keyframe.ID
        Frame[i] = keyframe.Frame
        ents[i] = keyframe.Entity
        Modifiers[i], Ease[i] = {}, {}
        ModCount[i] = 0
        for name, data in pairs(keyframe.Modifiers) do
            ModCount[i] = ModCount[i] + 1
            Modifiers[i][ModCount[i]] = name
            Ease[i][ModCount[i]] = keyframe.Ease[name]
        end
    end

    return i, IDs, ents, Frame, Ease, ModCount, Modifiers
end

function MGR.AKeyframes(ID, entity, Frame, Ease, Modifiers)
    local keyframe = {}
    keyframe.ID = ID
    keyframe.Entity = entity
    keyframe.Frame = Frame
    keyframe.Ease = table.Copy(Ease)
    keyframe.Modifiers = table.Copy(Modifiers)

    table.insert(keyframesAssembling, keyframe)
end

function MGR.GetKeyframes()
    local keyframes = table.Copy(keyframesAssembling)
    keyframesAssembling = {}
    return keyframes
end

function MGR.DProperties(timeline)
    if not next(timeline) then return end
    local Timelines = timeline.Timelines
    local KeyColor, Modifiers, ModCount = {}, {}, {}

    for key, _ in ipairs(timeline.TimelineMods) do
        Modifiers[key] = {}
        ModCount[key] = #timeline.TimelineMods[key]

        for k, value in pairs(timeline.TimelineMods[key]) do
            if k == "KeyColor" then
                KeyColor[key] = value
                continue
            end

            Modifiers[key][k] = value
        end
    end
    return Timelines, KeyColor, ModCount, Modifiers
end

function MGR.StartAProperties(Timelines)
    timelineAssembling.Timelines = Timelines
    timelineAssembling.TimelineMods = {}
    return Timelines
end

function MGR.AProperties(Timeline, Modifier, KeyColor)
    if not timelineAssembling.TimelineMods[Timeline] then
        timelineAssembling.TimelineMods[Timeline] = {}
    end
    if KeyColor then
        timelineAssembling.TimelineMods[Timeline].KeyColor = KeyColor
    end
    if Modifier then
        table.insert(timelineAssembling.TimelineMods[Timeline], Modifier)
    end
end

function MGR.GetProperties()
    local timeline = table.Copy(timelineAssembling)
    timelineAssembling = {}
    return timeline
end

function MGR.DTable(list)
    local items, keys, count = {}, {}, 0
    for key, item in pairs(list) do
        table.insert(items, item)
        table.insert(keys, key)
        count = count + 1
    end
    return items, keys, count
end

local tonumber = tonumber

function MGR.ATable(key, item)
    if not tonumber(key) then
        listAssembling[key] = item
    else
        listAssembling[tonumber(key)] = item
    end
end

function MGR.GetTable()
    local list = table.Copy(listAssembling)
    listAssembling = {}
    return list
end

SMH.TableSplit = MGR
