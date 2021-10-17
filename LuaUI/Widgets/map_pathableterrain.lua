function widget:GetInfo() return {
	name    = "Pathability shader",
	desc    = "Improved pathability overlay for when no units are selected",
	author  = "JennyDmnit",
	date    = "2021/10/15",
	license = "GPL",
	layer   = 0,
	enabled = true,
    handler   = true,
} end

local normalsTexture = "$normals"
local mapSizeX, mapSizeZ = Game.mapSizeX, Game.mapSizeZ

local spGetMapDrawMode = Spring.GetMapDrawMode
local spSendCommands   = Spring.SendCommands

local function TogglePath()
	WG.showpath = not WG.showpath
	Spring.Echo(spGetMapDrawMode())
	if ((spGetMapDrawMode() == "pathTraversability") ~= WG.showpath) then
		spSendCommands("ShowPathTraversability")
	end
end

WG.TogglePath = TogglePath


-- if not gl.CreateShader then
-- 	Spring.Echo(GetInfo().name .. ": GLSL not supported.")
-- 	return
-- end

-- local shaderProgram = gl.CreateShader({
-- 	vertex = [[
-- 		#version 130
-- 		varying vec2 texCoord;

-- 		void main() {
-- 			texCoord = gl_MultiTexCoord0.st;
-- 			gl_Position = vec4(gl_Vertex.xyz, 1.0);
-- 		}
-- 	]],
-- 	fragment = [[
-- 		#version 130
-- 		uniform sampler2D tex0;
-- 		varying vec2 texCoord;

-- 		const float hardCliffMax = 1.0; // sharpest bot-blocking cliff
-- 		const float hardCliffMin = 0.58778525229; // least sharp bot-blocking cliff

-- 		const float vehCliff = 0.4546;
-- 		const float botCliff = 0.8065;

-- 		const float softCliffMax = hardCliffMin;
-- 		const float bandingMin = 0.12;
-- 		const float vehCliffMinus = 0.24;
-- 		const float vehCliffEpsilon = 0.492;
-- 		const float vehCliffPlus = 0.62;
-- 		const float botCliffMinus = botCliff - 0.06;
-- 		const float botCliffMinusMinus = 0.65;

-- 		void main() {
--     		vec4 norm = texture2D(tex0, texCoord);
--     		vec2 norm2d = vec2(norm.x, norm.a);
--     		float slope = length(norm2d);
-- 			if (slope < vehCliff) {
-- 				gl_FragColor =  vec4(0.0,1.0,0.0,1.0);
-- 			} 
-- 			else if (slope < botCliff) {
-- 				gl_FragColor =  vec4(1.0,1.0,0.0,1.0);

-- 			}
-- 			else {
-- 				gl_FragColor =  vec4(1.0,0.0,0.0,1.0);
-- 			}
-- 			gl_FragColor.a = 0.3;
-- 		}
-- 	]]
-- })
-- if not shaderProgram then
-- 	Spring.Log(widget:GetInfo().name, LOG.ERROR, gl.GetShaderLog())
-- 	return
-- end

function widget:Initialize()
	-- spSendCommands("ShowPathTraversability")
end

function widget:Shutdown()
end


function widget:DrawWorldPreUnit()
end
