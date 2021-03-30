# glua-material-avatar

Simple script demonstrating how to download Steam avatars and generate a Material from them using clientside GLua.

## Circle Avatars

This code could be combined with [Circles!](https://github.com/SneakySquid/Circles) to produce a textured circular avatar.

## Examples

### Basic Example

```lua
getAvatarMaterial(LocalPlayer():SteamID64(), function(mat)
	print("Downloaded", mat)
end)
```

### HUDPaint Example

```lua
local avatar, downloaded = ( Material("vgui/avatar_default") )
hook.Add("HUDPaint", "showMyAvatar", function()
	if not downloaded then
		downloaded = true
		-- NEVER call this every frame unless you are planning on DDoSing Steam.
		getAvatarMaterial(LocalPlayer():SteamID64(), function(mat)
			avatar = mat
		end)
	end

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(avatar)
	surface.DrawTexturedRect(50, 50, 128, 128)
end)
```

### VGUI Element Example

```lua
include("vgui-element.lua")

local avatar = vgui.Create("AvatarMaterial")
avatar:SetSize(128, 128)
avatar:SetPos(50, 200)
avatar:SetSteamID64(LocalPlayer():SteamID64())
--avatar:SetPlayer(LocalPlayer())
```
