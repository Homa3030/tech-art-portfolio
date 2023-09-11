using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Assertions;

namespace Lit.Editor
{
    public class ChannelPackerEditorWindow : EditorWindow
    {
        [SerializeField] private Texture2D _r;
        [SerializeField] private Texture2D _g;
        [SerializeField] private Texture2D _b;
        [SerializeField] private Texture2D _a;
        
        private string _error;

        private void OnGUI()
        {
            _r = (Texture2D) EditorGUILayout.ObjectField("R", _r, typeof(Texture2D), false);
            _g = (Texture2D) EditorGUILayout.ObjectField("G", _g, typeof(Texture2D), false);
            _b = (Texture2D) EditorGUILayout.ObjectField("B", _b, typeof(Texture2D), false);
            _a = (Texture2D) EditorGUILayout.ObjectField("A", _a, typeof(Texture2D), false);

            if (!string.IsNullOrWhiteSpace(_error))
            {
                EditorGUILayout.HelpBox(_error, MessageType.Error);
            }

            //try
            //{
                if (GUILayout.Button("Generate"))
                {
                    Generate();
                    _error = null;
                }
            //}
            // catch (Exception e)
            // {
            //     Debug.LogError(e.Message);
            //     _error = e.Message;
            //     throw;
            // }
        }

        private void Generate()
        {
            int width = 0;
            int height = 0;
            Texture2D[] arr = new[] {_r, _g, _b, _a};

            foreach (Texture2D tex in arr)
            {
                if (tex != null)
                {
                    if (width == 0)
                    {
                        width = tex.width;
                        height = tex.height;
                    }
                    else
                    {
                        Assert.IsTrue(tex.width == width, "Width is not the same");
                        Assert.IsTrue(tex.height == height,"Height is not the same");
                    }
                }
            }

            if (_r != null)
            {
                Assert.IsTrue(_r.isReadable, "R is not readable");    
                Assert.IsFalse(_r.isDataSRGB, "R is sRGB");
            }

            if (_g != null)
            {
                Assert.IsTrue(_g.isReadable, "G is not readable");
                Assert.IsFalse(_g.isDataSRGB, "G is sRGB");    
            }
            
            if (_b != null)
            {
                Assert.IsTrue(_b.isReadable, "B is not readable");
                Assert.IsFalse(_b.isDataSRGB, "B is sRGB");    
            }
            
            if (_a != null)
            {
                Assert.IsTrue(_a.isReadable, "A is not readable");
                Assert.IsFalse(_a.isDataSRGB, "A is sRGB");    
            }


            Color[] whitePixels = Enumerable.Repeat(Color.white, width * height).ToArray();
            Color[] rPixels = _r == null ? whitePixels: _r.GetPixels();
            Color[] gPixels = _g == null ? whitePixels : _g.GetPixels();
            Color[] bPixels = _b == null ? whitePixels : _b.GetPixels();
            Color[] aPixels = _a == null ? whitePixels : _a.GetPixels();

            var packedPixels = new Color[rPixels.Length];

            for (int i = 0; i < rPixels.Length; i++)
            {
                var color = new Color(rPixels[i].r, gPixels[i].r, bPixels[i].r, aPixels[i].r);
                packedPixels[i] = color;
            }

            var texture = new Texture2D(_r.width, _g.height, _a == null ? TextureFormat.RGB24 : TextureFormat.RGBA32, false);
            texture.SetPixels(packedPixels);
            texture.Apply();

            byte[] pngBytes = texture.EncodeToPNG();

            string path = EditorUtility.SaveFilePanel("Save packed texture", "Assets", "PackedTexture", "png");
            if (!string.IsNullOrWhiteSpace(path))
            {
                File.WriteAllBytes(path, pngBytes);
                AssetDatabase.Refresh();

                if (path.StartsWith(Application.dataPath))
                {
                    path = "Assets" + path.Substring(Application.dataPath.Length);
                }

                var importer = (TextureImporter) AssetImporter.GetAtPath(path);

                importer.sRGBTexture = false;
                EditorUtility.SetDirty(importer);
                importer.SaveAndReimport();
            }
        }

        [MenuItem("Window/Rendering/Channel Packer")]
        public static void OpenWindow()
        {
            CreateWindow<ChannelPackerEditorWindow>().Show();
        }
    }
}