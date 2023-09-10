using UnityEngine;
using UnityEngine.Rendering;

namespace Lit.Editor
{
    public class BlinnPhongInspector : ShaderInspectorBase
    {
        protected override void EnableAlphaMultiplyKeywordIfNeeded(SurfaceType surface, Material material)
        { }

        protected override void TransparentBlending(Material material)
        {
            material.SetInt("_SourceBlend", (int)BlendMode.SrcAlpha);
            material.SetInt("_DestBlend", (int)BlendMode.OneMinusSrcAlpha);
            material.SetInt("_ZWrite", 0);
        }
    }
}
