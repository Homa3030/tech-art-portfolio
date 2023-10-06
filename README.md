# Tech Art Portfolio
>Project uses Universal Render Pipeline

## Blinn Phong shader
### Features
- Albedo: Color and Texture
- Texture: Tilling and Offset
- Diffuse
- Specular

![Bling-Phong1](./Screenshots/BlinnPhong1.jpg "Bling-Phong shader")
![Bling-Phong2](./Screenshots/BlinnPhong2.jpg "Bling-Phong shader")

## Blinn Phong shader with texture rotation
### Features
- Albedo: Color and Texture
- Texture: Tilling/Offset and rotation round center
- Diffuse
- Specular

![Bling-Phong texture rotation](./Screenshots/TextureRotation.gif "Texture rotation")

## Bling Phong With Shadows and Transparency
### Features in addition to default Blinn Phong shader:
- Shadows (receive and cast)
- Transparency (blend + cutout)
- Front, Back, Double sided rendering modes

![Blinn-Phong Transparent3](./Screenshots/BlinnPhongTransparent3.png)
![Blinn-Phong Transparent3](./Screenshots/BlinnPhongTransparent1.gif "Cutout transparency")
![Blinn-Phong Transparent3](./Screenshots/BlinnPhongTransparent2.gif "Blend transparency")

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

## Channel Packer Editor
### Feature:
- Packs several masks(up to 4) into one RGBA mask.

Example: Metallic and Smoothness masks are packed into one mask
![ChannelPacker1](./Screenshots/ChannelPacker1.png "Editor")
![ChannelPacker3](./Screenshots/ChannelPacker3.png "Red Channel" )
![ChannelPacker2](./Screenshots/ChannelPacker2.png "Green Channel")
![ChannelPacker4](./Screenshots/ChannelPacker4.png "Blue Channel")
![ChannelPacker5](./Screenshots/ChannelPacker5.png "RGB Channel")

## Toon Shader
### Features
- Albedo: Color and Texture (configurable shadow color and intensity)
- Texture: Tilling and Offset
- Diffuse (configurable smoothness and threshold)
- Specular (configurable smoothness and threshold)

![ToonShader](Screenshots/ToonShader.gif)

## CircleOfNthPower
### Features
- Plots the [squircle](https://en.wikipedia.org/wiki/Squircle) with the particular power. 

![CircleOfNthPower](Screenshots/CircleOfNthPower.gif)

## Instancing
### Features
- Rendering 1000 cubes with random rotation, scale and color using instancing.

![Instancing](Screenshots/Instancing.jpg)

DrawCalls:

![Instancing](Screenshots/Instancing_DrawCall1.jpg)
![Instancing](Screenshots/Instancing_DrawCall2.jpg)

## Smoke With Distortion
### Features:
- Distortion uses opaque texture

![Smoke With Distortion](Screenshots/SmokeWithDistortion.gif)

## Triplanar Mapping
### Features:
- Albedo blending 
- Normal map blending (UDN)
- Configurable blend sharpness
- Normal strength (per texture) 

![Triplanar Shader](Screenshots/TriplanarShader.gif)

## Triplanar Grass Effect (Shader Graph)
### Features:
- Normal direction-based blending between rock and grass textures
- Configurable threshold and smoothness of the rock to grass transition

![Triplanar Grass Effect](Screenshots/TriplanarGrassEffect.gif)

## Outline
### Features:
- Implemented as URP Render Feature
- Sobel filter for color, depth and normals

![Outline](Screenshots/Outline.png)