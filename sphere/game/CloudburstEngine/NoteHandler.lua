local Class = require("aqua.util.Class")
local ShortLogicalNote = require("sphere.game.CloudburstEngine.note.ShortLogicalNote")
local LongLogicalNote = require("sphere.game.CloudburstEngine.note.LongLogicalNote")
local FileManager = require("sphere.filesystem.FileManager")
local AudioManager = require("aqua.audio.AudioManager")

local NoteHandler = Class:new()

NoteHandler.autoplayDelay = 1/15

NoteHandler.loadNoteData = function(self)
	self.noteData = {}
	
	for layerDataIndex in self.engine.noteChart:getLayerDataIndexIterator() do
		local layerData = self.engine.noteChart:requireLayerData(layerDataIndex)
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			
			if noteData.inputType == self.inputType and noteData.inputIndex == self.inputIndex then
				local logicalNote
				
				local soundFilePath
				if noteData.soundFileName then
					if not self.engine.soundFiles[noteData.soundFileName] then
						self.engine.soundFiles[noteData.soundFileName] = FileManager:findFile(noteData.soundFileName, "audio")
					end
					soundFilePath = self.engine.soundFiles[noteData.soundFileName]
				end
				
				if noteData.noteType == "ShortNote" then
					logicalNote = ShortLogicalNote:new({
						startNoteData = noteData,
						pressSoundFilePath = soundFilePath,
						noteType = "ShortNote"
					})
				elseif noteData.noteType == "LongNoteStart" then
					logicalNote = LongLogicalNote:new({
						startNoteData = noteData,
						endNoteData = noteData.endNoteData,
						pressSoundFilePath = soundFilePath,
						noteType = "LongNote"
					})
				elseif noteData.noteType == "LineNoteStart" then
					logicalNote = ShortLogicalNote:new({
						startNoteData = noteData,
						endNoteData = noteData.endNoteData,
						pressSoundFilePath = soundFilePath,
						noteType = "SoundNote"
					})
				elseif noteData.noteType == "SoundNote" then
					logicalNote = ShortLogicalNote:new({
						startNoteData = noteData,
						pressSoundFilePath = soundFilePath,
						noteType = "SoundNote"
					})
				end
				
				if logicalNote then
					logicalNote.noteHandler = self
					logicalNote.engine = self.engine
					logicalNote.score = self.engine.score
					table.insert(self.noteData, logicalNote)
					
					self.engine.sharedLogicalNoteData[noteData] = logicalNote
				end
			end
		end
	end
	
	table.sort(self.noteData, function(a, b)
		return a.startNoteData.timePoint < b.startNoteData.timePoint
	end)

	for index, logicalNote in ipairs(self.noteData) do
		logicalNote.index = index
	end
	
	self.startNoteIndex = 1
	self.currentNote = self.noteData[1]
end

NoteHandler.setKeyState = function(self)
	self.keyBind = self.engine.inputMode:getString() .. ":" .. self.inputType .. self.inputIndex
	self.keyState = love.keyboard.isDown(self.keyBind)
end

NoteHandler.update = function(self)
	self.currentNote:update()
	if self.click then
		self.keyTimer = self.keyTimer + love.timer.getDelta()
		if self.keyTimer > self.autoplayDelay then
			self.click = false
			self:switchKey(false)
		end
	end
end

NoteHandler.receive = function(self, event)
	local key = event.args and event.args[1]
	if self.keyBind and key == self.keyBind then
		if event.name == "keypressed" then
			self:playAudio(self.currentNote.pressSoundFilePath)
			
			self.currentNote.keyState = true
			return self:switchKey(true)
		elseif event.name == "keyreleased" then
			self:playAudio(self.currentNote.releaseSoundFilePath)
			
			self.currentNote.keyState = false
			return self:switchKey(false)
		end
	end
end

NoteHandler.playAudio = function(self, path)
	local audio = AudioManager:getAudio(path)
	if audio then
		audio:play()
		audio:rate(self.engine.rate)
	end
end

NoteHandler.switchKey = function(self, state)
	self.keyState = state
	return self:sendState()
end

NoteHandler.clickKey = function(self)
	self.keyTimer = 0
	self.click = true
	self.keyState = true
	
	return self:sendState()
end

NoteHandler.sendState = function(self)
	return self.engine.observable:send({
		name = "noteHandlerUpdated",
		noteHandler = self
	})
end

NoteHandler.load = function(self)
	self:loadNoteData()
	self:setKeyState()
end

NoteHandler.unload = function(self) end

return NoteHandler