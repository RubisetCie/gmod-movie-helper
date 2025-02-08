local PANEL = {}

local Color = Color
local ClearColour = Color(225, 225, 225)
local DarkColour = Color(32, 40, 24, 215)
local MiddleColour = Color(175, 175, 175)
local LightColour = Color(220, 220, 220)

local RoundedBox = draw.RoundedBox

function PANEL:Init()

    self:SetTitle("Rubis Movie Helper")
    self:SetSize(ScrW(), 90)
    self:SetPos(0, ScrH() - self:GetTall())
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    self:SetDeleteOnClose(false)

    self._sendKeyframeChanges = true
    self._createTime = SysTime()

    self.FramePanel = vgui.Create("SMHFramePanel", self)

    self.FramePointer = self.FramePanel:CreateFramePointer(ClearColour, self.FramePanel:GetTall() / 4, true)

    self.TimelinesBase = vgui.Create("Panel", self)

    self.PositionLabel = vgui.Create("DLabel", self)

    self.PlaybackRateControl = vgui.Create("DNumberWang", self)
    self.PlaybackRateControl:SetMinMax(1, 216000)
    self.PlaybackRateControl:SetDecimals(0)
    self.PlaybackRateControl.OnValueChanged = function(_, value)
        self:OnRequestStateUpdate({ PlaybackRate = tonumber(value) })
    end
    self.PlaybackRateControl.Label = vgui.Create("DLabel", self)
    self.PlaybackRateControl.Label:SetText("Framerate")
    self.PlaybackRateControl.Label:SizeToContents()

    self.PlaybackLengthControl = vgui.Create("DNumberWang", self)
    self.PlaybackLengthControl:SetMinMax(1, 999)
    self.PlaybackLengthControl:SetDecimals(0)
    self.PlaybackLengthControl.OnValueChanged = function(_, value)
        self:OnRequestStateUpdate({ PlaybackLength = tonumber(value) })
    end
    self.PlaybackLengthControl.Label = vgui.Create("DLabel", self)
    self.PlaybackLengthControl.Label:SetText("Frame Count")
    self.PlaybackLengthControl.Label:SizeToContents()

    self.Easing = vgui.Create("Panel", self)

    self.EaseControl = vgui.Create("DComboBox", self.Easing)
    self.EaseControl:AddChoice("No ease", 0, true)
    self.EaseControl:AddChoice("Ease out", 1)
    self.EaseControl:AddChoice("Ease in", 2)
    self.EaseControl:AddChoice("Ease in/out", 3)
    self.EaseControl:AddChoice("Interpolate", 4)
    self.EaseControl.OnSelect = function(_, _, _, data)
        if self._sendKeyframeChanges then
            self:OnRequestKeyframeUpdate({ Ease = data })
        end
    end
    self.EaseControl.Label = vgui.Create("DLabel", self.Easing)
    self.EaseControl.Label:SetText("Easing")
    self.EaseControl.Label:SizeToContents()

    self.PlayButton = vgui.Create("DButton", self)
    self.PlayButton:SetText("Play / Stop")
    self.PlayButton.DoClick = function()
        if not SMH.Controller.IsPlaying() then
            SMH.Controller.StartPlayback()
        else
            SMH.Controller.StopPlayback()
        end
    end

    self.RecordButton = vgui.Create("DButton", self)
    self.RecordButton:SetText("Record")
    self.RecordButton.DoClick = function() self:OnRequestRecord() end

    self.PropertiesButton = vgui.Create("DButton", self)
    self.PropertiesButton:SetText("Properties")
    self.PropertiesButton.DoClick = function() self:OnRequestOpenPropertiesMenu() end

    self.SaveButton = vgui.Create("DButton", self)
    self.SaveButton:SetText("Save")
    self.SaveButton.DoClick = function() self:OnRequestOpenSaveMenu() end

    self.LoadButton = vgui.Create("DButton", self)
    self.LoadButton:SetText("Load")
    self.LoadButton.DoClick = function() self:OnRequestOpenLoadMenu() end

    self.SettingsButton = vgui.Create("DButton", self)
    self.SettingsButton:SetText("Settings")
    self.SettingsButton.DoClick = function() self:OnRequestOpenSettings() end

    self.Easing:SetVisible(false)

end

