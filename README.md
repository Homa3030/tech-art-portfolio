# Tech Art Portfolio
>Project uses Universal Render Pipeline

## Table Of Contents
1. [ Blinn Phong shader ](#blinn-phong)
2. [ Blinn Phong shader with texture rotation ](#blinn-phong-texture-rotation)
3. [ Bling Phong With Shadows and Transparency ](#bling-phong-shadows-transparency)
4. [ PBR ](#pbr)
5. [ Channel Packer Editor ](#channel-packer-editor)
6. [ Toon Shader ](#toon-shader) 
7. [ Circle Of Nth Power ](#circle-of-nth-power)
8. [ Instancing ](#instancing)
9. [ Smoke With Distortion ](#smoke-with-distortion)
10. [ Triplanar Mapping ](#triplanar)
11. [ Triplanar Grass Effect (Shader Graph) ](#triplanar-grass)
12. [ Outline ](#outline)
13. [ Procedural Gradient Skybox With Clouds ](#cloud-skybox)
14. [ Tree Animation Shader (Pivot Baking) ](#tree-animation)

<a name="blinn-phong"></a>
## Blinn Phong shader
### Features
- Albedo: Color and Texture
- Texture: Tilling and Offset
- Diffuse
- Specular

![Bling-Phong1](./Screenshots/BlinnPhong1.jpg "Bling-Phong shader")
![Bling-Phong2](./Screenshots/BlinnPhong2.jpg "Bling-Phong shader")

<a name="blinn-phong-texture-rotation"></a>
## Blinn Phong shader with texture rotation
### Features
- Albedo: Color and Texture
- Texture: Tilling/Offset and rotation round center
- Diffuse
- Specular

![Bling-Phong texture rotation](./Screenshots/TextureRotation.gif "Texture rotation")

<a name="bling-phong-shadows-transparency"></a>
## Bling Phong With Shadows and Transparency
### Features in addition to default Blinn Phong shader:
- Shadows (receive and cast)
- Transparency (blend + cutout)
- Front, Back, Double sided rendering modes

![Blinn-Phong Transparent3](./Screenshots/BlinnPhongTransparent3.png)
![Blinn-Phong Transparent3](./Screenshots/BlinnPhongTransparent1.gif "Cutout transparency")
![Blinn-Phong Transparent3](./Screenshots/BlinnPhongTransparent2.gif "Blend transparency")

<a name="pbr"></a>
## PBR
### Features:
- Albedo, Normal, Metallic, Smoothness, Specular, Emission maps are supported
- Parallax mapping
- Specular/Metallic setup workflow
- Texture Channel Packing

![PBR5](./Screenshots/ParallaxMapping.gif)
![PBR3](./Screenshots/PBR3.png)
![PBR4](./Screenshots/PBR4.png)
![PBR1](./Screenshots/PBR1.png)
![PBR2](./Screenshots/PBR2.png)

<a name="channel-packer-editor"></a>
## Channel Packer Editor
### Feature:
- Packs several masks(up to 4) into one RGBA mask.

Example: Metallic and Smoothness masks are packed into one mask
![ChannelPacker1](./Screenshots/ChannelPacker1.png "Editor")
![ChannelPacker3](./Screenshots/ChannelPacker3.png "Red Channel" )
![ChannelPacker2](./Screenshots/ChannelPacker2.png "Green Channel")
![ChannelPacker4](./Screenshots/ChannelPacker4.png "Blue Channel")
![ChannelPacker5](./Screenshots/ChannelPacker5.png "RGB Channel")

<a name="toon-shader"></a>
## Toon Shader
### Features
- Albedo: Color and Texture (configurable shadow color and intensity)
- Texture: Tilling and Offset
- Diffuse (configurable smoothness and threshold)
- Specular (configurable smoothness and threshold)

![ToonShader](Screenshots/ToonShader.gif)

<a name="circle-of-nth-power"></a>
## Circle Of Nth Power
### Features
- Plots the [squircle](https://en.wikipedia.org/wiki/Squircle) with the particular power. 

![CircleOfNthPower](Screenshots/CircleOfNthPower.gif)

<a name="instancing"></a>
## Instancing
### Features
- Rendering 1000 cubes with random rotation, scale and color using instancing.

![Instancing](Screenshots/Instancing.jpg)

DrawCalls:

![Instancing](Screenshots/Instancing_DrawCall1.jpg)
![Instancing](Screenshots/Instancing_DrawCall2.jpg)

<a name="smoke-with-distortion"></a>
## Smoke With Distortion
### Features:
- Distortion uses opaque texture

![Smoke With Distortion](Screenshots/SmokeWithDistortion.gif)

<a name="triplanar"></a>
## Triplanar Mapping
### Features:
- Albedo blending 
- Normal map blending (UDN)
- Configurable blend sharpness
- Normal strength (per texture) 

![Triplanar Shader](Screenshots/TriplanarShader.gif)

<a name="triplanar-grass"></a>
## Triplanar Grass Effect (Shader Graph)
### Features:
- Normal direction-based blending between rock and grass textures
- Configurable threshold and smoothness of the rock to grass transition

![Triplanar Grass Effect](Screenshots/TriplanarGrassEffect.gif)

<a name="outline"></a>
## Outline
### Features:
- Implemented as URP Render Feature
- Sobel filter for color, depth and normals

![Outline](Screenshots/Outline.png)

<a name="cloud-skybox"></a>
## Procedural Gradient Skybox With Clouds
### Features:
- Implemented in Shader Graph
- Clouds implemented using the noise texture

![Skybox](Screenshots/ProceduralSkyboxWithClouds.gif)

<a name="tree-animation"></a>
## Tree Animation Shader (Pivot Baking)
### Features:
- Asset post processor that bakes pivot of each branch into the vertex color and merges them into one mesh.
- Custom normals (based on the pivots) are used for the leaves illumination.
- Setting branch curvature.
- Game object swaying. 
- Implemented in Shader Graph.

![TreeAnimation](Screenshots/TreeAnimationShader.gif)