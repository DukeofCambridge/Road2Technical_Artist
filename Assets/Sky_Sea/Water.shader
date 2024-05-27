// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water"
{
	Properties
	{
		_ReflectionTex("ReflectionTex", 2D) = "white" {}
		_WaterNormal("WaterNormal", 2D) = "bump" {}
		_WaterNormalTiling("WaterNormalTiling", Float) = 1
		_FlowSpeed("FlowSpeed", Float) = 1
		_NoiseAmplitude("NoiseAmplitude", Float) = 1
		_SpecularGloss("SpecularGloss", Range( 0.01 , 1)) = 0
		_LightColor("LightColor", Color) = (0,0,0,0)
		_SpecularIntensity("SpecularIntensity", Float) = 0
		_SpecularEnd("SpecularEnd", Float) = 0
		_SpecularStart("SpecularStart", Float) = 0
		_UnderWater("UnderWater", 2D) = "white" {}
		_UnderWaterTiling("UnderWaterTiling", Float) = 0
		_WaterDepth("WaterDepth", Float) = 0
		_FresnelItem("FresnelItem", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
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
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float3 viewDir;
			float4 screenPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _SpecularIntensity;
		uniform sampler2D _WaterNormal;
		uniform float _WaterNormalTiling;
		uniform float _FlowSpeed;
		uniform float _SpecularGloss;
		uniform float4 _LightColor;
		uniform float _SpecularEnd;
		uniform float _SpecularStart;
		uniform sampler2D _UnderWater;
		uniform float _UnderWaterTiling;
		uniform float _WaterDepth;
		uniform sampler2D _ReflectionTex;
		uniform float _NoiseAmplitude;
		uniform float _FresnelItem;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float2 temp_output_14_0 = ( (ase_worldPos).xz * _WaterNormalTiling );
			float temp_output_12_0 = ( _Time.y * _FlowSpeed * 0.1 );
			float2 temp_output_25_0 = ( (( UnpackNormal( tex2D( _WaterNormal, ( temp_output_14_0 + temp_output_12_0 ) ) ) + UnpackNormal( tex2D( _WaterNormal, ( ( temp_output_14_0 * 1.5 ) + ( temp_output_12_0 * -1.0 ) ) ) ) )).xy * 0.5 );
			float dotResult28 = dot( temp_output_25_0 , temp_output_25_0 );
			float3 appendResult31 = (float3(temp_output_25_0 , sqrt( ( 1.0 - dotResult28 ) )));
			float3 WaterNormal33 = (WorldNormalVector( i , appendResult31 ));
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult50 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult52 = dot( WaterNormal33 , normalizeResult50 );
			float clampResult82 = clamp( ( ( _SpecularEnd - distance( ase_worldPos , _WorldSpaceCameraPos ) ) / ( _SpecularEnd - _SpecularStart ) ) , 0.0 , 1.0 );
			float4 SpecularItem65 = ( _SpecularIntensity * pow( max( dotResult52 , 0.0 ) , ( _SpecularGloss * 256.0 ) ) * _LightColor * clampResult82 );
			float2 paralaxOffset105 = ParallaxOffset( 0 , _WaterDepth , i.viewDir );
			float4 UnderWaterColor90 = tex2D( _UnderWater, ( ( (ase_worldPos).xz * _UnderWaterTiling ) + ( (WaterNormal33).xy * 0.1 ) + paralaxOffset105 ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos42 = UnityObjectToClipPos( ase_vertex3Pos );
			float4 ReflectionItem68 = tex2D( _ReflectionTex, ( (ase_screenPosNorm).xy + ( ( (WaterNormal33).xz / ( unityObjectToClipPos42.w + 1.0 ) ) * _NoiseAmplitude ) ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float dotResult95 = dot( ase_worldNormal , ase_worldViewDir );
			float clampResult96 = clamp( pow( dotResult95 , _FresnelItem ) , 0.0 , 1.0 );
			float4 lerpResult98 = lerp( UnderWaterColor90 , ReflectionItem68 , ( 1.0 - clampResult96 ));
			c.rgb = ( SpecularItem65 + lerpResult98 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

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
				float4 screenPos : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
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
6.666667;140.6667;1693.333;857;2588.014;-661.496;1.69608;True;False
Node;AmplifyShaderEditor.CommentaryNode;34;-2487.948,-848.6471;Inherit;False;3132.631;712.3004;;26;4;16;24;25;26;28;29;30;31;21;13;5;7;14;6;10;12;11;15;19;18;17;20;22;32;33;WaterNormal;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;5;-2400.248,-798.6471;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;15;-2410.646,-304.6471;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-2437.948,-393.0477;Inherit;False;Property;_FlowSpeed;FlowSpeed;3;0;Create;True;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;10;-2436.648,-484.0475;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;6;-2197.45,-741.4473;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-2402.847,-620.5471;Inherit;False;Property;_WaterNormalTiling;WaterNormalTiling;2;0;Create;True;0;0;False;0;False;1;0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1981.647,-438.5476;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2034.948,-694.6467;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2213.048,-251.3472;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-2207.849,-448.9475;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1817.848,-458.0477;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-2050.549,-363.1477;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-1660.55,-676.447;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-1654.048,-439.8477;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;4;-1418.749,-699.9468;Inherit;True;Property;_WaterNormal;WaterNormal;1;0;Create;True;0;0;False;0;False;-1;dafc0b1dcf338454b891a90762794d8a;dafc0b1dcf338454b891a90762794d8a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-1430.448,-467.2473;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;4;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-1046.947,-588.147;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;22;-907.7463,-592.0471;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-915.6465,-491.9474;Inherit;False;Constant;_Float3;Float 3;4;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-729.7469,-572.5471;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;28;-524.3477,-499.6472;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;29;-361.8475,-500.9473;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;30;-169.4477,-500.9472;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-21.2476,-569.847;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;69;-2658.78,-33.39083;Inherit;False;1937.06;660.3505;;14;41;44;35;42;43;38;2;40;45;39;3;23;1;68;Planar Reflection Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;32;162.7672,-570.0974;Inherit;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;41;-2608.78,333.86;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;434.6836,-574.7726;Inherit;False;WaterNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;66;-2348.945,783.0468;Inherit;False;1923.93;507.3649;;15;48;49;50;52;54;58;60;62;61;47;56;57;59;63;65;Specular Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;109;-899.634,1419.781;Inherit;False;1475.155;946.0731;;9;108;107;84;86;89;88;103;85;90;Underwater Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;47;-2257.403,883.1838;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;48;-2298.945,1072.273;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;35;-2319.815,212.0637;Inherit;False;33;WaterNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-2249.982,511.96;Inherit;False;Constant;_Float4;Float 4;5;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;83;-2288.568,1299.095;Inherit;False;1234.71;473.2833;make the specular item decrease with the distance from camera;9;79;73;74;75;78;76;77;80;82;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;107;-849.634,1733.569;Inherit;False;597.3333;269.0001;influence of water to the underwater color.  Used to simulate the complex underwater lighting;4;99;100;101;102;;1,1,1,1;0;0
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;42;-2337.081,333.8603;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceCameraPos;74;-2238.568,1546.892;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;38;-2075.676,210.9386;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;84;-723.9262,1474.761;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;108;-797.2047,2047.853;Inherit;False;592.9999;318.001;水深导致的UV视差偏移;3;105;104;106;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;73;-2204.465,1349.095;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;99;-799.634,1790.569;Inherit;False;33;WaterNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-2054.982,426.1601;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-2003.85,967.7005;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-560.4952,1639.517;Inherit;False;Property;_UnderWaterTiling;UnderWaterTiling;11;0;Create;True;0;0;False;0;False;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-594.634,1887.57;Inherit;False;Constant;_Float6;Float 6;12;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-695.2047,2097.853;Inherit;False;Property;_WaterDepth;WaterDepth;12;0;Create;True;0;0;False;0;False;0;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;50;-1850.574,967.7004;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;104;-747.2047,2181.854;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;54;-1879.224,833.0468;Inherit;False;33;WaterNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;86;-505.0663,1469.781;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-1848.192,1657.378;Inherit;False;Property;_SpecularStart;SpecularStart;9;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;100;-588.634,1783.569;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1887.671,359.9174;Inherit;False;Property;_NoiseAmplitude;NoiseAmplitude;4;0;Create;True;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-1823.192,1385.378;Inherit;False;Property;_SpecularEnd;SpecularEnd;8;0;Create;True;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;45;-1885.986,258.4602;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;2;-1991.826,16.93074;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;75;-1961.192,1454.378;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;93;-480.0339,285.2699;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;77;-1596.192,1631.378;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-1710.192,1175.412;Inherit;False;Constant;_Float5;Float 5;6;0;Create;True;0;0;False;0;False;256;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-326.8262,1551.102;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;3;-1724.55,16.60915;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ParallaxOffsetHlpNode;105;-458.2048,2139.854;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-415.634,1819.57;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1666.093,258.3664;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;94;-465.0339,444.2699;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;76;-1591.192,1418.378;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-1831.953,1083.732;Inherit;False;Property;_SpecularGloss;SpecularGloss;5;0;Create;True;0;0;False;0;False;0;0.01;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;52;-1665.783,878.8862;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;103;-170.0339,1676.27;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-321.9512,610.6241;Inherit;False;Property;_FresnelItem;FresnelItem;13;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;95;-258.0339,360.2699;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;56;-1506.776,878.8862;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;80;-1399.193,1504.378;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1519.67,1092.327;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-1470.25,106.5069;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-1165.671,839.575;Inherit;False;Property;_SpecularIntensity;SpecularIntensity;7;0;Create;True;0;0;False;0;False;0;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;82;-1225.192,1504.378;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;57;-1346.339,880.3187;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;85;9.365707,1649.151;Inherit;True;Property;_UnderWater;UnderWater;10;0;Create;True;0;0;False;0;False;-1;None;3c004106d6cf9704780ede542d271ab5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-1346.65,35.00712;Inherit;True;Property;_ReflectionTex;ReflectionTex;0;0;Create;True;0;0;False;0;False;-1;0d79852d3391d574781a61a66e8430ac;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;62;-1341.512,1008.283;Inherit;False;Property;_LightColor;LightColor;6;0;Create;True;0;0;False;0;False;0,0,0,0;1,0.4822641,0.3836477,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;112;-86.70044,474.1506;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;334.1875,1649.788;Inherit;False;UnderWaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-949.7203,34.60329;Inherit;False;ReflectionItem;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-959.4441,938.2556;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;96;116.9661,378.2699;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;97;263.9661,378.2699;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;123.9661,187.2698;Inherit;False;90;UnderWaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;136.851,291.3615;Inherit;False;68;ReflectionItem;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-717.925,937.4314;Inherit;False;SpecularItem;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;433.851,170.1908;Inherit;False;65;SpecularItem;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;98;486.9661,273.2698;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;688.793,174.9922;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;963,-11;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;5;0
WireConnection;14;0;6;0
WireConnection;14;1;7;0
WireConnection;12;0;10;0
WireConnection;12;1;11;0
WireConnection;12;2;15;0
WireConnection;17;0;14;0
WireConnection;17;1;20;0
WireConnection;19;0;12;0
WireConnection;19;1;18;0
WireConnection;13;0;14;0
WireConnection;13;1;12;0
WireConnection;21;0;17;0
WireConnection;21;1;19;0
WireConnection;4;1;13;0
WireConnection;16;1;21;0
WireConnection;24;0;4;0
WireConnection;24;1;16;0
WireConnection;22;0;24;0
WireConnection;25;0;22;0
WireConnection;25;1;26;0
WireConnection;28;0;25;0
WireConnection;28;1;25;0
WireConnection;29;0;28;0
WireConnection;30;0;29;0
WireConnection;31;0;25;0
WireConnection;31;2;30;0
WireConnection;32;0;31;0
WireConnection;33;0;32;0
WireConnection;42;0;41;0
WireConnection;38;0;35;0
WireConnection;43;0;42;4
WireConnection;43;1;44;0
WireConnection;49;0;47;0
WireConnection;49;1;48;0
WireConnection;50;0;49;0
WireConnection;86;0;84;0
WireConnection;100;0;99;0
WireConnection;45;0;38;0
WireConnection;45;1;43;0
WireConnection;75;0;73;0
WireConnection;75;1;74;0
WireConnection;77;0;78;0
WireConnection;77;1;79;0
WireConnection;88;0;86;0
WireConnection;88;1;89;0
WireConnection;3;0;2;0
WireConnection;105;1;106;0
WireConnection;105;2;104;0
WireConnection;102;0;100;0
WireConnection;102;1;101;0
WireConnection;39;0;45;0
WireConnection;39;1;40;0
WireConnection;76;0;78;0
WireConnection;76;1;75;0
WireConnection;52;0;54;0
WireConnection;52;1;50;0
WireConnection;103;0;88;0
WireConnection;103;1;102;0
WireConnection;103;2;105;0
WireConnection;95;0;93;0
WireConnection;95;1;94;0
WireConnection;56;0;52;0
WireConnection;80;0;76;0
WireConnection;80;1;77;0
WireConnection;59;0;58;0
WireConnection;59;1;60;0
WireConnection;23;0;3;0
WireConnection;23;1;39;0
WireConnection;82;0;80;0
WireConnection;57;0;56;0
WireConnection;57;1;59;0
WireConnection;85;1;103;0
WireConnection;1;1;23;0
WireConnection;112;0;95;0
WireConnection;112;1;110;0
WireConnection;90;0;85;0
WireConnection;68;0;1;0
WireConnection;61;0;63;0
WireConnection;61;1;57;0
WireConnection;61;2;62;0
WireConnection;61;3;82;0
WireConnection;96;0;112;0
WireConnection;97;0;96;0
WireConnection;65;0;61;0
WireConnection;98;0;92;0
WireConnection;98;1;70;0
WireConnection;98;2;97;0
WireConnection;72;0;71;0
WireConnection;72;1;98;0
WireConnection;0;13;72;0
ASEEND*/
//CHKSM=FF4E55DF4B44B7DD226753B37793FA16354D0FC1