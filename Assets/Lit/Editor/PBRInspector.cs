using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace Lit.Editor
{
    public class PBRInspector : ShaderInspectorBase
    {
        public enum BlendType
        {
            Alpha,
            Premultiplied,
            Additive,
            Multiply
        }

        protected override void UpdateSurfaceType(Material material)
        {
            base.UpdateSurfaceType(material);
            if (material.GetTexture("_NormalMap") == null)
            {
                material.DisableKeyword("_NORMALMAP");
            }
            else
            {
                material.EnableKeyword("_NORMALMAP");
            }
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
        
            Material material = materialEditor.target as Material;
            var blendProp = BaseShaderGUI.FindProperty("_BlendType", properties, true);
        
            EditorGUI.BeginChangeCheck();
            blendProp.floatValue =
                (int) (FaceRenderingMode) EditorGUILayout.EnumPopup("Blend type", (BlendType) blendProp.floatValue);

            base.OnGUI(materialEditor, properties);
        
            if(EditorGUI.EndChangeCheck()) {
                UpdateSurfaceType(material);
            }
        }

        protected override void OnBeforeAutoProperties(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            EditorGUILayout.HelpBox("Red channel - Metallic mask\n" +
                                    "Green channel - Smoothness mask\n", MessageType.Info);
            MaterialProperty mask = FindProperty("_Mask", properties);
            materialEditor.TextureProperty(mask, "Mask");
        }

        protected override void EnableAlphaMultiplyKeywordIfNeeded(SurfaceType surface, Material material)
        {
            BlendType blend = (BlendType)material.GetFloat("_BlendType");
            if(surface == SurfaceType.TransparentBlend && blend == BlendType.Premultiplied) {
                material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
            } else {
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
            }
        }

        protected override void TransparentBlending(Material material)
        {
            BlendType blend = (BlendType)material.GetFloat("_BlendType");
            switch (blend)
            {
                case BlendType.Alpha:
                    material.SetInt("_SourceBlend", (int) BlendMode.SrcAlpha);
                    material.SetInt("_DestBlend", (int) BlendMode.OneMinusSrcAlpha);
                    break;
                case BlendType.Premultiplied:
                    material.SetInt("_SourceBlend", (int) BlendMode.One);
                    material.SetInt("_DestBlend", (int) BlendMode.OneMinusSrcAlpha);
                    break;
                case BlendType.Additive:
                    material.SetInt("_SourceBlend", (int) BlendMode.SrcAlpha);
                    material.SetInt("_DestBlend", (int) BlendMode.One);
                    break;
                case BlendType.Multiply:
                    material.SetInt("_SourceBlend", (int) BlendMode.Zero);
                    material.SetInt("_DestBlend", (int) BlendMode.SrcColor);
                    break;
            }
            material.SetInt("_ZWrite", 0);
        }
    }
}
