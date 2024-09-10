// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon_Tree"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Alpha("Alpha", Range( 0 , 1)) = 1
		_GlobalWindSpeed1("GlobalWindSpeed", Float) = 0.5
		_GlobalWindDirection1("GlobalWindDirection", Vector) = (0,0,-1,0)
		_GlobalWindStrength1("GlobalWindStrength", Float) = 1
		_SmallSpeed1("SmallSpeed", Float) = 0
		_SmallWeight1("SmallWeight", Float) = 0.65
		_WindWaveScale("WindWaveScale", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _GlobalWindSpeed1;
		uniform float _GlobalWindStrength1;
		uniform float3 _GlobalWindDirection1;
		uniform float _SmallSpeed1;
		uniform float _WindWaveScale;
		uniform float _SmallWeight1;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _Alpha;
		uniform float _Cutoff = 0.5;


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		float3 ACESTonemap12( float3 linear_color )
		{
			float3 tonemapped_color = saturate((linear_color*(3 * linear_color + 0))/(linear_color*(2.0 * linear_color + 1.0) + 0.0));
			return tonemapped_color;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float temp_output_21_0 = ( ( ( ( _GlobalWindSpeed1 * 0.5 ) * _Time.y ) + v.color.b ) * ( 2.0 * UNITY_PI ) );
			float temp_output_23_0 = ( _GlobalWindStrength1 * 0.1 );
			float3 temp_output_7_0_g2 = float3(0,0,1);
			float3 RotateAxis34_g2 = cross( temp_output_7_0_g2 , float3(0,1,0) );
			float3 wind_direction31_g2 = temp_output_7_0_g2;
			float3 wind_speed40_g2 = ( ( _Time.y * _SmallSpeed1 ) * float3(0.5,-0.5,-0.5) );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float temp_output_148_0_g2 = _WindWaveScale;
			float3 temp_cast_0 = (1.0).xxx;
			float3 temp_output_22_0_g2 = abs( ( ( frac( ( ( ( wind_direction31_g2 * wind_speed40_g2 ) + ( ase_worldPos / ( 10.0 * temp_output_148_0_g2 ) ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
			float3 temp_cast_1 = (3.0).xxx;
			float dotResult30_g2 = dot( ( ( temp_output_22_0_g2 * temp_output_22_0_g2 ) * ( temp_cast_1 - ( temp_output_22_0_g2 * 2.0 ) ) ) , wind_direction31_g2 );
			float BigTriangleWave42_g2 = dotResult30_g2;
			float3 temp_cast_2 = (1.0).xxx;
			float3 temp_output_59_0_g2 = abs( ( ( frac( ( ( wind_speed40_g2 + ( ase_worldPos / ( 2.0 * temp_output_148_0_g2 ) ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
			float3 temp_cast_3 = (3.0).xxx;
			float SmallTriangleWave52_g2 = distance( ( ( temp_output_59_0_g2 * temp_output_59_0_g2 ) * ( temp_cast_3 - ( temp_output_59_0_g2 * 2.0 ) ) ) , float3(0,0,0) );
			float3 rotatedValue72_g2 = RotateAroundAxis( ( ase_worldPos - float3(0,0.1,0) ), ase_worldPos, normalize( RotateAxis34_g2 ), ( ( BigTriangleWave42_g2 + SmallTriangleWave52_g2 ) * ( 2.0 * UNITY_PI ) ) );
			float3 worldToObj81_g2 = mul( unity_WorldToObject, float4( rotatedValue72_g2, 1 ) ).xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 TreeWindAnimVertex37 = ( ( v.color.r * ( sin( temp_output_21_0 ) * temp_output_23_0 ) * _GlobalWindDirection1 ) + ( ( _GlobalWindDirection1 * ( cos( temp_output_21_0 ) * temp_output_23_0 ) * v.color.g ) + ( v.color.g * ( worldToObj81_g2 - ase_vertex3Pos ) * _SmallWeight1 ) ) );
			v.vertex.xyz += TreeWindAnimVertex37;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float3 linear_color12 = ( tex2DNode1 * tex2DNode1 ).rgb;
			float3 localACESTonemap12 = ACESTonemap12( linear_color12 );
			o.Emission = localACESTonemap12;
			o.Alpha = _Alpha;
			clip( tex2DNode1.a - _Cutoff );
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
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
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
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
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
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
1102;491;1906;1038;1200.873;282.5551;1.254186;True;False
Node;AmplifyShaderEditor.CommentaryNode;13;-1858.666,487.4714;Inherit;False;2474.418;1182.637;TreeWind;29;40;39;37;36;35;34;33;32;31;30;29;28;27;26;25;24;23;22;21;20;19;18;17;16;15;14;43;44;45;TreeWind;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1810.426,782.9485;Inherit;False;Constant;_Float2;Float 1;9;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1838.485,706.9127;Inherit;False;Property;_GlobalWindSpeed1;GlobalWindSpeed;3;0;Create;True;0;0;False;0;False;0.5;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1560.487,743.4094;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;16;-1653.839,864.2595;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;45;-1540.067,925.6362;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-1392.96,747.9756;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-1239.067,760.6362;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;18;-1359.028,1017.144;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1758.293,1067.168;Inherit;False;Property;_GlobalWindStrength1;GlobalWindStrength;5;0;Create;True;0;0;False;0;False;1;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1712.075,1196.938;Inherit;False;Constant;_Float1;Float 0;9;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1192.536,892.0554;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1235.105,1418.35;Inherit;False;Property;_SmallSpeed1;SmallSpeed;6;0;Create;True;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;24;-1043.443,1099.396;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1207.811,1325.664;Inherit;False;Property;_WindWaveScale;WindWaveScale;8;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1425.505,1162.663;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;39;-1233.58,1503.418;Inherit;False;Constant;_Vector5;Vector 4;14;0;Create;True;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;26;-696.5222,930.1045;Inherit;False;Property;_GlobalWindDirection1;GlobalWindDirection;4;0;Create;True;0;0;False;0;False;0,0,-1;1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-822.6022,1166.059;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;25;-1040.275,766.7424;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;27;-751.3478,1287.491;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-594.8203,1590.316;Inherit;False;Property;_SmallWeight1;SmallWeight;7;0;Create;True;0;0;False;0;False;0.65;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;42;-901.2006,1484.283;Inherit;False;SimpleGrassWind;-1;;2;eb6b5a71d4f47f64ab6869a5d5d0a9be;0;5;148;FLOAT;1;False;85;FLOAT;0;False;86;FLOAT;1;False;1;FLOAT;1;False;7;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-323.5932,1477.788;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-354.8222,1158.591;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;30;-767.6082,537.4714;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-756.8568,739.3784;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-925.913,121.8263;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;False;-1;None;49dd10e056cde1646829c78cbae6d92c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-101.8072,1284.572;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-309.1373,801.8765;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-525.6957,91.82615;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;123.7797,877.1775;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;6;156.0225,216.791;Inherit;False;Property;_Alpha;Alpha;2;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;12;233.2505,106.2036;Inherit;False;float3 tonemapped_color = saturate((linear_color*(3 * linear_color + 0))/(linear_color*(2.0 * linear_color + 1.0) + 0.0))@$return tonemapped_color@;3;False;1;True;linear_color;FLOAT3;0,0,0;In;;Inherit;False;ACESTonemap;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;292.3709,889.708;Inherit;False;TreeWindAnimVertex;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;638.7321,57.0442;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Toon_Tree;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;17;0;15;0
WireConnection;17;1;14;0
WireConnection;19;0;17;0
WireConnection;19;1;16;0
WireConnection;44;0;19;0
WireConnection;44;1;45;3
WireConnection;21;0;44;0
WireConnection;21;1;18;0
WireConnection;24;0;21;0
WireConnection;23;0;22;0
WireConnection;23;1;20;0
WireConnection;28;0;24;0
WireConnection;28;1;23;0
WireConnection;25;0;21;0
WireConnection;42;148;43;0
WireConnection;42;1;40;0
WireConnection;42;7;39;0
WireConnection;33;0;27;2
WireConnection;33;1;42;0
WireConnection;33;2;29;0
WireConnection;31;0;26;0
WireConnection;31;1;28;0
WireConnection;31;2;27;2
WireConnection;32;0;25;0
WireConnection;32;1;23;0
WireConnection;34;0;31;0
WireConnection;34;1;33;0
WireConnection;35;0;30;1
WireConnection;35;1;32;0
WireConnection;35;2;26;0
WireConnection;7;0;1;0
WireConnection;7;1;1;0
WireConnection;36;0;35;0
WireConnection;36;1;34;0
WireConnection;12;0;7;0
WireConnection;37;0;36;0
WireConnection;0;2;12;0
WireConnection;0;9;6;0
WireConnection;0;10;1;4
WireConnection;0;11;37;0
ASEEND*/
//CHKSM=47BD1B2028634FF5DFE117F209389B19F7722383