local myname, ns = ...

-- handy tests:
-- [[Interface\Minimap\POIIcons]]
-- "Interface\\ChatFrame\\ChatFrameBackground"
-- "Interface\\Tooltips\\UI-Tooltip-Border"
-- "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes" 0, 0.25, 0, 0.25
-- worldquest-icon-firstaid

-- /script TextureViewer:ShowWith([[Interface/Minimap/POIIcons]], C_Minimap.GetPOITextureCoords(115))

ns:RegisterEvent("ADDON_LOADED")
function ns:ADDON_LOADED(event, addon)
    if addon ~= myname then return end

    -- onload goes here

    self:UnregisterEvent("ADDON_LOADED")
    self.ADDON_LOADED = nil
end

local frame = CreateFrame("Frame", myname, UIParent, "BackdropTemplate")
frame:SetWidth(350)
frame:SetHeight(150)
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

frame.sizes = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
frame.sizes:SetPoint("BOTTOM", 0, 4)

frame:EnableMouseWheel(true)
frame:SetScript("OnMouseWheel", function(self, delta)
    local width, height = self.texture:GetSize()
    if delta > 0 then
        width = width * 2
        height = height * 2
    else
        width = width / 2
        height = height / 2
    end
    self.texture:SetSize(width, height)
end)

frame.texture = frame:CreateTexture("ARTWORK", nil)

frame.input = CreateFrame("EditBox", nil, frame, "BackdropTemplate") --, "ChatFrameEditBoxTemplate")
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
frame.input:SetPoint("TOPRIGHT",-12,-38)
frame.input:SetHeight(40)

frame.input:SetScript("OnEscapePressed", function(self) frame:Hide() end)
frame.input:SetScript("OnTextChanged", function(self, by_user_input)
    -- to be nice, replace double-slashes
    local path = self:GetText():gsub([[\\]], [[\]]):gsub("%[%[", ""):gsub("%]%]", ""):gsub([["]], "")

    -- jiggle the size a bit to make it display at native size
    frame.texture:SetSize(0, 0)
    frame.texture:ClearAllPoints()
    frame.texture:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, 0)

    if not frame.texture:SetAtlas(path, true) then
        frame.texture:SetTexture(path)
    end

    frame.sizes:SetFormattedText("%d x %d", frame.texture:GetSize())

    frame.texcoords:Enable()
    frame.texcoords:GetScript("OnTextChanged")(frame.texcoords, by_user_input)
end)
frame.input:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("Texture path")
    GameTooltip:AddLine("Quotes and double-slashes will be handled automatically")
    GameTooltip:Show()
end)
frame.input:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

frame.texcoords = CreateFrame("EditBox", nil, frame, "BackdropTemplate")
frame.texcoords:SetFontObject("GameFontHighlight")
frame.texcoords:SetTextInsets(10, 10, 3, 3) -- left, right, top, bottom
frame.texcoords:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4, },
})
frame.texcoords:SetBackdropColor(0.1, 0.1, 0.2, 1)
frame.texcoords:SetBackdropBorderColor(0.8, 0.8, 0.9, 0.4)
frame.texcoords:SetPoint("TOPLEFT", frame.input, "BOTTOMLEFT", 0, -10)
frame.texcoords:SetPoint("TOPRIGHT", frame.input, "BOTTOMRIGHT", 0, -10)
frame.texcoords:SetHeight(frame.input:GetHeight())
frame.texcoords:Disable()

frame.texcoords:SetScript("OnEscapePressed", function(self) frame:Hide() end)
frame.texcoords:SetScript("OnTextChanged", function(self, by_user_input)
    local coords = { string.split(",", (self:GetText():gsub("%s", ""))) }
    if 4 == #coords or 8 == #coords then
        frame.texture:SetTexCoord(unpack(coords))
    else
        frame.texture:SetTexCoord(0, 1, 0, 1)
    end
end)
frame.texcoords:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("Texture coordinates")
    GameTooltip:AddLine("{left, right, top, bottom}")
    GameTooltip:AddLine("{ULx, ULy, LLx, LLy, URx, URy, LRx, LRy}")
    GameTooltip:Show()
end)
frame.texcoords:SetScript("OnLeave", function()
    GameTooltip:Hide()
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

_G["SLASH_".. myname:upper().."1"] = C_AddOns.GetAddOnMetadata(myname, "X-LoadOn-Slash")
SlashCmdList[myname:upper()] = function(msg)
    if frame:IsVisible() then
        frame:Hide()
    else
        frame:Show()
    end
end

function frame:ShowWith(texture, ...)
    self:Show()
    frame.input:SetText(texture)
    if ... then
        frame.texcoords:SetText(string.join(", ", ...))
    end
end

