// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Beach"
{
	Properties
	{
		_Sand_Water("Sand_Water", 2D) = "white" {}
		_Sand_Land("Sand_Land", 2D) = "white" {}
		_Tilling("Tilling", Float) = 1
		_ShadowColor("ShadowColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
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

		uniform sampler2D _Sand_Water;
		uniform float _Tilling;
		uniform sampler2D _Sand_Land;
		uniform float4 _ShadowColor;


		float3 ACESTonemap12( float3 linear_color )
		{
			float3 tonemapped_color = saturate((linear_color*(2.8 * linear_color + 0))/(linear_color*(2.0 * linear_color + 1.0) + 0.0));
			return tonemapped_color;
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 temp_output_7_0 = ( i.uv_texcoord * _Tilling );
			float4 tex2DNode1 = tex2D( _Sand_Water, temp_output_7_0 );
			float4 tex2DNode2 = tex2D( _Sand_Land, temp_output_7_0 );
			float4 lerpResult9 = lerp( ( tex2DNode1 * tex2DNode1 ) , ( tex2DNode2 * tex2DNode2 ) , i.vertexColor.r);
			float3 linear_color12 = lerpResult9.rgb;
			float3 localACESTonemap12 = ACESTonemap12( linear_color12 );
			float4 temp_cast_2 = (1.0).xxxx;
			float4 lerpResult16 = lerp( _ShadowColor , temp_cast_2 , ase_lightAtten);
			c.rgb = ( float4( localACESTonemap12 , 0.0 ) * lerpResult16 ).rgb;
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
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;35;1906;1038;1540.368;510.0365;1;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-1345.752,-256.679;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-1203.752,-46.679;Inherit;False;Property;_Tilling;Tilling;2;0;Create;True;0;0;False;0;False;1;2.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-1009.751,-155.679;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-743.3831,-309.3933;Inherit;True;Property;_Sand_Water;Sand_Water;0;0;Create;True;0;0;False;0;False;-1;311992eb0de996446a684dae69e9b75e;311992eb0de996446a684dae69e9b75e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-741,-36;Inherit;True;Property;_Sand_Land;Sand_Land;1;0;Create;True;0;0;False;0;False;-1;1fcc8780175d07c49a009b3f76c63ee6;1fcc8780175d07c49a009b3f76c63ee6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-373.2303,-298.1563;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;8;-477.2841,193.7479;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-343,4;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;14;-108.5808,410.1029;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;20.38736,354.6869;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;9;-123,0.3739173;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;15;-118.6563,191.4617;Inherit;False;Property;_ShadowColor;ShadowColor;3;0;Create;True;0;0;False;0;False;0,0,0,0;0.5490196,0.627451,0.6431373,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;12;184.8289,44.41981;Inherit;False;float3 tonemapped_color = saturate((linear_color*(2.8 * linear_color + 0))/(linear_color*(2.0 * linear_color + 1.0) + 0.0))@$return tonemapped_color@;3;False;1;True;linear_color;FLOAT3;0,0,0;In;;Inherit;False;ACESTonemap;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;16;224.9227,318.4147;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;454.647,165.2651;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;669.7206,-86.31981;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Beach;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;4;0
WireConnection;7;1;6;0
WireConnection;1;1;7;0
WireConnection;2;1;7;0
WireConnection;10;0;1;0
WireConnection;10;1;1;0
WireConnection;11;0;2;0
WireConnection;11;1;2;0
WireConnection;9;0;10;0
WireConnection;9;1;11;0
WireConnection;9;2;8;1
WireConnection;12;0;9;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;16;2;14;0
WireConnection;13;0;12;0
WireConnection;13;1;16;0
WireConnection;0;13;13;0
ASEEND*/
//CHKSM=591F6A7414ACEA2ECC15779005177CC6493A14D7