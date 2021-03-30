local getAvatarMaterial = include("material-avatar.lua")

local PANEL = {}

function PANEL:Init()
	self.m_Material = Material("vgui/avatar_default")
end

function PANEL:SetPlayer(ply)
	if ply:IsBot() then return end
	self.m_SteamID64 = ply:SteamID64()
	self:Download()
end

function PANEL:SetSteamID64(steamid64)
	self.m_SteamID64 = steamid64
	if steamid64 then
		self:Download()
	end
end

function PANEL:GetPlayer()
	if self.m_SteamID64 == nil then
		return NULL
	else
		-- This is slow. Don't call it every frame.
		return player.GetBySteamID64(self.m_SteamID64)
	end
end

function PANEL:GetMaterial()
	return self.m_Material
end

function PANEL:GetSteamID64()
	return self.m_SteamID64
end

function PANEL:Download()
	assert(self.m_SteamID64 ~= nil, "Tried to download the avatar image of a nil SteamID64!")
	getAvatarMaterial(self.m_SteamID64, function(mat)
		if not IsValid(self) then return end -- The panel could've been destroyed before it could download the avatar image.
		self.m_Material = mat
	end)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(self.m_Material)
	surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register("AvatarMaterial", PANEL, "Panel")