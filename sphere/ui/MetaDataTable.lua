local CoordinateManager = require("aqua.graphics.CoordinateManager")
local TextFrame = require("aqua.graphics.TextFrame")
local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")

local MetaDataTable = {}

MetaDataTable.setData = function(self, data)
	self.data = data or {}
	self:updateValues()
	self:reload()
end

MetaDataTable.updateValues = function(self)
	self.artistText.text = self.data.artist or ""
	self.titleText.text = self.data.title or ""
	self.nameText.text = self.data.name or ""
	
	if self.data.creator then
		self.nameText.text = self.data.creator
	end
end

MetaDataTable.load = function(self)
	self.artistText = self.artistText or TextFrame:new({
		text = "",
		x1 = self.x1,
		y1 = self.y1,
		x2 = self.x2,
		y2 = self.y2 - (self.y2 - self.y1) / 2,
		cs1 = self.cs1,
		cs2 = self.cs2,
		align = {x = "left", y = "center"},
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 20)
	})
	
	self.titleText = self.titleText or TextFrame:new({
		text = "",
		x1 = self.x1,
		y1 = self.y1 + (self.y2 - self.y1) / 2,
		x2 = self.x2,
		y2 = self.y2,
		cs1 = self.cs1,
		cs2 = self.cs2,
		align = {x = "left", y = "center"},
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 26)
	})
	
	self.nameText = self.nameText or TextFrame:new({
		text = "",
		x1 = self.x1,
		y1 = self.y1,
		x2 = self.x2,
		y2 = self.y2 - (self.y2 - self.y1) / 2,
		cs1 = self.cs1,
		cs2 = self.cs2,
		align = {x = "right", y = "center"},
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 20)
	})
	
	self:reload()
end

MetaDataTable.reload = function(self)
	self.artistText:reload()
	self.titleText:reload()
	self.nameText:reload()
end

MetaDataTable.draw = function(self)
	self.artistText:draw()
	self.titleText:draw()
	self.nameText:draw()
end

return MetaDataTable
