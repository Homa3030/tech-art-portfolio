using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Unity.Collections;
using UnityEditor;
using UnityEngine;

namespace TreeShader.Editor
{
    public class TreeAssetPostprocessor : AssetPostprocessor
    {
        [UsedImplicitly]
        private void OnPostprocessModel(GameObject gameObject)
        {
            string name = gameObject.name;
            if (!name.Contains("PIVOT_BAKING"))
            {
                return;
            }

            var combinedBranchMesh = new Mesh
            {
                name = "BranchMesh",
            };
            var combinedVertices = new List<Vector3>();
            var combinedNormals = new List<Vector3>();
            var combinedUvs = new List<Vector2>();
            var combinedVertexColors = new List<Vector4>();

            Material[] branchMaterials = null;
            List<int>[] combinedIndexBuffers = null;

            // Iterate over all children
            foreach (Transform child in gameObject.transform)
            {
                if (child.name.Contains("Branch", StringComparison.OrdinalIgnoreCase))
                {
                    Debug.Log(child.name);

                    Mesh branchMesh = child.GetComponent<MeshFilter>().sharedMesh;

                    // on first branch
                    if (branchMaterials == null)
                    {
                        branchMaterials = child.GetComponent<MeshRenderer>().sharedMaterials;
                        combinedBranchMesh.subMeshCount = branchMesh.subMeshCount;

                        combinedIndexBuffers = new List<int>[branchMesh.subMeshCount];

                        for (int i = 0; i < combinedIndexBuffers.Length; i++)
                        {
                            combinedIndexBuffers[i] = new List<int>();
                        }
                    }

                    int indexOffset = combinedVertices.Count;
                    Vector3[] vertices = branchMesh.vertices;
                    Vector3[] normals = branchMesh.normals;

                    for (int vertexIndex = 0; vertexIndex < branchMesh.vertexCount; ++vertexIndex)
                    {
                        Vector4 vertexOs = vertices[vertexIndex];
                        vertexOs.w = 1;
                        Vector4 normalOs = normals[vertexIndex];
                        normalOs.w = 0;

                        Transform branchTransform = child.transform;
                        var branchMatrix = Matrix4x4.TRS(branchTransform.localPosition, branchTransform.localRotation,
                            branchTransform.localScale
                        );

                        Vector3 vertexWs = branchMatrix * vertexOs;
                        Vector3 normalWs = (branchMatrix * normalOs).normalized;
                        combinedVertices.Add(vertexWs);
                        combinedNormals.Add(normalWs);
                        combinedVertexColors.Add(branchTransform.localPosition);
                    }

                    combinedUvs.AddRange(branchMesh.uv);

                    for (int subMeshIndex = 0; subMeshIndex < branchMesh.subMeshCount; subMeshIndex++)
                    {
                        int[] indices = branchMesh.GetIndices(subMeshIndex);

                        foreach (int index in indices)
                        {
                            combinedIndexBuffers[subMeshIndex].Add(index + indexOffset);
                        }
                    }
                }
            }

            if (branchMaterials == null || combinedIndexBuffers == null)
            {
                return;
            }

            combinedBranchMesh.SetVertices(combinedVertices);
            combinedBranchMesh.SetNormals(combinedNormals);
            combinedBranchMesh.SetUVs(0, combinedUvs);

            var vertexColorsNativeArray = new NativeArray<Vector4>(combinedVertexColors.ToArray(), Allocator.Temp);
            combinedBranchMesh.SetColors(vertexColorsNativeArray);
            vertexColorsNativeArray.Dispose();

            for (int subMeshIndex = 0; subMeshIndex < combinedIndexBuffers.Length; ++subMeshIndex)
            {
                List<int> indices = combinedIndexBuffers[subMeshIndex];
                combinedBranchMesh.SetIndices(indices, MeshTopology.Triangles, subMeshIndex);
            }

            var combinedBranches = new GameObject("CombinedBranches");
            combinedBranches.transform.parent = gameObject.transform;

            combinedBranches.gameObject.AddComponent<MeshFilter>().mesh = combinedBranchMesh;
            combinedBranches.gameObject.AddComponent<MeshRenderer>().sharedMaterials = branchMaterials;

            context.AddObjectToAsset(combinedBranchMesh.name, combinedBranchMesh);
        }
    }
}