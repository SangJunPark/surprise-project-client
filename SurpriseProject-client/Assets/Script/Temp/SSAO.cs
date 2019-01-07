using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SSAO : MonoBehaviour
{
    [SerializeField] float depthLevel;
    [SerializeField] float radius;
    [Range(1, 8)]
    [SerializeField] int kernelSize;

    Camera cam;
    [SerializeField] RenderTexture depthTexture;

    private Shader _depthShader;
    private Shader depthShader
    {
        get
        {
            return _depthShader != null ? _depthShader : (_depthShader = Shader.Find("Custom/Depth"));
        }
    }

    private Material _depthMaterial;
    private Material depthMaterial
    {
        get { return _depthMaterial != null ? _depthMaterial : (_depthMaterial = new Material(depthShader));}
    }
    
    void Awake()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.Depth;
        //cam.targetTexture = depthTexture;
        depthMaterial.hideFlags = HideFlags.HideAndDontSave;
    }

    void Update()
    {
        //depthTexture = new RenderTexture(1024, 1024, 1, RenderTextureFormat.ARGB32);
        //cam.Render();
    }

    public void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(depthShader != null)
        {
            depthMaterial.SetFloat("_DepthLevel", depthLevel);
            depthMaterial.SetFloat("_Radius", radius);
            depthMaterial.SetFloat("_KernelSize", kernelSize);

            Graphics.Blit(src, dest, depthMaterial);
            //Graphics.Blit(src, dest);
            //Gra
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
