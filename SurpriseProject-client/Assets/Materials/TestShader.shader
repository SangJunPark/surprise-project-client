// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Depth"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_DepthLevel("Depth Level", Range(1, 3)) = 1
		_Radius("Radius", Range(0, 3)) = 0.3
		_KernelSize("Kernel Size", Range(1, 8)) = 8
	}
		SubShader
	{
		Pass
	{
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

	uniform sampler2D _MainTex;
	uniform sampler2D _CameraDepthTexture;
	uniform fixed _DepthLevel;
	uniform half _Radius;
	uniform half _KernelSize;
	uniform half4 _MainTex_TexelSize;

	struct input
	{
		float4 pos : POSITION;
		half2 uv : TEXCOORD0;
	};

	struct output
	{
		float4 pos : SV_POSITION;
		half2 uv : TEXCOORD0;
	};


	output vert(input i)
	{
		output o;
		o.pos = UnityObjectToClipPos(i.pos);
		o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, i.uv);
		// why do we need this? cause sometimes the image I get is flipped. see: http://docs.unity3d.com/Manual/SL-PlatformDifferences.html
#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0)
			o.uv.y = 1 - o.uv.y;
#endif

		return o;
	}

	fixed4 frag(output o) : COLOR
	{
		float3 kernel[8] = {
		float3(0.5381, 0.1856,-0.4319), float3(0.1379, 0.2486, 0.4430),
		float3(0.3371, 0.5679,-0.0057), float3(-0.6999,-0.0451,-0.0019),
		float3(0.0689,-0.1598,-0.8547), float3(0.0560, 0.0069,-0.1843),
		float3(-0.0146, 0.1402, 0.0762), float3(0.0100,-0.1924,-0.0344)
		};


		float _depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, o.uv));
		float depth = pow(Linear01Depth(_depth), _DepthLevel);
		float4 ssaoParam = float4(0.3, 0.5, 0.1, 1);
		//return depth;

		float4 main = tex2D(_MainTex, o.uv);
		float radius = _Radius;
		float3 kernelScale = float3(radius / depth, radius / depth, radius / _ZBufferParams.z);
		float occlusion = 0;
		//float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, o.uv));
		//for (int j = 0; j < 3; j++)
		//{
			for (int i = 0; i < _KernelSize; ++i)
			{
				float3 rotateKernel = reflect(kernel[i], normalize(float3(0.1, 0.5, 0.3))) * kernelScale;

				float sampleDepth = tex2D(_CameraDepthTexture, rotateKernel.xy + o.uv).r;
				float delta = max(sampleDepth - _depth + rotateKernel.z, 0);
				float range = abs(delta) / (kernelScale.z * ssaoParam.z);
				occlusion += lerp(delta * ssaoParam.w, ssaoParam.x, saturate(range));
				//return occlusion;
			}
		//}

		return occlusion;
		
		//main = pow(main, occlusion);
		main -= occlusion;
		return main * 2;

	}

		ENDCG
	}
	}
}