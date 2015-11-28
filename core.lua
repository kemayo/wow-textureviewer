local myname, ns = ...

ns:RegisterEvent("ADDON_LOADED")
function ns:ADDON_LOADED(event, addon)
    if addon ~= myname then return end

    LibStub("tekKonfig-AboutPanel").new(nil, myname) -- Make first arg nil if no parent config panel

    self:UnregisterEvent("ADDON_LOADED")
    self.ADDON_LOADED = nil
end

local frame = CreateFrame("Frame", myname, UIParent)
frame:SetWidth(350)
frame:SetHeight(90)
frame:SetPoint("CENTER")
frame:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
frame:SetBackdropColor(0, 0, 0, 0.8)
frame:SetBackdropBorderColor(0.1, 0.1, 0.1, 0.8)
frame:EnableMouse(1)
frame:SetMovable(1)
frame:SetToplevel(1)
frame:SetClampedToScreen(1)
frame:Hide()

frame:SetScript("OnMouseDown",frame.StartMoving)
frame:SetScript("OnMouseUp",frame.StopMovingOrSizing)

frame.header = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
frame.header:SetPoint("TOPLEFT", 12, -12)
frame.header:SetFont(frame.header:GetFont(), 20, "THICKOUTLINE")
frame.header:SetText("Texture path")

frame:EnableMouseWheel(true)
frame:SetScript("OnMouseWheel", function(self, delta)
    local width = self.texture:GetWidth()
    local height = self.texture:GetHeight()
    if delta > 0 then
        width = width * 2
        height = height * 2
    else
        width = width / 2
        height = height / 2
    end
    self.texture:SetWidth(width)
    self.texture:SetHeight(height)
end)

frame.input = CreateFrame("EditBox", nil, frame) --, "ChatFrameEditBoxTemplate")
frame.input:SetFontObject("GameFontHighlight")
frame.input:SetTextInsets(10, 10, 3, 3) -- left, right, top, bottom
frame.input:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4, },
})
frame.input:SetBackdropColor(0.1, 0.1, 0.2, 1)
frame.input:SetBackdropBorderColor(0.8, 0.8, 0.9, 0.4)
frame.input:SetPoint("TOPLEFT",12,-38)
frame.input:SetPoint("BOTTOMRIGHT",-12,12)

frame.input:SetScript("OnEscapePressed", function(self) frame:Hide() end)
frame.input:SetScript("OnTextChanged", function(self, by_user_input)
    local path = self:GetText():gsub([[\\]], [[\]]):gsub("%[%[", ""):gsub("%]%]", "")
    -- to be nice, replace double-slashes
    if frame.texture then
        frame.texture:Hide()
    end

    frame.texture = frame:CreateTexture("ARTWORK", nil)
    frame.texture:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, 0)
    -- frame.texture:SetWidth(128)
    -- frame.texture:SetHeight(128)

    frame.texture:SetTexture(path)
    local w,h = frame.texture:GetSize()
    frame.texture:SetWidth(w)
    frame.texture:SetHeight(h)
end)

frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
frame.close:SetPoint("TOPRIGHT", -4, -4)
frame.close:SetScript("OnClick", function(self, button, down) frame:Hide() end)

frame.xscaleup = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
frame.xscaleup:SetText("X+")
frame.xscaleup:SetWidth(32)
frame.xscaleup:SetPoint("RIGHT", frame.close, "LEFT", 10)
frame.xscaleup:SetScript("OnClick", function(self, button, down)
    frame.texture:SetWidth(frame.texture:GetWidth() * 2)
end)
frame.xscaledown = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
frame.xscaledown:SetText("X-")
frame.xscaledown:SetWidth(32)
frame.xscaledown:SetPoint("RIGHT", frame.xscaleup, "LEFT", 10)
frame.xscaledown:SetScript("OnClick", function(self, button, down)
    frame.texture:SetWidth(frame.texture:GetWidth() / 2)
end)
frame.yscaleup = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
frame.yscaleup:SetText("Y+")
frame.yscaleup:SetWidth(32)
frame.yscaleup:SetPoint("RIGHT", frame.xscaledown, "LEFT", 15)
frame.yscaleup:SetScript("OnClick", function(self, button, down)
    frame.texture:SetHeight(frame.texture:GetHeight() * 2)
end)
frame.yscaledown = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
frame.yscaledown:SetText("Y-")
frame.yscaledown:SetWidth(32)
frame.yscaledown:SetPoint("RIGHT", frame.yscaleup, "LEFT", 15)
frame.yscaledown:SetScript("OnClick", function(self, button, down)
    frame.texture:SetHeight(frame.texture:GetHeight() / 2)
end)

_G["SLASH_".. myname:upper().."1"] = GetAddOnMetadata(myname, "X-LoadOn-Slash")
SlashCmdList[myname:upper()] = function(msg)
    if frame:IsVisible() then
        frame:Hide()
    else
        frame:Show()
    end
end
