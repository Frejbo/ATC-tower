shader_type spatial;
render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D constant_marks_texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D livery_texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;

void fragment() {
	vec2 base_uv = UV;
	vec4 constant_marks_albedo_tex = texture(constant_marks_texture_albedo, base_uv);
	vec4 livery_albedo_tex = texture(livery_texture_albedo, base_uv);
	ALBEDO = albedo.rgb * mix(livery_albedo_tex, constant_marks_albedo_tex, constant_marks_albedo_tex.a).rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
}