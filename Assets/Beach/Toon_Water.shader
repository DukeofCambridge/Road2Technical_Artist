// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon_Water"
{
	Properties
	{
		_WaveASpeedXYSteepnesswavelength("WaveA(SpeedXY,Steepness,wavelength)", Vector) = (1,1,2,50)
		_WaveB("WaveB", Vector) = (1,1,2,50)
		_WaveC("WaveC", Vector) = (1,1,2,50)
		_DeepColor("DeepColor", Color) = (0,0,0,0)
		_ShallowColor("ShallowColor", Color) = (0,0,0,0)
		_DeepRange("DeepRange", Float) = 0
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_FresnelPower("FresnelPower", Float) = 0
		_NormalScale("NormalScale", Float) = 0
		_NormalSpeed("NormalSpeed", Vector) = (0,0,0,0)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_ReflectionTex("ReflectionTex", 2D) = "white" {}
		_ReflectDistortion("ReflectDistortion", Float) = 0
		_ReflectionIntensity("ReflectionIntensity", Float) = 0
		_ReflectionPower("ReflectionPower", Float) = 0
		_UnderwaterDistortion("UnderwaterDistortion", Float) = 0
		_CausticScale("CausticScale", Float) = 0
		_CausticSpeed("CausticSpeed", Vector) = (0,0,0,0)
		_CausticTex("CausticTex", 2D) = "white" {}
		_CausticIntensity("CausticIntensity", Float) = 0
		_CausticRange("CausticRange", Float) = 0
		_ShoreRange("ShoreRange", Float) = 0
		_ShoreColor("ShoreColor", Color) = (0.9150943,0.9150943,0.9150943,0.07058824)
		_ShoreEdgeWidth("ShoreEdgeWidth", Range( 0 , 1)) = 0
		_ShoreEdgeIntensity("ShoreEdgeIntensity", Range( 0 , 1)) = 0
		_FoamSpeed("FoamSpeed", Float) = 0
		_FoamRange("FoamRange", Float) = 1
		_FoamBlend("FoamBlend", Range( 0 , 1)) = 0
		_FoamFrequency("FoamFrequency", Float) = 20
		_FoamDissolve("FoamDissolve", Float) = 0
		_FoamColor("FoamColor", Color) = (0.8773585,0.8773585,0.8773585,0.827451)
		_FoamNoiseSize("FoamNoiseSize", Vector) = (10,10,0,0)
		_FoamWidth("FoamWidth", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		GrabPass{ }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
			float3 worldNormal;
			float2 uv_texcoord;
		};

		uniform float4 _WaveASpeedXYSteepnesswavelength;
		uniform float4 _WaveB;
		uniform float4 _WaveC;
		uniform float4 _DeepColor;
		uniform float4 _ShallowColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DeepRange;
		uniform float4 _FresnelColor;
		uniform float _FresnelPower;
		uniform sampler2D _ReflectionTex;
		uniform sampler2D _NormalMap;
		uniform float _NormalScale;
		uniform float2 _NormalSpeed;
		uniform float _ReflectDistortion;
		uniform float _ReflectionIntensity;
		uniform float _ReflectionPower;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _UnderwaterDistortion;
		uniform sampler2D _CausticTex;
		uniform float _CausticScale;
		uniform float2 _CausticSpeed;
		uniform float _CausticIntensity;
		uniform float _CausticRange;
		uniform float4 _ShoreColor;
		uniform float _ShoreRange;
		uniform float _FoamBlend;
		uniform float _FoamRange;
		uniform float _FoamWidth;
		uniform float _FoamFrequency;
		uniform float _FoamSpeed;
		uniform float2 _FoamNoiseSize;
		uniform float _FoamDissolve;
		uniform float4 _FoamColor;
		uniform float _ShoreEdgeWidth;
		uniform float _ShoreEdgeIntensity;


		float3 GerstnerWave188( float3 position, inout float3 tangent, inout float3 binormal, float4 wave )
		{
			float steepness = wave.z * 0.01;
			float wavelength = wave.w;
			float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, position.xz) - c * _Time.y);
			float a = steepness / k;
						
			tangent += float3(
			-d.x * d.x * (steepness * sin(f)),
			d.x * (steepness * cos(f)),
			-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
			-d.x * d.y * (steepness * sin(f)),
			d.y * (steepness * cos(f)),
			-d.y * d.y * (steepness * sin(f))
			);
			return float3(
			d.x * (a * cos(f)),
			a * sin(f),
			d.y * (a * cos(f))
			);
		}


		float3 GerstnerWave196( float3 position, inout float3 tangent, inout float3 binormal, float4 wave )
		{
			float steepness = wave.z * 0.01;
			float wavelength = wave.w;
			float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, position.xz) - c * _Time.y);
			float a = steepness / k;
						
			tangent += float3(
			-d.x * d.x * (steepness * sin(f)),
			d.x * (steepness * cos(f)),
			-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
			-d.x * d.y * (steepness * sin(f)),
			d.y * (steepness * cos(f)),
			-d.y * d.y * (steepness * sin(f))
			);
			return float3(
			d.x * (a * cos(f)),
			a * sin(f),
			d.y * (a * cos(f))
			);
		}


		float3 GerstnerWave203( float3 position, inout float3 tangent, inout float3 binormal, float4 wave )
		{
			float steepness = wave.z * 0.01;
			float wavelength = wave.w;
			float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, position.xz) - c * _Time.y);
			float a = steepness / k;
						
			tangent += float3(
			-d.x * d.x * (steepness * sin(f)),
			d.x * (steepness * cos(f)),
			-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
			-d.x * d.y * (steepness * sin(f)),
			d.y * (steepness * cos(f)),
			-d.y * d.y * (steepness * sin(f))
			);
			return float3(
			d.x * (a * cos(f)),
			a * sin(f),
			d.y * (a * cos(f))
			);
		}


		float2 UnStereo( float2 UV )
		{
			#if UNITY_SINGLE_PASS_STEREO
			float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
			UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
			#endif
			return UV;
		}


		float3 InvertDepthDir72_g1( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		//https://www.shadertoy.com/view/XdXGW8
		float2 GradientNoiseDir( float2 x )
		{
			const float2 k = float2( 0.3183099, 0.3678794 );
			x = x * k + k.yx;
			return -1.0 + 2.0 * frac( 16.0 * k * frac( x.x * x.y * ( x.x + x.y ) ) );
		}
		
		float GradientNoise( float2 UV, float Scale )
		{
			float2 p = UV * Scale;
			float2 i = floor( p );
			float2 f = frac( p );
			float2 u = f * f * ( 3.0 - 2.0 * f );
			return lerp( lerp( dot( GradientNoiseDir( i + float2( 0.0, 0.0 ) ), f - float2( 0.0, 0.0 ) ),
					dot( GradientNoiseDir( i + float2( 1.0, 0.0 ) ), f - float2( 1.0, 0.0 ) ), u.x ),
					lerp( dot( GradientNoiseDir( i + float2( 0.0, 1.0 ) ), f - float2( 0.0, 1.0 ) ),
					dot( GradientNoiseDir( i + float2( 1.0, 1.0 ) ), f - float2( 1.0, 1.0 ) ), u.x ), u.y );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 position188 = ase_worldPos;
			float3 tangent188 = float3( 1,0,0 );
			float3 binormal188 = float3( 0,0,1 );
			float4 wave188 = _WaveASpeedXYSteepnesswavelength;
			float3 localGerstnerWave188 = GerstnerWave188( position188 , tangent188 , binormal188 , wave188 );
			float3 position196 = ase_worldPos;
			float3 tangent196 = tangent188;
			float3 binormal196 = binormal188;
			float4 wave196 = _WaveB;
			float3 localGerstnerWave196 = GerstnerWave196( position196 , tangent196 , binormal196 , wave196 );
			float3 position203 = ase_worldPos;
			float3 tangent203 = tangent196;
			float3 binormal203 = binormal196;
			float4 wave203 = _WaveC;
			float3 localGerstnerWave203 = GerstnerWave203( position203 , tangent203 , binormal203 , wave203 );
			float3 temp_output_191_0 = ( ase_worldPos + localGerstnerWave188 + localGerstnerWave196 + localGerstnerWave203 );
			float3 worldToObj192 = mul( unity_WorldToObject, float4( temp_output_191_0, 1 ) ).xyz;
			float3 WaveVertexPos194 = worldToObj192;
			v.vertex.xyz = WaveVertexPos194;
			v.vertex.w = 1;
			float3 normalizeResult198 = normalize( cross( binormal203 , tangent203 ) );
			float3 worldToObjDir199 = mul( unity_WorldToObject, float4( normalizeResult198, 0 ) ).xyz;
			float3 WaveVertexNormal200 = worldToObjDir199;
			v.normal = WaveVertexNormal200;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 UV22_g3 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g3 = UnStereo( UV22_g3 );
			float2 break64_g1 = localUnStereo22_g3;
			float clampDepth69_g1 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g1 = ( 1.0 - clampDepth69_g1 );
			#else
				float staticSwitch38_g1 = clampDepth69_g1;
			#endif
			float3 appendResult39_g1 = (float3(break64_g1.x , break64_g1.y , staticSwitch38_g1));
			float4 appendResult42_g1 = (float4((appendResult39_g1*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g1 = mul( unity_CameraInvProjection, appendResult42_g1 );
			float3 In72_g1 = ( (temp_output_43_0_g1).xyz / (temp_output_43_0_g1).w );
			float3 localInvertDepthDir72_g1 = InvertDepthDir72_g1( In72_g1 );
			float4 appendResult49_g1 = (float4(localInvertDepthDir72_g1 , 1.0));
			float3 PositionFromDepth218 = (mul( unity_CameraToWorld, appendResult49_g1 )).xyz;
			float temp_output_220_0 = ( ase_worldPos.y - (PositionFromDepth218).y );
			float WaterDepth223 = temp_output_220_0;
			float clampResult234 = clamp( exp( ( -WaterDepth223 / _DeepRange ) ) , 0.0 , 1.0 );
			float4 lerpResult226 = lerp( _DeepColor , _ShallowColor , clampResult234);
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV238 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode238 = ( 0.0 + 1.0 * pow( max( 1.0 - fresnelNdotV238 , 0.0001 ), _FresnelPower ) );
			float4 lerpResult237 = lerp( lerpResult226 , _FresnelColor , fresnelNode238);
			float4 WaterColor241 = lerpResult237;
			float2 temp_output_249_0 = ( ( (ase_worldPos).xz * -0.1 ) / _NormalScale );
			float2 temp_output_254_0 = ( _NormalSpeed * _Time.y * 0.01 );
			float3 SurfaceNormal259 = BlendNormals( UnpackNormal( tex2D( _NormalMap, ( temp_output_249_0 + temp_output_254_0 ) ) ) , UnpackNormal( tex2D( _NormalMap, ( ( temp_output_249_0 * 2.0 ) + ( temp_output_254_0 * -0.5 ) ) ) ) );
			float fresnelNdotV292 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode292 = ( 0.0 + _ReflectionIntensity * pow( max( 1.0 - fresnelNdotV292 , 0.0001 ), _ReflectionPower ) );
			float clampResult299 = clamp( fresnelNode292 , 0.0 , 1.0 );
			float4 ReflectionColor279 = ( tex2D( _ReflectionTex, ( (ase_screenPosNorm).xy + ( (SurfaceNormal259).xy * ( _ReflectDistortion * 0.01 ) ) ) ) * clampResult299 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor288 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ase_grabScreenPosNorm + float4( ( SurfaceNormal259 * _UnderwaterDistortion * 0.01 ) , 0.0 ) ).xy);
			float2 temp_output_302_0 = ( (PositionFromDepth218).xz / _CausticScale );
			float2 temp_output_307_0 = ( _CausticSpeed * _Time.y * 0.01 );
			float clampResult323 = clamp( exp( ( -WaterDepth223 / _CausticRange ) ) , 0.0 , 1.0 );
			float4 CausticColor313 = ( ( min( tex2D( _CausticTex, ( temp_output_302_0 + temp_output_307_0 ) ) , tex2D( _CausticTex, ( -temp_output_302_0 + temp_output_307_0 ) ) ) * _CausticIntensity ) * clampResult323 );
			float4 UnderwaterColor290 = ( screenColor288 + CausticColor313 );
			float WaterTransparency244 = (lerpResult237).a;
			float4 lerpResult296 = lerp( ( WaterColor241 + ReflectionColor279 ) , UnderwaterColor290 , WaterTransparency244);
			float4 ScreenColor336 = screenColor288;
			float3 ShoreColor346 = (( ScreenColor336 * _ShoreColor )).rgb;
			float clampResult342 = clamp( exp( ( -WaterDepth223 / _ShoreRange ) ) , 0.0 , 1.0 );
			float ShoreArea348 = clampResult342;
			float4 lerpResult349 = lerp( lerpResult296 , float4( ShoreColor346 , 0.0 ) , ShoreArea348);
			float clampResult371 = clamp( ( WaterDepth223 / _FoamRange ) , 0.0 , 1.0 );
			float smoothstepResult373 = smoothstep( _FoamBlend , 1.0 , ( clampResult371 + 0.0 ));
			float temp_output_372_0 = ( 1.0 - clampResult371 );
			float gradientNoise379 = GradientNoise(( i.uv_texcoord * _FoamNoiseSize ),1.0);
			gradientNoise379 = gradientNoise379*0.5 + 0.5;
			float4 Foam396 = ( ( ( 1.0 - smoothstepResult373 ) * step( ( temp_output_372_0 - _FoamWidth ) , ( ( temp_output_372_0 + ( sin( ( ( temp_output_372_0 * _FoamFrequency ) + ( _FoamSpeed * _Time.y ) ) ) + gradientNoise379 ) ) - _FoamDissolve ) ) ) * _FoamColor );
			float4 lerpResult400 = lerp( lerpResult349 , ( lerpResult349 + float4( (Foam396).rgb , 0.0 ) ) , (Foam396).a);
			float smoothstepResult356 = smoothstep( ( 1.0 - _ShoreEdgeWidth ) , 1.0 , ShoreArea348);
			float ShoreEdge359 = ( smoothstepResult356 * _ShoreEdgeIntensity );
			o.Emission = max( ( lerpResult400 + ShoreEdge359 ) , float4( 0,0,0,0 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float3 worldNormal : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
257.3333;72.66667;1109.333;572.3333;362.9478;-1391.36;1.865958;False;False
Node;AmplifyShaderEditor.CommentaryNode;245;-2152.254,197.0557;Inherit;False;1484.904;357.2927;;8;215;217;218;216;219;220;223;222;Water Depth;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;215;-2102.254,440.0704;Inherit;False;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;267;-2198.604,-553.9713;Inherit;False;1938.407;603.0083;;20;265;266;259;258;260;262;261;251;249;254;263;246;253;256;257;247;250;264;280;281;Surface Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;217;-1729.051,432.3485;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;246;-2165.593,-494.4154;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;218;-1511.051,439.3485;Inherit;False;PositionFromDepth;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;247;-1959.322,-498.4799;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;281;-1964.237,-421.7933;Inherit;False;Constant;_Float4;Float 4;15;0;Create;True;0;0;False;0;False;-0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;216;-1515.051,262.3483;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;219;-1234.05,431.3485;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;253;-1897.275,-278.5877;Inherit;False;Property;_NormalSpeed;NormalSpeed;11;0;Create;True;0;0;False;0;False;0,0;-10,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;250;-1828.428,-352.1829;Inherit;False;Property;_NormalScale;NormalScale;10;0;Create;True;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;280;-1760.734,-474.8783;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;256;-1900.298,-150.8347;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;220;-1101.049,323.3485;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;257;-1886.165,-69.44064;Inherit;False;Constant;_Float0;Float 0;12;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;314;1552.075,-1286.05;Inherit;False;1954.181;724.2302;;19;302;306;307;301;309;303;304;300;311;312;308;324;313;310;325;327;329;330;331;Caustic Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;264;-1634.013,-65.96286;Inherit;False;Constant;_Float2;Float 2;13;0;Create;True;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;397;-498.4848,469.3874;Inherit;False;2279.591;1049.693;;18;395;383;387;388;385;391;392;369;368;371;374;372;390;393;396;394;399;398;Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;263;-1635.278,-321.0325;Inherit;False;Constant;_Float1;Float 1;13;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;249;-1621.442,-475.5035;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;254;-1640.697,-240.0349;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;223;-947.5605,247.0555;Inherit;False;WaterDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;368;-448.4848,695.0848;Inherit;False;223;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;300;1587.684,-1220.06;Inherit;False;218;PositionFromDepth;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;374;-425.4848,815.0849;Inherit;False;Property;_FoamRange;FoamRange;28;0;Create;True;0;0;False;0;False;1;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;261;-1424.621,-270.0467;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;262;-1414.201,-102.045;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;369;-222.4848,738.0848;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;251;-1410.441,-425.9035;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;301;1836.588,-1216.862;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;265;-1256.49,-194.9818;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;303;1753.086,-1107.864;Inherit;False;Property;_CausticScale;CausticScale;18;0;Create;True;0;0;False;0;False;0;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;325;2199.404,-819.0043;Inherit;False;893.8286;241.2402;only show caustic effects at shoreside;6;319;318;315;317;321;323;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;306;1745.182,-753.4719;Inherit;False;Constant;_Float6;Float 6;20;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;258;-1183.304,-448.6878;Inherit;True;Property;_NormalMap;NormalMap;12;0;Create;True;0;0;False;0;False;-1;None;2aab2b9fb283e6646ad7f1df2f799dc1;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;308;1733.482,-843.1718;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;309;1733.483,-969.2715;Inherit;False;Property;_CausticSpeed;CausticSpeed;19;0;Create;True;0;0;False;0;False;0,0;-8,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;260;-1112.193,-223.6543;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Instance;258;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;371;-69.48482,759.0848;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;302;2019.852,-1164.082;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;395;-62.21666,887.1802;Inherit;False;783.1568;601.8325;Foam Shape;11;378;377;376;367;365;363;380;381;379;364;382;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;235;34.57325,-487.3892;Inherit;False;1855.737;719.1693;;16;244;241;243;237;226;238;236;224;234;225;239;232;230;229;228;227;Water Body Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;376;-8.216712,937.1802;Inherit;False;Property;_FoamFrequency;FoamFrequency;30;0;Create;True;0;0;False;0;False;20;25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;372;116.5276,783.1031;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;363;4.783269,1028.18;Inherit;False;Property;_FoamSpeed;FoamSpeed;27;0;Create;True;0;0;False;0;False;0;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;315;2246.455,-760.1541;Inherit;False;223;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;364;-12.2167,1120.181;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;327;2122.755,-1008.564;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;1940.183,-886.0713;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendNormalsNode;266;-711.1857,-262.3068;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;380;42.28323,1213.081;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;377;216.783,944.1802;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;-488.1952,-266.5273;Inherit;False;SurfaceNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;330;2275.478,-932.6833;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;291;2168.154,-438.4634;Inherit;False;1326.49;539.0489;;11;290;333;332;288;285;287;283;289;286;284;336;Underwater Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;365;211.783,1072.181;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;381;88.28336,1358.081;Inherit;False;Property;_FoamNoiseSize;FoamNoiseSize;33;0;Create;True;0;0;False;0;False;10,10;10,40;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;304;2315.884,-1150.184;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;282;-305.9326,-1250.504;Inherit;False;1517.084;563.4999;;16;279;295;299;268;292;294;293;272;271;274;270;278;275;276;273;277;Water Reflection Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;84.57357,-120.2285;Inherit;False;223;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;319;2382.95,-683.914;Inherit;False;Property;_CausticRange;CausticRange;22;0;Create;True;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;317;2442.615,-753.0184;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;367;404.7827,1018.18;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;289;2274.822,-8.083271;Inherit;False;Constant;_Float5;Float 5;16;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;382;299.2827,1262.081;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;2243.42,-211.6056;Inherit;False;259;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;229;84.57308,-12.96853;Inherit;False;Property;_DeepRange;DeepRange;7;0;Create;True;0;0;False;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;286;2218.154,-108.0171;Inherit;False;Property;_UnderwaterDistortion;UnderwaterDistortion;17;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;310;2526.659,-1209.138;Inherit;True;Property;_CausticTex;CausticTex;20;0;Create;True;0;0;False;0;False;-1;None;72417ee6f632e4e4aabc8c81143957bf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;318;2606.949,-724.9139;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;-255.9326,-1009.904;Inherit;False;259;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;329;2495.235,-1009.384;Inherit;True;Property;_TextureSample1;Texture Sample 1;20;0;Create;True;0;0;False;0;False;-1;None;e0d769cd83879f8429f146cdd5ab9364;True;0;False;white;Auto;False;Instance;310;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;228;322.8046,-86.35664;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;276;-269.6701,-899.8585;Inherit;False;Property;_ReflectDistortion;ReflectDistortion;14;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;277;-201.6703,-803.8585;Inherit;False;Constant;_Float3;Float 3;15;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;283;2388.696,-388.4634;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;287;2514.843,-173.572;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;270;-146.9325,-1200.504;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;312;2826.952,-933.8438;Inherit;False;Property;_CausticIntensity;CausticIntensity;21;0;Create;True;0;0;False;0;False;0;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;278;-0.04381847,-845.3618;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;230;511.3589,-42.61769;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;275;7.067389,-1007.904;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;379;484.283,1209.081;Inherit;False;Gradient;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;378;579.783,1028.18;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ExpOpNode;321;2759.949,-718.9141;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;331;2873.85,-1083.625;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;383;765.2005,1075.561;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;294;193.1417,-784.5723;Inherit;False;Property;_ReflectionPower;ReflectionPower;16;0;Create;True;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;311;3037.478,-1118.138;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;274;198.0675,-990.9045;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;271;95.06738,-1192.905;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;394;269.7446,503.4138;Inherit;False;737.8002;299.3579;Foam Mask;4;375;384;386;373;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ExpOpNode;232;675.0722,-49.39162;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;285;2731.043,-307.6145;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;293;182.7417,-862.5723;Inherit;False;Property;_ReflectionIntensity;ReflectionIntensity;15;0;Create;True;0;0;False;0;False;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;323;2918.948,-730.9139;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;347;2085.582,200.6095;Inherit;False;1831.913;435.9406;;18;346;348;345;342;344;341;343;352;340;338;339;337;353;354;356;357;358;359;Shore Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;375;319.7446,716.3715;Inherit;False;Property;_FoamBlend;FoamBlend;29;0;Create;True;0;0;False;0;False;0;0.076;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;384;357.0599,553.4136;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;337;2135.582,250.6095;Inherit;False;223;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;225;689.9207,-256.7065;Inherit;False;Property;_ShallowColor;ShallowColor;6;0;Create;True;0;0;False;0;False;0,0,0,0;0.1215682,0.7490196,0.7333333,0.4588235;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;234;809.4309,-41.48952;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;393;752.5153,868.872;Inherit;False;Property;_FoamWidth;FoamWidth;34;0;Create;True;0;0;False;0;False;0;-0.44;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;292;436.2422,-887.2723;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;324;3187.743,-1029.465;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;388;808.632,1206.956;Inherit;False;Property;_FoamDissolve;FoamDissolve;31;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;391;902.7162,978.4717;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;239;743.1448,130.6802;Inherit;False;Property;_FresnelPower;FresnelPower;9;0;Create;True;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;272;316.9676,-1154.705;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;224;690.45,-437.3892;Inherit;False;Property;_DeepColor;DeepColor;5;0;Create;True;0;0;False;0;False;0,0,0,0;0.09803887,0.3882349,0.7254902,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;288;2926.669,-312.5328;Inherit;False;Global;_GrabScreen0;Grab Screen 0;16;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;313;3306.646,-910.6204;Inherit;False;CausticColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;299;704.8604,-871.397;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;387;1054.85,1129.398;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;338;2272.077,326.8498;Inherit;False;Property;_ShoreRange;ShoreRange;23;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;339;2331.742,257.7454;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;392;1008.515,808.7722;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;336;3170.551,-312.848;Inherit;False;ScreenColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;236;1029.601,-154.0855;Inherit;False;Property;_FresnelColor;FresnelColor;8;0;Create;True;0;0;False;0;False;0,0,0,0;0.01176471,0.3411761,0.9843137,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;238;1026.776,41.87931;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;226;1006.056,-299.6093;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;373;619.0676,605.2686;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;268;474.374,-1179.327;Inherit;True;Property;_ReflectionTex;ReflectionTex;13;0;Create;True;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;854.3809,-1040.119;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;237;1330.464,-209.7495;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;340;2496.076,285.8499;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;193;-392.7289,1706.817;Inherit;False;2542.907;761.6924;Wave Vertex Animation ;21;203;196;189;200;194;192;199;191;198;197;188;202;190;204;207;206;208;209;210;211;212;Wave Vertex Animation ;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;343;2456.683,461.2505;Inherit;False;Property;_ShoreColor;ShoreColor;24;0;Create;True;0;0;False;0;False;0.9150943,0.9150943,0.9150943,0.07058824;0.8773585,0.8773585,0.8773585,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;390;1216.831,1010.091;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;352;2477.27,382.5592;Inherit;False;336;ScreenColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;332;2865.767,-114.8423;Inherit;False;313;CausticColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;386;839.2448,692.7991;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;399;1376.062,945.2963;Inherit;False;Property;_FoamColor;FoamColor;32;0;Create;True;0;0;False;0;False;0.8773585,0.8773585,0.8773585,0.827451;0.8773585,0.8773585,0.8773585,0.3882353;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;333;3150.61,-203.4611;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ExpOpNode;341;2648.066,270.6408;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;189;-272.3056,1788.543;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;190;-314.3051,2086.544;Inherit;False;Property;_WaveASpeedXYSteepnesswavelength;WaveA(SpeedXY,Steepness,wavelength);1;0;Create;True;0;0;False;0;False;1,1,2,50;0,-1,1.6,50;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;241;1578.137,-212.5944;Inherit;False;WaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;279;1009.05,-1045.55;Inherit;False;ReflectionColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;385;1372.382,788.0662;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;344;2722.606,430.1429;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;243;1489.392,6.132292;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;342;2800.015,271.7902;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;354;2949.89,358.8937;Inherit;False;Property;_ShoreEdgeWidth;ShoreEdgeWidth;25;0;Create;True;0;0;False;0;False;0;0.324;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;202;98.92351,2158.968;Inherit;False;Property;_WaveB;WaveB;2;0;Create;True;0;0;False;0;False;1,1,2,50;-0.5,-0.5,1.6,30;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;242;1865.21,858.5567;Inherit;False;279;ReflectionColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;334;1889.947,768.9969;Inherit;False;241;WaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;345;2889.888,460.1686;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;398;1592.061,890.8967;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;290;3285.906,-207.8806;Inherit;False;UnderwaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;188;86.86852,1985.272;Inherit;False;float steepness = wave.z * 0.01@$float wavelength = wave.w@$float k = 2 * UNITY_PI / wavelength@$float c = sqrt(9.8 / k)@$float2 d = normalize(wave.xy)@$float f = k * (dot(d, position.xz) - c * _Time.y)@$float a = steepness / k@$			$$tangent += float3($-d.x * d.x * (steepness * sin(f)),$d.x * (steepness * cos(f)),$-d.x * d.y * (steepness * sin(f))$)@$$binormal += float3($-d.x * d.y * (steepness * sin(f)),$d.y * (steepness * cos(f)),$-d.y * d.y * (steepness * sin(f))$)@$$return float3($d.x * (a * cos(f)),$a * sin(f),$d.y * (a * cos(f))$)@;3;False;4;True;position;FLOAT3;0,0,0;In;;Inherit;False;True;tangent;FLOAT3;1,0,0;InOut;;Inherit;False;True;binormal;FLOAT3;0,0,1;InOut;;Inherit;False;True;wave;FLOAT4;0,0,0,0;In;;Inherit;False;GerstnerWave;True;False;0;4;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT3;0,0,1;False;3;FLOAT4;0,0,0,0;False;3;FLOAT3;0;FLOAT3;2;FLOAT3;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;244;1655.405,4.34347;Inherit;False;WaterTransparency;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;346;3083.066,476.0569;Inherit;False;ShoreColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;353;3256.89,347.8937;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;196;422.8508,1985.36;Inherit;False;float steepness = wave.z * 0.01@$float wavelength = wave.w@$float k = 2 * UNITY_PI / wavelength@$float c = sqrt(9.8 / k)@$float2 d = normalize(wave.xy)@$float f = k * (dot(d, position.xz) - c * _Time.y)@$float a = steepness / k@$			$$tangent += float3($-d.x * d.x * (steepness * sin(f)),$d.x * (steepness * cos(f)),$-d.x * d.y * (steepness * sin(f))$)@$$binormal += float3($-d.x * d.y * (steepness * sin(f)),$d.y * (steepness * cos(f)),$-d.y * d.y * (steepness * sin(f))$)@$$return float3($d.x * (a * cos(f)),$a * sin(f),$d.y * (a * cos(f))$)@;3;False;4;True;position;FLOAT3;0,0,0;In;;Inherit;False;True;tangent;FLOAT3;1,0,0;InOut;;Inherit;False;True;binormal;FLOAT3;0,0,1;InOut;;Inherit;False;True;wave;FLOAT4;0,0,0,0;In;;Inherit;False;GerstnerWave;True;False;0;4;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT3;0,0,1;False;3;FLOAT4;0,0,0,0;False;3;FLOAT3;0;FLOAT3;2;FLOAT3;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;396;1549.906,727.0047;Inherit;False;Foam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;348;2973.766,261.8027;Inherit;False;ShoreArea;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;335;2120.349,819.8972;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;298;1942.198,957.5399;Inherit;False;290;UnderwaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;297;1933.867,1043.775;Inherit;False;244;WaterTransparency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;204;517.7306,2175.757;Inherit;False;Property;_WaveC;WaveC;3;0;Create;True;0;0;False;0;False;1,1,2,50;1,0.5,1,20;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;350;2240.993,1062.292;Inherit;False;346;ShoreColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;351;2280.159,1175.738;Inherit;False;348;ShoreArea;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;358;3333.89,440.8937;Inherit;False;Property;_ShoreEdgeIntensity;ShoreEdgeIntensity;26;0;Create;True;0;0;False;0;False;0;0.333;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;296;2288.222,916.2191;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;203;763.183,1960.55;Inherit;False;float steepness = wave.z * 0.01@$float wavelength = wave.w@$float k = 2 * UNITY_PI / wavelength@$float c = sqrt(9.8 / k)@$float2 d = normalize(wave.xy)@$float f = k * (dot(d, position.xz) - c * _Time.y)@$float a = steepness / k@$			$$tangent += float3($-d.x * d.x * (steepness * sin(f)),$d.x * (steepness * cos(f)),$-d.x * d.y * (steepness * sin(f))$)@$$binormal += float3($-d.x * d.y * (steepness * sin(f)),$d.y * (steepness * cos(f)),$-d.y * d.y * (steepness * sin(f))$)@$$return float3($d.x * (a * cos(f)),$a * sin(f),$d.y * (a * cos(f))$)@;3;False;4;True;position;FLOAT3;0,0,0;In;;Inherit;False;True;tangent;FLOAT3;1,0,0;InOut;;Inherit;False;True;binormal;FLOAT3;0,0,1;InOut;;Inherit;False;True;wave;FLOAT4;0,0,0,0;In;;Inherit;False;GerstnerWave;True;False;0;4;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT3;0,0,1;False;3;FLOAT4;0,0,0,0;False;3;FLOAT3;0;FLOAT3;2;FLOAT3;3
Node;AmplifyShaderEditor.SmoothstepOpNode;356;3436.89,285.8937;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;401;2479.786,1167.233;Inherit;False;396;Foam;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;357;3672.89,342.8937;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;404;2656.589,1137.332;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;349;2484.091,1000.168;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CrossProductOpNode;197;1098.393,2233.15;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;359;3700.89,482.8937;Inherit;False;ShoreEdge;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;403;2813.89,1089.231;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;198;1297.393,2267.15;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;402;2702.089,1211.433;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;191;1018.069,1777.777;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;192;1250.747,1778.07;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;361;3030.694,1181.437;Inherit;False;359;ShoreEdge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;199;1497.393,2245.15;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;400;2984.194,1043.731;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;1747.393,2262.15;Inherit;False;WaveVertexNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;1554.227,1788.148;Inherit;False;WaveVertexPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;360;3256.294,1068.536;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;222;-838.679,333.4135;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;326;3202.286,1532.703;Inherit;False;396;Foam;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;2107.47,1263.08;Inherit;False;212;WaveColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;195;3110.76,1304.383;Inherit;False;194;WaveVertexPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;211;1477.925,2081.401;Inherit;False;Property;_WaveColor;WaveColor;4;0;Create;True;0;0;False;0;False;0,0,0,0;0.3098039,0.5333333,0.7921569,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;209;1616.155,1938.732;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;3066.053,1414.569;Inherit;False;200;WaveVertexNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;405;3419.69,1086.631;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;206;1265.863,1989.286;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;1944.877,2102.879;Inherit;False;WaveColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;207;1068.711,2040.605;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;210;1785.287,2005.242;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;208;1437.863,1997.286;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3607.195,1032.372;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Toon_Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;217;0;215;0
WireConnection;218;0;217;0
WireConnection;247;0;246;0
WireConnection;219;0;218;0
WireConnection;280;0;247;0
WireConnection;280;1;281;0
WireConnection;220;0;216;2
WireConnection;220;1;219;0
WireConnection;249;0;280;0
WireConnection;249;1;250;0
WireConnection;254;0;253;0
WireConnection;254;1;256;0
WireConnection;254;2;257;0
WireConnection;223;0;220;0
WireConnection;261;0;249;0
WireConnection;261;1;263;0
WireConnection;262;0;254;0
WireConnection;262;1;264;0
WireConnection;369;0;368;0
WireConnection;369;1;374;0
WireConnection;251;0;249;0
WireConnection;251;1;254;0
WireConnection;301;0;300;0
WireConnection;265;0;261;0
WireConnection;265;1;262;0
WireConnection;258;1;251;0
WireConnection;260;1;265;0
WireConnection;371;0;369;0
WireConnection;302;0;301;0
WireConnection;302;1;303;0
WireConnection;372;0;371;0
WireConnection;327;0;302;0
WireConnection;307;0;309;0
WireConnection;307;1;308;0
WireConnection;307;2;306;0
WireConnection;266;0;258;0
WireConnection;266;1;260;0
WireConnection;377;0;372;0
WireConnection;377;1;376;0
WireConnection;259;0;266;0
WireConnection;330;0;327;0
WireConnection;330;1;307;0
WireConnection;365;0;363;0
WireConnection;365;1;364;0
WireConnection;304;0;302;0
WireConnection;304;1;307;0
WireConnection;317;0;315;0
WireConnection;367;0;377;0
WireConnection;367;1;365;0
WireConnection;382;0;380;0
WireConnection;382;1;381;0
WireConnection;310;1;304;0
WireConnection;318;0;317;0
WireConnection;318;1;319;0
WireConnection;329;1;330;0
WireConnection;228;0;227;0
WireConnection;287;0;284;0
WireConnection;287;1;286;0
WireConnection;287;2;289;0
WireConnection;278;0;276;0
WireConnection;278;1;277;0
WireConnection;230;0;228;0
WireConnection;230;1;229;0
WireConnection;275;0;273;0
WireConnection;379;0;382;0
WireConnection;378;0;367;0
WireConnection;321;0;318;0
WireConnection;331;0;310;0
WireConnection;331;1;329;0
WireConnection;383;0;378;0
WireConnection;383;1;379;0
WireConnection;311;0;331;0
WireConnection;311;1;312;0
WireConnection;274;0;275;0
WireConnection;274;1;278;0
WireConnection;271;0;270;0
WireConnection;232;0;230;0
WireConnection;285;0;283;0
WireConnection;285;1;287;0
WireConnection;323;0;321;0
WireConnection;384;0;371;0
WireConnection;234;0;232;0
WireConnection;292;2;293;0
WireConnection;292;3;294;0
WireConnection;324;0;311;0
WireConnection;324;1;323;0
WireConnection;391;0;372;0
WireConnection;391;1;383;0
WireConnection;272;0;271;0
WireConnection;272;1;274;0
WireConnection;288;0;285;0
WireConnection;313;0;324;0
WireConnection;299;0;292;0
WireConnection;387;0;391;0
WireConnection;387;1;388;0
WireConnection;339;0;337;0
WireConnection;392;0;372;0
WireConnection;392;1;393;0
WireConnection;336;0;288;0
WireConnection;238;3;239;0
WireConnection;226;0;224;0
WireConnection;226;1;225;0
WireConnection;226;2;234;0
WireConnection;373;0;384;0
WireConnection;373;1;375;0
WireConnection;268;1;272;0
WireConnection;295;0;268;0
WireConnection;295;1;299;0
WireConnection;237;0;226;0
WireConnection;237;1;236;0
WireConnection;237;2;238;0
WireConnection;340;0;339;0
WireConnection;340;1;338;0
WireConnection;390;0;392;0
WireConnection;390;1;387;0
WireConnection;386;0;373;0
WireConnection;333;0;288;0
WireConnection;333;1;332;0
WireConnection;341;0;340;0
WireConnection;241;0;237;0
WireConnection;279;0;295;0
WireConnection;385;0;386;0
WireConnection;385;1;390;0
WireConnection;344;0;352;0
WireConnection;344;1;343;0
WireConnection;243;0;237;0
WireConnection;342;0;341;0
WireConnection;345;0;344;0
WireConnection;398;0;385;0
WireConnection;398;1;399;0
WireConnection;290;0;333;0
WireConnection;188;0;189;0
WireConnection;188;3;190;0
WireConnection;244;0;243;0
WireConnection;346;0;345;0
WireConnection;353;0;354;0
WireConnection;196;0;189;0
WireConnection;196;1;188;2
WireConnection;196;2;188;3
WireConnection;196;3;202;0
WireConnection;396;0;398;0
WireConnection;348;0;342;0
WireConnection;335;0;334;0
WireConnection;335;1;242;0
WireConnection;296;0;335;0
WireConnection;296;1;298;0
WireConnection;296;2;297;0
WireConnection;203;0;189;0
WireConnection;203;1;196;2
WireConnection;203;2;196;3
WireConnection;203;3;204;0
WireConnection;356;0;348;0
WireConnection;356;1;353;0
WireConnection;357;0;356;0
WireConnection;357;1;358;0
WireConnection;404;0;401;0
WireConnection;349;0;296;0
WireConnection;349;1;350;0
WireConnection;349;2;351;0
WireConnection;197;0;203;3
WireConnection;197;1;203;2
WireConnection;359;0;357;0
WireConnection;403;0;349;0
WireConnection;403;1;404;0
WireConnection;198;0;197;0
WireConnection;402;0;401;0
WireConnection;191;0;189;0
WireConnection;191;1;188;0
WireConnection;191;2;196;0
WireConnection;191;3;203;0
WireConnection;192;0;191;0
WireConnection;199;0;198;0
WireConnection;400;0;349;0
WireConnection;400;1;403;0
WireConnection;400;2;402;0
WireConnection;200;0;199;0
WireConnection;194;0;192;0
WireConnection;360;0;400;0
WireConnection;360;1;361;0
WireConnection;222;0;220;0
WireConnection;209;0;208;0
WireConnection;405;0;360;0
WireConnection;206;0;191;0
WireConnection;206;1;207;0
WireConnection;212;0;210;0
WireConnection;210;0;209;0
WireConnection;210;1;211;0
WireConnection;208;0;206;0
WireConnection;0;2;405;0
WireConnection;0;11;195;0
WireConnection;0;12;201;0
ASEEND*/
//CHKSM=06B3DCE30C70911F831647E107BA4033B8906665