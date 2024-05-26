// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Fire"
{
	Properties
	{
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0,-0.7,0,0)
		_Color0("Color 0", Color) = (1,0.4414282,0,0)
		_Gradient("Gradient", 2D) = "white" {}
		_SmoothFlame("SmoothFlame", Range( 0 , 1)) = 0.3282005
		_InnerFlameHeight("InnerFlameHeight", Float) = 1
		_EmissionIntensity("EmissionIntensity", Float) = 2
		_FireShape("FireShape", 2D) = "white" {}
		_SmoothShape("SmoothShape", Float) = 0.1
		_FlameIntensity("FlameIntensity", Float) = 3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _EmissionIntensity;
		uniform float4 _Color0;
		uniform float _InnerFlameHeight;
		uniform sampler2D _Gradient;
		SamplerState sampler_Gradient;
		uniform float4 _Gradient_ST;
		uniform sampler2D _Noise;
		SamplerState sampler_Noise;
		uniform float2 _NoiseSpeed;
		uniform float4 _Noise_ST;
		uniform float _SmoothFlame;
		uniform sampler2D _FireShape;
		SamplerState sampler_FireShape;
		uniform float _SmoothShape;
		uniform float _FlameIntensity;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 break29 = ( _EmissionIntensity * _Color0 );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float4 tex2DNode11 = tex2D( _Gradient, uv_Gradient );
			float FlameRange43 = ( _InnerFlameHeight * ( 1.0 - tex2DNode11.r ) );
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner7 = ( 1.0 * _Time.y * _NoiseSpeed + uv_Noise);
			float Noise17 = tex2D( _Noise, panner7 ).r;
			float4 appendResult30 = (float4(break29.r , ( break29.g + ( FlameRange43 * Noise17 ) ) , break29.b , 0.0));
			float4 FlameColor62 = appendResult30;
			o.Emission = FlameColor62.xyz;
			float clampResult16 = clamp( ( Noise17 - _SmoothFlame ) , 0.0 , 1.0 );
			float Gradient60 = tex2DNode11.r;
			float smoothstepResult14 = smoothstep( clampResult16 , Noise17 , Gradient60);
			float2 appendResult42 = (float2(( i.uv_texcoord.x + ( (Noise17*2.0 + -1.0) * _SmoothShape * FlameRange43 ) ) , i.uv_texcoord.y));
			float4 tex2DNode34 = tex2D( _FireShape, appendResult42 );
			float clampResult50 = clamp( ( ( tex2DNode34.r * tex2DNode34.r ) * _FlameIntensity ) , 0.0 , 1.0 );
			float FlameShape56 = clampResult50;
			o.Alpha = ( smoothstepResult14 * FlameShape56 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

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
206.6667;72.66667;1190.667;641.6667;1573.374;-322.4268;1.507338;True;False
Node;AmplifyShaderEditor.CommentaryNode;55;-2065.049,63.90895;Inherit;False;1057.539;374.8011;;5;6;8;7;5;17;Noise Animation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;53;-2389.52,-510.7783;Inherit;False;1358.848;413.1556;;7;12;11;22;24;23;43;60;Flame Range;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;8;-1989.449,277.71;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;1;0;Create;True;0;0;False;0;False;0,-0.7;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-2015.049,137.3091;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-2339.52,-303.642;Inherit;False;0;11;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;7;-1754.145,141.209;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;11;-2069.587,-327.6228;Inherit;True;Property;_Gradient;Gradient;3;0;Create;True;0;0;False;0;False;-1;3f6983171245fc44d91f0c0ac57e6ac8;3f6983171245fc44d91f0c0ac57e6ac8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;22;-1677.881,-341.8785;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1772.781,-460.7782;Inherit;False;Property;_InnerFlameHeight;InnerFlameHeight;5;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1550.845,113.909;Inherit;True;Property;_Noise;Noise;0;0;Create;True;0;0;False;0;False;-1;2748981c7560cd948a9fdc3849c6b657;2748981c7560cd948a9fdc3849c6b657;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;59;-2136.98,605.0283;Inherit;False;2271.311;535.5029;;14;44;47;38;41;37;35;39;40;42;45;48;50;34;56;Flame Shape;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1504.98,-445.8784;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-1235.51,137.7415;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-1258.67,-314.0607;Inherit;False;FlameRange;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-2086.98,807.1307;Inherit;False;17;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-1886.779,1025.531;Inherit;False;43;FlameRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;41;-1868.577,799.3306;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1897.177,922.8295;Inherit;False;Property;_SmoothShape;SmoothShape;8;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-1767.176,655.0283;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1665.777,846.1307;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-1465.579,665.4301;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;42;-1292.679,703.1302;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;64;-939.023,-704.1695;Inherit;False;1385.832;608.4988;;10;10;25;32;52;26;31;29;28;30;62;Flame Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-865.387,-654.1695;Inherit;False;Property;_EmissionIntensity;EmissionIntensity;6;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;34;-1134.077,665.4282;Inherit;True;Property;_FireShape;FireShape;7;0;Create;True;0;0;False;0;False;-1;ad91f2be29f1e1548bde5d7b94cb7705;ad91f2be29f1e1548bde5d7b94cb7705;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;10;-889.023,-557.8018;Inherit;False;Property;_Color0;Color 0;2;0;Create;True;0;0;False;0;False;1,0.4414282,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;32;-646.704,-271.4998;Inherit;False;17;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-796.1374,958.5714;Inherit;False;Property;_FlameIntensity;FlameIntensity;9;0;Create;True;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-815.6362,710.2714;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-634.0204,-358.1484;Inherit;False;43;FlameRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-645.6875,-581.3691;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-871.8478,249.1693;Inherit;False;Property;_SmoothFlame;SmoothFlame;4;0;Create;True;0;0;False;0;False;0.3282005;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-798.0475,162.069;Inherit;False;17;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;29;-448.0881,-580.0683;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-358.3912,-348.6707;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-555.6371,790.8715;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;13;-594.9482,169.8687;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;50;-371.0368,789.5715;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-1692.737,-222.1284;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-188.2956,-479.0828;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-93.66927,785.447;Inherit;False;FlameShape;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;30;-29.48827,-580.0683;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-491.4448,83.16855;Inherit;False;60;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;16;-443.1476,169.8701;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-530.248,314.1704;Inherit;False;17;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;14;-212.7489,143.8699;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;218.8092,-584.9915;Inherit;False;FlameColor;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-199.3445,384.9472;Inherit;False;56;FlameShape;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-36.29153,46.16962;Inherit;False;62;FlameColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;26.94898,312.2703;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;216.2251,6.101316;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Fire;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;6;0
WireConnection;7;2;8;0
WireConnection;11;1;12;0
WireConnection;22;0;11;1
WireConnection;5;1;7;0
WireConnection;23;0;24;0
WireConnection;23;1;22;0
WireConnection;17;0;5;1
WireConnection;43;0;23;0
WireConnection;41;0;38;0
WireConnection;39;0;41;0
WireConnection;39;1;37;0
WireConnection;39;2;44;0
WireConnection;40;0;35;1
WireConnection;40;1;39;0
WireConnection;42;0;40;0
WireConnection;42;1;35;2
WireConnection;34;1;42;0
WireConnection;45;0;34;1
WireConnection;45;1;34;1
WireConnection;26;0;25;0
WireConnection;26;1;10;0
WireConnection;29;0;26;0
WireConnection;31;0;52;0
WireConnection;31;1;32;0
WireConnection;48;0;45;0
WireConnection;48;1;47;0
WireConnection;13;0;18;0
WireConnection;13;1;15;0
WireConnection;50;0;48;0
WireConnection;60;0;11;1
WireConnection;28;0;29;1
WireConnection;28;1;31;0
WireConnection;56;0;50;0
WireConnection;30;0;29;0
WireConnection;30;1;28;0
WireConnection;30;2;29;2
WireConnection;16;0;13;0
WireConnection;14;0;61;0
WireConnection;14;1;16;0
WireConnection;14;2;19;0
WireConnection;62;0;30;0
WireConnection;36;0;14;0
WireConnection;36;1;57;0
WireConnection;0;2;63;0
WireConnection;0;9;36;0
ASEEND*/
//CHKSM=34F0D878B7D3E89E197908DA58B4C17FA2CCDC5E