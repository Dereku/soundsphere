local Class = require("aqua.util.Class")
local Drawable = require("aqua.graphics.Drawable")

local InputObject = Class:new()

InputObject.load = function(self)
	self.drawableReleased = love.graphics.newImage(self.playField.directoryPath .. "/" .. self.released)
	self.drawablePressed = love.graphics.newImage(self.playField.directoryPath .. "/" .. (self.pressed or self.released))
	self.drawableObject = Drawable:new({
		drawable = self.drawableReleased,
		layer = self.layer,
		cs = self.cs,
		x = self.x,
		y = self.y,
		sx = 1,
		sy = 1,
		color = {255, 255, 255, 255}
	})
	self.drawableObject:reload()
	self.container:add(self.drawableObject)
end

InputObject.update = function(self)
	self.drawableObject.sx = self.cs:X(1) / self.drawableObject.drawable:getWidth() * self.w
	self.drawableObject.sy = self.cs:Y(1) / self.drawableObject.drawable:getHeight() * self.h
	self.drawableObject:reload()
end

InputObject.unload = function(self)
	self.container:remove(self.drawableObject)
end

InputObject.receive = function(self, event)
	if event.name == "noteHandlerUpdated" then
		if
			event.noteHandler.inputType == self.inputType and
			event.noteHandler.inputIndex == self.inputIndex
		then
			if event.noteHandler.keyState == true then
				self.drawableObject.drawable = self.drawablePressed
			else
				self.drawableObject.drawable = self.drawableReleased
			end
		end
	end
end

return InputObject