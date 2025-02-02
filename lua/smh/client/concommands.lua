CreateClientConVar("smh_currentpreset", "default", true, false)

concommand.Add("+smh_menu", function()
    SMH.Controller.OpenMenu()
end)

concommand.Add("-smh_menu", function()
    SMH.Controller.CloseMenu()
end)

concommand.Add("smh_record", function()
    SMH.Controller.Record()
end)

concommand.Add("smh_next", function()
    local pos = SMH.State.Frame + 1
    if pos >= SMH.State.PlaybackLength then
        pos = 0
    end
    SMH.Controller.SetFrame(pos)
end)

concommand.Add("smh_previous", function()
    local pos = SMH.State.Frame - 1
    if pos < 0 then
        pos = SMH.State.PlaybackLength - 1
    end
    SMH.Controller.SetFrame(pos)
end)

concommand.Add("smh_playback", function()
    if not SMH.Controller.IsPlaying() then
        SMH.Controller.StartPlayback()
    else
        SMH.Controller.StopPlayback()
    end
end)

concommand.Add("smh_quicksave", function()
    SMH.Controller.QuickSave()
end)
