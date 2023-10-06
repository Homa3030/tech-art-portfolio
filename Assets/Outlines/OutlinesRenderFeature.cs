using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Outlines
{
    public class OutlinesRenderFeature : ScriptableRendererFeature
    {
        public OutlineSettings Settings;

        private OutlinesRenderPass _outlinesRenderPass;

        public override void Create()
        {
            _outlinesRenderPass = new OutlinesRenderPass(Settings);
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            renderer.EnqueuePass(_outlinesRenderPass);
        }
    }

    [Serializable]
    public class OutlineSettings
    {
        [Min(0)] public float ColorThreshold = 1.5f;
        [Min(0)] public float DepthThreshold = 90.0f;
        [Min(0)] public float NormalsThreshold = 0.5f;
    }

    public class OutlinesRenderPass : ScriptableRenderPass
    {
        private static readonly int TemporaryRtId = Shader.PropertyToID("_OutlineTemporaryRT");
        private static readonly int ColorThreshold = Shader.PropertyToID("_ColorThreshold");
        private static readonly int DepthThreshold = Shader.PropertyToID("_DepthThreshold");
        private static readonly int NormalsThreshold = Shader.PropertyToID("_NormalsThreshold");
        private readonly Material _material;
        private OutlineSettings _outlineSettings;

        public OutlinesRenderPass(OutlineSettings outlineSettings)
        {
            _outlineSettings = outlineSettings;
            
            renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
            _material = CoreUtils.CreateEngineMaterial("Hidden/Outlines");

            ConfigureInput(ScriptableRenderPassInput.Normal);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get("Outlines");

            RTHandle cameraColor = renderingData.cameraData.renderer.cameraColorTargetHandle;
            cmd.CopyTexture(cameraColor, TemporaryRtId);
            cmd.Blit(TemporaryRtId, cameraColor, _material);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            base.OnCameraSetup(cmd, ref renderingData);

            cmd.GetTemporaryRT(TemporaryRtId, renderingData.cameraData.cameraTargetDescriptor);
            
            _material.SetFloat(ColorThreshold, _outlineSettings.ColorThreshold);
            _material.SetFloat(DepthThreshold, _outlineSettings.DepthThreshold);
            _material.SetFloat(NormalsThreshold, _outlineSettings.NormalsThreshold);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            base.OnCameraCleanup(cmd);

            cmd.ReleaseTemporaryRT(TemporaryRtId);
        }
    }
}