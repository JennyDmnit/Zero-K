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
	Spring.Echo(WG.showpath)
	if (#Spring.GetSelectedUnits() ~= 0 and (spGetMapDrawMode() == "pathTraversability") ~= WG.showpath) then
		spSendCommands("ShowPathTraversability")
	else 
		Spring.Echo("No unit selected this is where we'd draw the new shader")
	end
end

WG.TogglePath = TogglePath

if not gl.CreateShader then
	Spring.Echo(GetInfo().name .. ": GLSL not supported.")
	return
end

shaderProgram = gl.CreateShader({
	vertex = [[#version 130
		varying vec2 texCoord;

		void main() {
			texCoord = gl_MultiTexCoord0.st;
			gl_Position = vec4(gl_Vertex.xyz, 1.0);
		}
	]],
	fragment = [[
		#version 130
		uniform sampler2D tex0;
		varying vec2 texCoord;

		const float vehCliff = 0.4546;
		const float botCliff = 0.8065;
		
		void main() {
    		vec4 norm = texture2D(tex0, texCoord);
    		vec2 norm2d = vec2(norm.x, norm.a);
    		float slope = length(norm2d);
			if (slope < vehCliff) {
				gl_FragColor =  vec4(0.0,1.0,0.0,1.0);
			} 
			else if (slope < botCliff) {
				gl_FragColor =  vec4(1.0,1.0,0.0,1.0);

			}
			else {
				gl_FragColor =  vec4(1.0,0.0,0.0,1.0);
			}
			gl_FragColor.a = 0.3;
		}
	]],
	uniformInt = {
		tex0 = 0,
	},
	textures = {
		[0] = "$normals",
	},
})

if not shaderProgram then
	Spring.Log(widget:GetInfo().name, LOG.ERROR, gl.GetShaderLog())
	return
end

function widget:Update(dt)
	if (#Spring.GetSelectedUnits() ~= 0 and (spGetMapDrawMode() == "pathTraversability") == false and WG.showpath == true) then
		spSendCommands("ShowPathTraversability")
	elseif (#Spring.GetSelectedUnits() == 0 and (spGetMapDrawMode() == "pathTraversability") == true and WG.showpath == true) then
		spSendCommands("ShowPathTraversability")
	end
end

function widget:Initialize()
	Spring.SetMapShader(shaderProgram)
end

function widget:Shutdown()

end


function widget:DrawGroundPreForward()
end
