Shader "Custom/DiamondShader" {
    Properties {
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
        _Metallic ("Metallic (A)", 2D) = "white" { }
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _OcclusionMap ("Occlusion (G)", 2D) = "white" { }
        _EmissionMap ("Emission (RGB)", 2D) = "black" { }

        _Color ("Tint Color", Color) = (1, 1, 1, 1)
        _OcclusionStrength ("Occlusion Strength", Range(0, 1)) = 1
        _EmissionColor ("Emission Color", Color) = (0, 0, 0, 1)
        
        _Glossiness ("Smoothness", Range(0, 1)) = 0.5
        _Dist ("Refraction Intensity", Range(0, 1)) = 1.0
    }

    SubShader {
        Tags { "Queue" = "Overlay" "RenderType"="Transparent" "Queue"="Transparent" }
        Pass {
            Stencil {
                Ref 1
                Comp always
                Pass replace
            }
        }
        Pass {
            Stencil {
                Ref 1
                Comp equal
                Pass replace
            }

            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite On

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #pragma target 3.0

            // تعریف ورودی‌ها
            struct Input {
                float2 uv_MainTex;
                float3 worldPos;
                float4 screenPos;
            };

            // تعریف خروجی‌ها
            struct Output {
                float4 Albedo : COLOR;
                float3 Normal : NORMAL;
                float3 Emission : EMISSION;
                float Metallic : METALLIC;
                float Smoothness : SMOOTHNESS;
                float Occlusion : AMBIENT_OCCLUSION;
            };

            // تعریف ویژگی‌ها
            float4 _Color;
            sampler2D _MainTex;
            sampler2D _Metallic;
            sampler2D _BumpMap;
            sampler2D _OcclusionMap;
            sampler2D _EmissionMap;
            float _OcclusionStrength;
            float _Glossiness;
            float _Dist;
            float4 _EmissionColor;

            // تعریف تابع Surface
            Output Surface(Input i) {
                Output o;
                float2 uv = i.uv_MainTex;

                // اعمال تکسچر‌ها
                float4 c = tex2D(_MainTex, uv) * _Color;

                // اعمال نقشه نرمال
                o.Normal = UnpackNormal(tex2D(_BumpMap, uv));

                // اعمال نقشه Occlusion
                o.Occlusion = tex2D(_OcclusionMap, uv).r * _OcclusionStrength;

                // اعمال نقشه Emission
                o.Emission = tex2D(_EmissionMap, uv) * _EmissionColor;

                // اعمال شفافیت از تکسچر Alpha در _MainTex
                o.Albedo = c.rgb;
                o.Metallic = tex2D(_Metallic, uv).r;
                o.Smoothness = _Glossiness;

                return o;
            }
            ENDHLSL
        }
    }
}
