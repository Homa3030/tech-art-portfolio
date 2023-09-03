using System.Collections.Generic;
using UnityEngine;

public class InstancedMeshSpawner : MonoBehaviour
{
    private static readonly int ColorId = Shader.PropertyToID("_Color");

    [SerializeField] private Mesh _mesh;
    [SerializeField] private Material _material;

    private MaterialPropertyBlock _materialPropertyBlock;
    private List<Matrix4x4> _matrices;

    private void Start()
    {
        _matrices = new List<Matrix4x4>();
        var colors = new List<Vector4>();

        //filling the color and TRS matrices
        //rotation, scale and color are random but position is aligned to a grid 
        for (int i = 0; i < 10; i++)
        {
            for (int j = 0; j < 100; j++)
            {
                var position = new Vector3(2 * i, 0, 2 * j);
                var rotation = Quaternion.Euler(Random.Range(0, 360), Random.Range(0, 360), Random.Range(0, 360));
                Vector3 scale = Random.Range(0.75f, 1.25f) * Vector3.one;
                _matrices.Add(Matrix4x4.TRS(position, rotation, scale));

                colors.Add(new Vector4(Random.value, Random.value, Random.value, 1));
            }
        }

        _materialPropertyBlock = new MaterialPropertyBlock();
        _materialPropertyBlock.SetVectorArray(ColorId, colors);
    }

    private void Update()
    {
        Graphics.DrawMeshInstanced(_mesh, 0, _material, _matrices, _materialPropertyBlock);
    }
}