function PANEL:PerformLayout(width, height)

    self.BaseClass.PerformLayout(self, width, height)

    self.FramePanel:SetPos(5, 40)
    self.FramePanel:SetSize(width - 10, 45)

    self.FramePointer.VerticalPosition = self.FramePanel:GetTall() / 4

    self.TimelinesBase:SetPos(0, 25)
    self.TimelinesBase:SetSize(ScrW(),15)

    self.PositionLabel:SetPos(150, 5)

    self.PlaybackRateControl:SetPos(340, 2)
    self.PlaybackRateControl:SetSize(50, 20)
    local sizeX, sizeY = self.PlaybackRateControl.Label:GetSize()
    self.PlaybackRateControl.Label:SetRelativePos(self.PlaybackRateControl, -(sizeX) - 5, 3)

    self.PlaybackLengthControl:SetPos(470, 2)
    self.PlaybackLengthControl:SetSize(50, 20)
    sizeX, sizeY = self.PlaybackLengthControl.Label:GetSize()
    self.PlaybackLengthControl.Label:SetRelativePos(self.PlaybackLengthControl, -(sizeX) - 5, 3)

    self.Easing:SetPos(520, 0)
    self.Easing:SetSize(150, 30)

    self.EaseControl:SetPos(60, 2)
    self.EaseControl:SetSize(120, 20)
    sizeX, sizeY = self.EaseControl.Label:GetSize()
    self.EaseControl.Label:SetRelativePos(self.EaseControl, -(sizeX) - 5, 3)

    self.PlayButton:SetPos(width - 432, 2)
    self.PlayButton:SetSize(100, 20)

    self.RecordButton:SetPos(width - 325, 2)
    self.RecordButton:SetSize(60, 20)

    self.PropertiesButton:SetPos(width - 260, 2)
    self.PropertiesButton:SetSize(60, 20)

    self.SaveButton:SetPos(width - 195, 2)
    self.SaveButton:SetSize(60, 20)

    self.LoadButton:SetPos(width - 130, 2)
    self.LoadButton:SetSize(60, 20)

    self.SettingsButton:SetPos(width - 65, 2)
    self.SettingsButton:SetSize(60, 20)

end

function PANEL:Paint(width, height)

    RoundedBox(2, 0, 0, width, height, DarkColour)

end

function PANEL:UpdateTimelines(timelineinfo)
    self.TimelinesBase:Clear()

    if next(timelineinfo) == nil then return end --check if supplied table is empty
    local TotallTimelines = timelineinfo.Timelines
    if TotallTimelines < SMH.State.Timeline then SMH.State.Timeline = 1 end
    self.TimelinesBase.Timeline = {}

    for i = 1, TotallTimelines do
        self.TimelinesBase.Timeline[i] = vgui.Create("DPanel", self.TimelinesBase)
        self.TimelinesBase.Timeline[i]:SetPos((i - 1) * (ScrW() / TotallTimelines) + 4,0)
        self.TimelinesBase.Timeline[i]:SetSize((ScrW() / TotallTimelines) - 8,15)
        if i == SMH.State.Timeline then
            self.TimelinesBase.Timeline[i]:SetBackgroundColor(LightColour)
        else
            self.TimelinesBase.Timeline[i]:SetBackgroundColor(MiddleColour)
        end

        self.TimelinesBase.Timeline[i].Label = vgui.Create("DLabel", self.TimelinesBase.Timeline[i])
        self.TimelinesBase.Timeline[i].Label:SetText("Timeline " .. i)
        self.TimelinesBase.Timeline[i].Label:SetTextColor(Color(100, 100, 100))
        self.TimelinesBase.Timeline[i].Label:SizeToContents()
        self.TimelinesBase.Timeline[i].Label:Center()

        self.TimelinesBase.Timeline[i]._pressed = false
        self.TimelinesBase.Timeline[i].OnMousePressed = function(_, mousecode)
            if mousecode ~= MOUSE_LEFT then return end

            SMH.State.Timeline = i
            SMH.Controller.UpdateTimeline()

            for j = 1, TotallTimelines do
                if j ~= i then
                    self.TimelinesBase.Timeline[j]:SetBackgroundColor(MiddleColour)
                else
                    self.TimelinesBase.Timeline[j]:SetBackgroundColor(LightColour)
                end
            end
        end
    end
end

function PANEL:SetInitialState(state)
    self.PlaybackRateControl:SetValue(state.PlaybackRate)
    self.PlaybackLengthControl:SetValue(state.PlaybackLength)
    self:UpdatePositionLabel(state.Frame, state.PlaybackLength)
end

function PANEL:UpdatePositionLabel(frame, totalFrames)
    self.PositionLabel:SetText("Position: " .. frame + 1 .. " / " .. totalFrames)
    self.PositionLabel:SizeToContents()
end

function PANEL:ShowEasingControls(easing)
    self._sendKeyframeChanges = false
    self.EaseControl:SetValue(self.EaseControl:GetOptionTextByData(easing))
    self.Easing:SetVisible(true)
    self._sendKeyframeChanges = true
end

function PANEL:HideEasingControls()
    self.Easing:SetVisible(false)
end

function PANEL:SetEnabled(enabled)
    self.PlaybackRateControl:SetEnabled(enabled)
    self.PlaybackLengthControl:SetEnabled(enabled)
    self.RecordButton:SetEnabled(enabled)
    self.EaseControl:SetEnabled(enabled)
end

function PANEL:OnRequestStateUpdate(newState) end
function PANEL:OnRequestKeyframeUpdate(newKeyframeData) end
function PANEL:OnRequestOpenPropertiesMenu() end
function PANEL:OnRequestRecord() end
function PANEL:OnRequestOpenSaveMenu() end
function PANEL:OnRequestOpenLoadMenu() end
function PANEL:OnRequestOpenSettings() end

vgui.Register("SMHMenu", PANEL, "DFrame")
