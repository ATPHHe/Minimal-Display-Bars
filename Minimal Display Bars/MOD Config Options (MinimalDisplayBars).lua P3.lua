-- Persistent Data (for MinimalDisplayBars_Test)
local multiRefObjects = {

} -- multiRefObjects
local obj1 = {
	["moveBarsTogether"] = false;
	["menu"] = {
		["x"] = 70;
		["y"] = 15;
		["width"] = 15;
		["height"] = 15;
		["l"] = 3;
		["t"] = 3;
		["r"] = 3;
		["b"] = 3;
		["color"] = {
			["red"] = 1;
			["green"] = 1;
			["blue"] = 1;
			["alpha"] = 0.75;
		};
		["isMovable"] = true;
		["isResizable"] = false;
		["isVisible"] = true;
		["isVertical"] = true;
		["alwaysBringToTop"] = true;
		["showMoodletThresholdLines"] = true;
		["isCompact"] = false;
		["imageName"] = "";
		["showImage"] = false;
	};
	["hp"] = {
		["x"] = 70;
		["y"] = 30;
		["width"] = 15;
		["height"] = 150;
		["l"] = 3;
		["t"] = 3;
		["r"] = 3;
		["b"] = 3;
		["color"] = {
			["red"] = 0;
			["green"] = 0.5019607843137255;
			["blue"] = 0;
			["alpha"] = 0.75;
		};
		["isMovable"] = true;
		["isResizable"] = false;
		["isVisible"] = true;
		["isVertical"] = true;
		["alwaysBringToTop"] = true;
		["showMoodletThresholdLines"] = true;
		["isCompact"] = false;
		["imageName"] = "";
		["showImage"] = false;
	};
	["hunger"] = {
		["x"] = 85;
		["y"] = 30;
		["width"] = 8;
		["height"] = 150;
		["l"] = 2;
		["t"] = 3;
		["r"] = 2;
		["b"] = 3;
		["color"] = {
			["red"] = 1;
			["green"] = 1;
			["blue"] = 0.0392156862745098;
			["alpha"] = 0.75;
		};
		["isMovable"] = true;
		["isResizable"] = false;
		["isVisible"] = true;
		["isVertical"] = true;
		["alwaysBringToTop"] = true;
		["showMoodletThresholdLines"] = true;
		["isCompact"] = false;
		["imageName"] = "media/ui/Moodle_hungry.png";
		["showImage"] = false;
	};
	["thirst"] = {
		["x"] = 93;
		["y"] = 30;
		["width"] = 8;
		["height"] = 150;
		["l"] = 2;
		["t"] = 3;
		["r"] = 2;
		["b"] = 3;
		["color"] = {
			["red"] = 0.6784313725490196;
			["green"] = 0.8470588235294118;
			["blue"] = 0.9019607843137255;
			["alpha"] = 0.75;
		};
		["isMovable"] = true;
		["isResizable"] = false;
		["isVisible"] = true;
		["isVertical"] = true;
		["alwaysBringToTop"] = true;
		["showMoodletThresholdLines"] = true;
		["isCompact"] = false;
		["imageName"] = "media/ui/Moodle_thirsty.png";
		["showImage"] = false;
	};
	["endurance"] = {
		["x"] = 101;
		["y"] = 30;
		["width"] = 8;
		["height"] = 150;
		["l"] = 2;
		["t"] = 3;
		["r"] = 2;
		["b"] = 3;
		["color"] = {
			["red"] = 0.9568627450980393;
			["green"] = 0.9568627450980393;
			["blue"] = 0.9568627450980393;
			["alpha"] = 0.75;
		};
		["isMovable"] = true;
		["isResizable"] = false;
		["isVisible"] = true;
		["isVertical"] = true;
		["alwaysBringToTop"] = true;
		["showMoodletThresholdLines"] = true;
		["isCompact"] = false;
		["imageName"] = "media/ui/Moodle_endurance.png";
		["showImage"] = false;
	};
	["fatigue"] = {
		["x"] = 109;
		["y"] = 30;
		["width"] = 8;
		["height"] = 150;
		["l"] = 2;
		["t"] = 3;
		["r"] = 2;
		["b"] = 3;
		["color"] = {
			["red"] = 0.9411764705882353;
			["green"] = 0.9411764705882353;
			["blue"] = 0.6666666666666666;
			["alpha"] = 0.75;
		};
		["isMovable"] = true;
		["isResizable"] = false;
		["isVisible"] = true;
		["isVertical"] = true;
		["alwaysBringToTop"] = true;
		["showMoodletThresholdLines"] = true;
		["isCompact"] = false;
		["imageName"] = "media/ui/Moodle_tired.png";
		["showImage"] = false;
	};
	["boredomlevel"] = {
		["x"] = 117;
		["y"] = 30;
		["width"] = 8;
		["height"] = 150;
		["l"] = 2;
		["t"] = 3;
		["r"] = 2;
		["b"] = 3;
		["color"] = {
			["red"] = 0.6666666666666666;
			["green"] = 0.6666666666666666;
			["blue"] = 0.6666666666666666;
			["alpha"] = 0.75;
		};
		["isMovable"] = true;
		["isResizable"] = false;
		["isVisible"] = true;
		["isVertical"] = true;
		["alwaysBringToTop"] = true;
		["showMoodletThresholdLines"] = true;
		["isCompact"] = false;
		["imageName"] = "media/ui/Moodle_bored.png";
		["showImage"] = false;
	};
	["unhappynesslevel"] = {
		["x"] = 125;
		["y"] = 30;
		["width"] = 8;
		["height"] = 150;
		["l"] = 2;
		["t"] = 3;
		["r"] = 2;
		["b"] = 3;
		["color"] = {
			["red"] = 0.5019607843137255;
			["green"] = 0.5019607843137255;
			["blue"] = 1;
			["alpha"] = 0.75;
		};
		["isMovable"] = true;
		["isResizable"] = false;
		["isVisible"] = true;
		["isVertical"] = true;
		["alwaysBringToTop"] = true;
		["showMoodletThresholdLines"] = true;
		["isCompact"] = false;
		["imageName"] = "media/ui/Moodle_unhappy.png";
		["showImage"] = false;
	};
	["temperature"] = {
		["x"] = 133;
		["y"] = 30;
		["width"] = 8;
		["height"] = 150;
		["l"] = 2;
		["t"] = 3;
		["r"] = 2;
		["b"] = 3;
		["color"] = {
			["red"] = 0;
			["green"] = 1;
			["blue"] = 0;
			["alpha"] = 0.75;
		};
		["isMovable"] = true;
		["isResizable"] = false;
		["isVisible"] = true;
		["isVertical"] = true;
		["alwaysBringToTop"] = true;
		["showMoodletThresholdLines"] = true;
		["isCompact"] = false;
		["imageName"] = "media/ui/MDBTemperature.png";
		["showImage"] = false;
	};
	["calorie"] = {
		["x"] = 141;
		["y"] = 30;
		["width"] = 8;
		["height"] = 150;
		["l"] = 2;
		["t"] = 3;
		["r"] = 2;
		["b"] = 3;
		["color"] = {
			["red"] = 0.39215686274509803;
			["green"] = 1;
			["blue"] = 0;
			["alpha"] = 0.75;
		};
		["isMovable"] = true;
		["isResizable"] = false;
		["isVisible"] = true;
		["isVertical"] = true;
		["alwaysBringToTop"] = true;
		["showMoodletThresholdLines"] = true;
		["isCompact"] = false;
		["imageName"] = "media/ui/TraitNutritionist.png";
		["showImage"] = false;
	};
}
return obj1
