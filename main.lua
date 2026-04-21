-- Save this as ~/.config/yazi/plugins/video-duration.yazi/init.lua

local function is_video_file(path)
	local ext = path:match("%.([^%.]+)$")
	if not ext then
		return false
	end
	ext = ext:lower()
	local video_extensions = {
		mp4 = true, mkv = true, avi = true, mov = true,
		webm = true, flv = true, wmv = true, m4v = true,
		mpg = true, mpeg = true, ["3gp"] = true, ts = true,
		mts = true, m2ts = true, ogv = true, vob = true
	}
	return video_extensions[ext] or false
end

local selected_or_hovered = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, u in pairs(tab.selected) do
		local path = tostring(u)
		if is_video_file(path) then
			paths[#paths + 1] = path
		end
	end
	if #paths == 0 and tab.current.hovered then
		local path = tostring(tab.current.hovered.url)
		if is_video_file(path) then
			paths[1] = path
		end
	end
	return paths
end)

return {
	entry = function()
		ya.mgr_emit("escape", { visual = true }) -- Deselects if in visual mode
		local urls = selected_or_hovered()
		
		if #urls == 0 then
			return ya.notify({
				title = "Video Duration",
				content = "No video file selected or hovered.",
				level = "warn",
				timeout = 5,
			})
		end

		local total_ms = 0
		local video_count = 0

		for _, file_path in ipairs(urls) do
			-- Get duration in milliseconds
			local status = Command("mediainfo")
				:arg("--Inform=General;%Duration%")
				:arg(file_path)
				:stdout(Command.PIPED)
				:stderr(Command.PIPED)
				:output()

			if status and status.status.success then
				local duration_str = status.stdout:gsub("%s+", "")
				local duration_ms = tonumber(duration_str)
				
				if duration_ms and duration_ms > 0 then
					total_ms = total_ms + duration_ms
					video_count = video_count + 1
				end
			else
				local filename = file_path:match("([^/]+)$")
				ya.notify({
					title = "Video Duration",
					content = string.format("Failed to get duration for: %s", filename),
					level = "error",
					timeout = 3,
				})
			end
		end

		if video_count == 0 then
			return ya.notify({
				title = "Video Duration",
				content = "Could not get duration for any video files.",
				level = "warn",
				timeout = 5,
			})
		end

		-- Convert milliseconds to hours, minutes, seconds
		local total_seconds = math.floor(total_ms / 1000)
		local hours = math.floor(total_seconds / 3600)
		local minutes = math.floor((total_seconds % 3600) / 60)
		local seconds = total_seconds % 60

		-- Build time string, omitting zero-value units
		local parts = {}
		if hours > 0 then parts[#parts + 1] = hours .. "h" end
		if minutes > 0 then parts[#parts + 1] = minutes .. "m" end
		if seconds > 0 or #parts == 0 then parts[#parts + 1] = seconds .. "s" end
		local time_str = table.concat(parts, " ")

		-- Build the notification content
		local content = string.format("Found %d video file%s\n\nTotal Duration: %s",
			video_count,
			video_count ~= 1 and "s" or "",
			time_str
		)

		ya.notify({
			title = "Video Duration",
			content = content,
			level = "info",
			timeout = 3,
		})
	end,
}
