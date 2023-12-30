Shader "Custom/DiamondShader"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
        _Metallic ("Metallic (A)", 2D) = "white" { }
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _OcclusionMap ("Occlusion (G)", 2D) = "white" { }
        _EmissionMap ("Emission (RGB)", 2D) = "black" { }

        _Color ("Tint Color", Color) = (1, 1, 1, 1)
        _OcclusionStrength ("Occlusion Strength", Range(0, 1)) = 1
        _EmissionColor ("Emission Color", Color) = (0, 0, 0, 1)
        
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Dist ("Refraction Intensity", Float) = 1.0

    }

    SubShader
    {
        Tags { "Queue" = "Overlay" "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        Blend SrcAlpha OneMinusSrcAlpha // تنظیم حالت مخلوط‌کردن برای شفافیت
        Cull Off // غیرفعال کردن سیستم Culling
        GrabPass { "_RefractionTex" }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:fade
        #pragma target 3.0
 
        sampler2D _RefractionTex;
        float4 _RefractionTex_TexelSize;
        
        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float4 grabPos;
            INTERNAL_DATA

            UNITY_VERTEX_INPUT_INSTANCE_ID
            UNITY_VERTEX_OUTPUT_STEREO
        };

        sampler2D _MainTex;
        sampler2D _Metallic;
        sampler2D _BumpMap;
        sampler2D _OcclusionMap;
        sampler2D _EmissionMap;
        half _Glossiness;
        half _Dist;

        fixed4 _Color;
        float _OcclusionStrength;
        fixed4 _EmissionColor;
        float _Reflectivity;
        fixed4 _ReflectColor;
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT (Input, o);
 
            float4 pos = UnityObjectToClipPos (v.vertex);
            o.grabPos = ComputeGrabScreenPos (pos);
        }
        
        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            
           float2 uv = IN.grabPos.xy / IN.grabPos.w;
 
            float2 norm = normalize (mul ((float3x3)unity_WorldToCamera, o.Normal)).xy;
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = tex2D (_RefractionTex, uv - norm * 0.1 * _Dist) * _Color;

            o.Metallic = tex2D(_Metallic, IN.uv_MainTex).r;

            // اعمال نقشه نرمال
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));

            // اعمال نقشه Occlusion
            o.Occlusion = tex2D(_OcclusionMap, IN.uv_MainTex).r * _OcclusionStrength;

            // اعمال نقشه Emission
            o.Emission = tex2D(_EmissionMap, IN.uv_MainTex) * _EmissionColor;

            // اعمال شفافیت از تکسچر Alpha در _MainTex
            o.Alpha = c.a;
            
            o.Smoothness = _Glossiness;

            o.Metallic = _Reflectivity;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
