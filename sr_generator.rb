# parameters
path = 'Assets/SurfaceRiser/Shaders'
name = 'SurfaceRiser'
steps_list = [8, 16, 32, 64]

# main shader programs
maincode = <<'SHADERCODE'
Shader "Unlit/Surface Riser/{{steps}} steps"
{
  Properties
  {
    _Bevel ("Bevel Scale", Range(0, 1)) = 0.1
    _Color ("Override Color", Color) = (1,1,1,0)
    _Spec ("Specular Color", Color) = (1,1,1,1)
    _SpecLevel ("Specular Level", Float) = 5
    _Emit ("Emitter Color", Color) = (0,0,0,1)
    _MainTex ("Texture", 2D) = "white" {}
  }
  SubShader
  {
    Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" }
      Blend SrcAlpha OneMinusSrcAlpha
      Cull Off
      LOD 200
      {{passes}}
  }
}
SHADERCODE

passcode = <<'SHADERCODE'
Pass
{
  CGPROGRAM
  #pragma vertex vert
  #pragma fragment frag

  #include "UnityCG.cginc"
  #include "Lighting.cginc"

  struct v2f
  {
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float3 normal : TEXCOORD1;
    float3 light : TEXCOORD2;
    float3 camera : TEXCOORD3;
  };

  float _Bevel, _SpecLevel;
  fixed4 _Color, _Spec, _Emit;
  sampler2D _MainTex;
  float4 _MainTex_ST;
  // [pixel width, pixel height, tex width, tex height]
  float4 _MainTex_TexelSize;

  #define OFFSET {{offset}}
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    float3 norm = normalize(v.normal);
    float3 tang = v.tangent;
    if (dot(norm, localCamera) >= 0) {
      o.normal = -v.normal;
      norm = -norm;
    } else {
      o.normal = v.normal;
    }
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(norm, tang), 0),
      float4(norm, 0), float4(0, 0, 0, 1) ));
    o.light = mul(localLight, inv);
    o.camera = normalize(mul(localCamera, inv));
    return o;
  }

  fixed4 frag (v2f i) : SV_Target
  {
    // sample the texture
    float2 texel = float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y);
    fixed4 c4 = tex2D(_MainTex, i.uv);
    fixed c = c4.a;
    if (c <= 0.5) discard; // no rendering

    fixed rc;
    i.normal.z = {{normal_z}};
    // left top/middle/bottom
    rc = tex2D(_MainTex, i.uv - texel).a;
    if (rc < c) i.normal += float3(-1,  1,  0);
    rc = tex2D(_MainTex, i.uv + float2(-texel.x, 0)).a;
    if (rc < c) i.normal += float3(-1,  0,  0);
    rc = tex2D(_MainTex, i.uv + float2(-texel.x, texel.y)).a;
    if (rc < c) i.normal += float3(-1, -1,  0);
    // center top/bottom
    rc = tex2D(_MainTex, i.uv + float2(0, -texel.y)).a;
    if (rc < c) i.normal += float3( 0,  1,  0);
    rc = tex2D(_MainTex, i.uv + float2(0, texel.y)).a;
    if (rc < c) i.normal += float3( 0, -1,  0);
    // right top/middle/bottom
    rc = tex2D(_MainTex, i.uv + float2(texel.x, -texel.y)).a;
    if (rc < c) i.normal += float3( 1,  1,  0);
    rc = tex2D(_MainTex, i.uv + float2(texel.x, 0)).a;
    if (rc < c) i.normal += float3( 1,  0,  0);
    rc = tex2D(_MainTex, i.uv + texel).a;
    if (rc < c) i.normal += float3( 1, -1,  0);

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, dot(inorm, lnorm)) * _LightColor0.rgb * c3;
    fixed3 ambi = unity_AmbientSky.rgb * c3;
    return fixed4(_Emit + ambi + diff + spec, c * c);
  }
  ENDCG
}
SHADERCODE

steps_list.each do |steps|
  # generate
  passes = []
  (steps+1).times do |s|
    passes << passcode.gsub(/\{\{[\w_]+\}\}/, {
      '{{offset}}' => 2.0 * s.to_f / steps - 1.0,
      '{{normal_z}}' => (s == 0 or s == steps) ? -1 : 0
    })
  end

  # make shader files
  fullcode = maincode.gsub(/\{\{[\w_]+\}\}/, {
    '{{steps}}' => steps,
    '{{passes}}' => passes.join("\n")
  })
  File.write "#{path}/#{name}_#{steps}steps.shader", fullcode
end