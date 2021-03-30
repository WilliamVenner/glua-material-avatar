local AVATAR_IMAGE_CACHE_EXPIRES = 86400

local function getAvatarMaterial(steamid64, callback)
	-- First, check the cache to see if this avatar has already been downloaded.
	-- If the avatar hasn't been cached in data/, file.Time will return 0.
	-- If an avatar material is 1 day old, let's redownload it but use it as a fallback in case something goes wrong.
	local fallback
	if os.time() - file.Time("avatars/" .. steamid64 .. ".png", "DATA") > AVATAR_IMAGE_CACHE_EXPIRES then
		fallback = Material("../data/avatars/" .. steamid64 .. ".png", "smooth")
	elseif os.time() - file.Exists("avatars/" .. steamid64 .. ".jpg", "DATA") > AVATAR_IMAGE_CACHE_EXPIRES then
		fallback = Material("../data/avatars/" .. steamid64 .. ".jpg", "smooth")
	end

	-- If a fallback couldn't be found in data/, default to vgui/avatar_default
	if not fallback or fallback:IsError() then
		fallback = Material("vgui/avatar_default")
	else
		-- Otherwise, if a cached avatar was found, and it hasn't expired, return it!
		return callback(fallback)
	end

	-- Fetch the XML version of the player's Steam profile.
	-- This XML contains a tag, <avatarFull> which contains the URL to their full avatar.
	http.Fetch("https://steamcommunity.com/profiles/" .. steamid64 .. "?xml=1",
	
		function(body, size, headers, code)
			-- If the HTTP request fails (size = 0, code is not a HTTP success response code) then return the fallback
			if size == 0 or code < 200 or code > 299 then return callback(fallback, steamid64) end

			local url, fileType = body:match("<avatarFull>.-(https?://%S+%f[%.]%.)(%w+).-</avatarFull>") -- Extract the URL and file extension from <avatarFull>
			if not url or not fileType then return callback(fallback, steamid64) end -- If the URL or file type couldn't be extracted, return the fallback.
			if fileType == "jpeg" then fileType = "jpg" end -- Defensively ensure jpeg -> jpg.

			-- Download the avatar image
			http.Fetch(url .. fileType,
				
				function(body, size, headers, code)
					if size == 0 or code < 200 or code > 299 then return callback(fallback, steamid64) end

					local cachePath = "avatars/" .. steamid64 .. "." .. fileType
					file.CreateDir("avatars")
					file.Write(cachePath, body) -- Write the avatar to data/

					local material = Material("../data/" .. cachePath, "smooth") -- Load the avatar from data/ as a Material
					if material:IsError() then
						-- If the material errors, the image must be corrupt, so we'll delete this from data/ and return the fallback.
						file.Delete(cachePath)
						callback(fallback, steamid64)
					else
						-- We succeeded, return the downloaded avatar image material!
						callback(material, steamid64)
					end

				end,

				-- If we hard-fail, return the fallback image.
				function() callback(fallback, steamid64) end

			)
		end,
		
		-- If we hard-fail, return the fallback image.
		function() callback(fallback, steamid64) end
	)
end

-- We don't want to fill the user's hard drive up with avatars over time, so we'll clear them whenever they join the server.
-- This also has the added benefit of allowing the user to "manually" regenerate avatars if they so desire.
local function clearCachedAvatars()
	for _, f in ipairs( ( file.Find("avatars/*", "DATA") ) ) do
		file.Delete("avatars/" .. f)
	end

	hook.Remove("InitPostEntity", "clearCachedAvatars") -- Just to be safe.
end
hook.Add("InitPostEntity", "clearCachedAvatars", clearCachedAvatars)

return getAvatarMaterial
