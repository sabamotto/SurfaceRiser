Shader "Unlit/Surface Riser/Phong (64 steps)"
{
  Properties
  {
    _Bevel ("Bevel Scale", Range(0, 1)) = 0.1
    _Color ("Diffuse Color", Color) = (1,1,1,0)
    _Spec ("Specular Color", Color) = (1,1,1,1)
    _SpecLevel ("Specular Shininess", Float) = 5
    _Emit ("Ambient Color", Color) = (0,0,0,1)
    _MainTex ("Texture", 2D) = "white" {}
  }
  SubShader
  {
    Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" }
      Blend SrcAlpha OneMinusSrcAlpha
      Cull Off
      LOD 200
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

  #define OFFSET -1.0
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = -1;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.96875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.9375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.90625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.84375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.8125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.78125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.75
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.71875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.6875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.65625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.59375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.5625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.53125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.5
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.46875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.4375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.40625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.34375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.3125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.28125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.25
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.21875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.1875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.15625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.09375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.0625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET -0.03125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.0
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.03125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.0625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.09375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.15625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.1875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.21875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.25
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.28125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.3125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.34375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.40625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.4375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.46875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.5
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.53125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.5625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.59375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.65625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.6875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.71875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.75
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.78125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.8125
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.84375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.90625
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.9375
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 0.96875
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = 0;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

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

  #define OFFSET 1.0
  v2f vert (appdata_tan v)
  {
    v2f o;
    o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz - OFFSET * _Bevel * v.normal.xyz, 1));
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // convert light axes from world to local
    float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);
    float3 localCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos) - v.vertex.xyz;
    if (dot(v.normal, localCamera) > 0) {
      o.normal = -v.normal;
    } else {
      o.normal = v.normal;
    }
    float3 tang = v.tangent;
    float4x4 inv = transpose(float4x4(
      float4(tang, 0), float4(cross(v.normal, tang), 0),
      float4(v.normal, 0), float4(0, 0, 0, 1) ));
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
    if (c <= 0.3) discard; // no rendering

    fixed rc;
    i.normal.z = -1;
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
    if (length(i.normal) == 0) discard;

    // calc
    float3 c3 = (1 - _Color.a) * c4.rgb + _Color.a * _Color.rgb;
    float3 inorm = normalize(i.normal);
    float3 lnorm = normalize(i.light);
    fixed3 spec = pow(max(0, dot(reflect(-lnorm, inorm), i.camera)), _SpecLevel) * _LightColor0.rgb * _Spec.rgb;
    fixed3 diff = max(0, abs(dot(inorm, lnorm))) * _LightColor0.rgb * c3;
    fixed3 ambi = (unity_AmbientSky.rgb + _Emit) * c3;
    return fixed4(ambi + diff + spec, c);
  }
  ENDCG
}

  }
}
