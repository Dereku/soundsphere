local TextDisplay = require("sphere.game.PlayField.TextDisplay")

local ScoreDisplay = TextDisplay:new()

ScoreDisplay.getText = function(self)
	return (self.format):format(self.score[self.field])
end

return ScoreDisplay
