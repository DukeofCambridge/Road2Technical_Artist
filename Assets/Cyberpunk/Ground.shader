// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Ground"
{
	Properties
	{
		_BaseColor("BaseColor", 2D) = "white" {}
		_Roughness("Roughness", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_AO("AO", 2D) = "white" {}
		_Tiling("Tiling", Float) = 1
		_RoughnessMax("RoughnessMax", Range( 0 , 1)) = 0
		_RoughnessMin("RoughnessMin", Range( 0 , 1)) = 0
		_NormalIntensity("NormalIntensity", Float) = 0
		_Height("Height", 2D) = "white" {}
		_POMscale("POMscale", Range( -0.5 , 0.5)) = 0
		_POMplane("POMplane", Float) = 0
		_BlendContrast("BlendContrast", Range( 0 , 1)) = 0
		_PuddleDepth("PuddleDepth", Range( 0 , 1)) = 0
		_PuddleColor("PuddleColor", Color) = (0,0,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _Normal;
		uniform float _Tiling;
		uniform sampler2D _Height;
		uniform float _POMscale;
		uniform float _POMplane;
		uniform float4 _Height_ST;
		uniform float _NormalIntensity;
		uniform sampler2D _BaseColor;
		uniform float4 _PuddleColor;
		uniform float _PuddleDepth;
		uniform float _BlendContrast;
		uniform float _RoughnessMin;
		uniform float _RoughnessMax;
		uniform sampler2D _Roughness;
		SamplerState sampler_Roughness;
		uniform sampler2D _AO;
		SamplerState sampler_AO;


		inline float2 POM( sampler2D heightMap, float2 uvs, float2 dx, float2 dy, float3 normalWorld, float3 viewWorld, float3 viewDirTan, int minSamples, int maxSamples, float parallax, float refPlane, float2 tilling, float2 curv, int index )
		{
			float3 result = 0;
			int stepIndex = 0;
			int numSteps = ( int )lerp( (float)maxSamples, (float)minSamples, saturate( dot( normalWorld, viewWorld ) ) );
			float layerHeight = 1.0 / numSteps;
			float2 plane = parallax * ( viewDirTan.xy / viewDirTan.z );
			uvs.xy += refPlane * plane;
			float2 deltaTex = -plane * layerHeight;
			float2 prevTexOffset = 0;
			float prevRayZ = 1.0f;
			float prevHeight = 0.0f;
			float2 currTexOffset = deltaTex;
			float currRayZ = 1.0f - layerHeight;
			float currHeight = 0.0f;
			float intersection = 0;
			float2 finalTexOffset = 0;
			while ( stepIndex < numSteps + 1 )
			{
			 	currHeight = tex2Dgrad( heightMap, uvs + currTexOffset, dx, dy ).r;
			 	if ( currHeight > currRayZ )
			 	{
			 	 	stepIndex = numSteps + 1;
			 	}
			 	else
			 	{
			 	 	stepIndex++;
			 	 	prevTexOffset = currTexOffset;
			 	 	prevRayZ = currRayZ;
			 	 	prevHeight = currHeight;
			 	 	currTexOffset += deltaTex;
			 	 	currRayZ -= layerHeight;
			 	}
			}
			int sectionSteps = 6;
			int sectionIndex = 0;
			float newZ = 0;
			float newHeight = 0;
			while ( sectionIndex < sectionSteps )
			{
			 	intersection = ( prevHeight - prevRayZ ) / ( prevHeight - currHeight + currRayZ - prevRayZ );
			 	finalTexOffset = prevTexOffset + intersection * deltaTex;
			 	newZ = prevRayZ - intersection * layerHeight;
			 	newHeight = tex2Dgrad( heightMap, uvs + finalTexOffset, dx, dy ).r;
			 	if ( newHeight > newZ )
			 	{
			 	 	currTexOffset = finalTexOffset;
			 	 	currHeight = newHeight;
			 	 	currRayZ = newZ;
			 	 	deltaTex = intersection * deltaTex;
			 	 	layerHeight = intersection * layerHeight;
			 	}
			 	else
			 	{
			 	 	prevTexOffset = finalTexOffset;
			 	 	prevHeight = newHeight;
			 	 	prevRayZ = newZ;
			 	 	deltaTex = ( 1 - intersection ) * deltaTex;
			 	 	layerHeight = ( 1 - intersection ) * layerHeight;
			 	}
			 	sectionIndex++;
			}
			return uvs.xy + finalTexOffset;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 ase_tanViewDir = mul( ase_worldToTangent, ase_worldViewDir );
			float2 OffsetPOM19 = POM( _Height, ( (ase_worldPos).xz * _Tiling ), ddx(( (ase_worldPos).xz * _Tiling )), ddy(( (ase_worldPos).xz * _Tiling )), ase_worldNormal, ase_worldViewDir, ase_tanViewDir, 8, 8, ( _POMscale * 0.1 ), _POMplane, _Height_ST.xy, float2(0,0), 0 );
			float2 WorldUV33 = OffsetPOM19;
			o.Normal = UnpackScaleNormal( tex2D( _Normal, WorldUV33 ), _NormalIntensity );
			float4 tex2DNode1 = tex2D( _BaseColor, WorldUV33 );
			float4 lerpResult42 = lerp( tex2DNode1 , _PuddleColor , _PuddleDepth);
			float temp_output_10_0_g1 = _BlendContrast;
			float4 tex2DNode32 = tex2D( _Height, WorldUV33 );
			float clampResult8_g1 = clamp( ( ( tex2DNode32.r - 1.0 ) + ( i.vertexColor.r * 2.0 ) ) , 0.0 , 1.0 );
			float lerpResult12_g1 = lerp( ( 0.0 - temp_output_10_0_g1 ) , ( temp_output_10_0_g1 + 1.0 ) , clampResult8_g1);
			float clampResult13_g1 = clamp( lerpResult12_g1 , 0.0 , 1.0 );
			float RchannelLerp36 = clampResult13_g1;
			float4 lerpResult44 = lerp( tex2DNode1 , lerpResult42 , ( 1.0 - RchannelLerp36 ));
			o.Albedo = lerpResult44.rgb;
			o.Metallic = 0.0;
			float lerpResult14 = lerp( _RoughnessMin , _RoughnessMax , tex2D( _Roughness, WorldUV33 ).r);
			o.Smoothness = ( 1.0 - lerpResult14 );
			o.Occlusion = tex2D( _AO, WorldUV33 ).r;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				half4 color : COLOR0;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
6.666667;158.6667;1693.333;839;1572.131;744.6727;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;26;-2330.495,-146.7218;Inherit;False;1180.061;781.6746;;12;7;8;11;22;12;20;19;21;23;24;25;33;World Space UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;7;-2155.008,-26.32174;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;8;-1914.011,-11.32171;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1938.711,105.8782;Inherit;False;Property;_Tiling;Tiling;4;0;Create;True;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1970.913,433.0559;Inherit;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2053.897,336.6484;Inherit;False;Property;_POMscale;POMscale;9;0;Create;True;0;0;False;0;False;0;-0.1;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1524.958,495.7535;Inherit;False;Property;_POMplane;POMplane;10;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;20;-2322.797,192.4287;Inherit;True;Property;_Height;Height;8;0;Create;True;0;0;False;0;False;None;a5ecce54dc98f2a46825515baaee9657;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1740.011,25.67828;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1681.074,262.2089;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;24;-1732.356,407.9713;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;19;-1436.436,142.8951;Inherit;False;0;8;False;-1;16;False;-1;6;0.02;0;False;1,1;False;0,0;7;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1367.112,353.5935;Inherit;False;WorldUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;39;-2330.917,711.6984;Inherit;False;1296.049;684.8956;;10;37;36;31;28;35;29;32;34;38;30;BlendFactor;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-2280.917,803.1938;Inherit;False;33;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;32;-2044.494,783.6985;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-2053.715,1281.593;Inherit;False;Property;_BlendContrast;BlendContrast;11;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;29;-1993.151,1057.835;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;28;-1614.648,875.5358;Inherit;False;HeightLerp;-1;;1;be07880a9dac45a45b9ecf14da13baa8;0;3;1;FLOAT;0;False;5;FLOAT;0;False;10;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-1262.869,860.91;Inherit;False;RchannelLerp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-1140.856,-825.8972;Inherit;False;33;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-1011.006,270.4216;Inherit;False;33;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-784.2865,-463.4057;Inherit;False;Property;_PuddleDepth;PuddleDepth;12;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-480.3958,210.9836;Inherit;False;Property;_RoughnessMax;RoughnessMax;5;0;Create;True;0;0;False;0;False;0;0.44;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-482.996,136.8836;Inherit;False;Property;_RoughnessMin;RoughnessMin;6;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-817.3307,-869.2374;Inherit;True;Property;_BaseColor;BaseColor;0;0;Create;True;0;0;False;0;False;-1;None;d3ac26717da02064ca31d4d267016259;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-779.6669,257.1667;Inherit;True;Property;_Roughness;Roughness;1;0;Create;True;0;0;False;0;False;-1;None;cc202f26da5640b4f9076c629b5dbe69;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;45;-455.139,-419.1087;Inherit;False;36;RchannelLerp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;41;-748.1599,-664.6064;Inherit;False;Property;_PuddleColor;PuddleColor;13;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;46;-252.1968,-484.94;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;42;-363.8776,-658.8452;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-1040.592,498.8903;Inherit;False;33;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1024.24,112.6248;Inherit;False;Property;_NormalIntensity;NormalIntensity;7;0;Create;True;0;0;False;0;False;0;0.64;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;14;-147.9966,171.9836;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-1043.88,27.15988;Inherit;False;33;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;31;-1617.49,1174.3;Inherit;False;HeightLerp;-1;;3;be07880a9dac45a45b9ecf14da13baa8;0;3;1;FLOAT;0;False;5;FLOAT;0;False;10;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;44;-55.62338,-838.162;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;6;35.03247,132.2665;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-775.6669,480.1667;Inherit;True;Property;_AO;AO;3;0;Create;True;0;0;False;0;False;-1;None;080d70a81de86ef48af663a880659966;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-1262.87,1195.008;Inherit;False;BchannelLerp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;30;-1613.59,1023.502;Inherit;False;HeightLerp;-1;;2;be07880a9dac45a45b9ecf14da13baa8;0;3;1;FLOAT;0;False;5;FLOAT;0;False;10;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-1268.07,1028.609;Inherit;False;GchannelLerp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-771.6669,29.16665;Inherit;True;Property;_Normal;Normal;2;0;Create;True;0;0;False;0;False;-1;None;600720e291a8e7f4c835508c250f599f;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;523.2011,-38.61644;Inherit;False;Constant;_Metallic;Metallic;9;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;283.1999,10.4;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Ground;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;40;-2094.494,733.6985;Inherit;False;370.6667;280;Comment;0;;1,1,1,1;0;0
WireConnection;8;0;7;0
WireConnection;12;0;8;0
WireConnection;12;1;11;0
WireConnection;22;0;21;0
WireConnection;22;1;23;0
WireConnection;19;0;12;0
WireConnection;19;1;20;0
WireConnection;19;2;22;0
WireConnection;19;3;24;0
WireConnection;19;4;25;0
WireConnection;33;0;19;0
WireConnection;32;0;20;0
WireConnection;32;1;34;0
WireConnection;28;1;32;1
WireConnection;28;5;29;1
WireConnection;28;10;35;0
WireConnection;36;0;28;0
WireConnection;1;1;47;0
WireConnection;2;1;49;0
WireConnection;46;0;45;0
WireConnection;42;0;1;0
WireConnection;42;1;41;0
WireConnection;42;2;43;0
WireConnection;14;0;15;0
WireConnection;14;1;16;0
WireConnection;14;2;2;1
WireConnection;31;1;32;1
WireConnection;31;5;29;3
WireConnection;31;10;35;0
WireConnection;44;0;1;0
WireConnection;44;1;42;0
WireConnection;44;2;46;0
WireConnection;6;0;14;0
WireConnection;4;1;50;0
WireConnection;38;0;31;0
WireConnection;30;1;32;1
WireConnection;30;5;29;2
WireConnection;30;10;35;0
WireConnection;37;0;30;0
WireConnection;3;1;48;0
WireConnection;3;5;17;0
WireConnection;0;0;44;0
WireConnection;0;1;3;0
WireConnection;0;3;18;0
WireConnection;0;4;6;0
WireConnection;0;5;4;1
ASEEND*/
//CHKSM=10F0C5645538103EAAB2380FE48965BB52D89B27