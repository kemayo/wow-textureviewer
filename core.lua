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
frame:SetHeight(200)
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

local CreateInput = function(parent)
    local input = CreateFrame("EditBox", nil, parent, "BackdropTemplate") --, "ChatFrameEditBoxTemplate")
    input:SetFontObject("GameFontHighlight")
    input:SetTextInsets(10, 10, 3, 3) -- left, right, top, bottom
    input:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4, },
    })
    input:SetBackdropColor(0.1, 0.1, 0.2, 1)
    input:SetBackdropBorderColor(0.8, 0.8, 0.9, 0.4)

    input:SetScript("OnEscapePressed", function(self) parent:Hide() end)
    input:SetScript("OnLeave", GameTooltip_Hide)
    return input
end


frame.texture = frame:CreateTexture("ARTWORK", nil)

frame.input = CreateInput(frame)
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

frame.texcoords = CreateInput(frame)
frame.texcoords:SetPoint("TOPLEFT", frame.input, "BOTTOMLEFT", 0, -10)
frame.texcoords:SetPoint("TOPRIGHT", frame.input, "BOTTOMRIGHT", 0, -10)
frame.texcoords:SetHeight(frame.input:GetHeight())
frame.texcoords:Disable()

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

local colorupdate = function(self, by_user_input)
    local r, g, b = tonumber(frame.colorr:GetText()), tonumber(frame.colorg:GetText()), tonumber(frame.colorb:GetText())
    frame.texture:SetVertexColor(r or 0, g or 0, b or 0)
end

frame.colorr = CreateInput(frame)
frame.colorr:SetPoint("TOPLEFT", frame.texcoords, "BOTTOMLEFT", 0, -10)
frame.colorr:SetWidth(frame.texcoords:GetWidth() / 3)
frame.colorr:SetHeight(frame.input:GetHeight())
frame.colorr:SetText("1")
frame.colorr:SetBackdropBorderColor(1, 0, 0, 1)
frame.colorr:SetScript("OnTextChanged", colorupdate)

frame.colorg = CreateInput(frame)
frame.colorg:SetWidth(frame.texcoords:GetWidth() / 3)
frame.colorg:SetHeight(frame.input:GetHeight())
frame.colorg:SetText("1")
frame.colorg:SetBackdropBorderColor(0, 1, 0, 1)
frame.colorg:SetScript("OnTextChanged", colorupdate)

frame.colorb = CreateInput(frame)
frame.colorb:SetPoint("TOPRIGHT", frame.texcoords, "BOTTOMRIGHT", 0, -10)
frame.colorb:SetWidth(frame.texcoords:GetWidth() / 3)
frame.colorb:SetHeight(frame.input:GetHeight())
frame.colorb:SetText("1")
frame.colorb:SetBackdropBorderColor(0, 0, 1, 1)
frame.colorb:SetScript("OnTextChanged", colorupdate)

frame.colorg:SetPoint("LEFT", frame.colorr, "RIGHT", 0, 0)
frame.colorg:SetPoint("RIGHT", frame.colorb, "LEFT", 0, 0)

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

