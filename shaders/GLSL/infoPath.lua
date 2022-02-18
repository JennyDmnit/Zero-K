return {
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
		uniform Int unitsSelected;
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
			if (unitsSelected > 0) {
				gl_FragColor = vec4(1.0,0.0,1.0,1.0);
			}
		}
	]],
	uniformInt = {
		tex0 = 0,
		unitsSelected = select(1, Spring.GetSelectedUnitsCount ()),
	},
	textures = {
		[0] = "$normals",
	},
}
