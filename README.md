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

## Bling Phong With Lighting, Shadows and Transparency
### Features in addition to default Blinn Phong shader:
- Lighting
- Shadows (receive and cast)
- Transparency (blend + cutout)
- Front, Back, Double sided rendering modes

![Blinn-Phong Transparent3](./Screenshots/BlinnPhongTransparent3.png)
![Blinn-Phong Transparent3](./Screenshots/BlinnPhongTransparent1.gif "Cutout transparency")
![Blinn-Phong Transparent3](./Screenshots/BlinnPhongTransparent2.gif "Blend transparency")

##PBR
### Features:
- Albedo, Normal, Metallic, Smoothness, Specular, Emission maps supporting
- Parallax mapping
- Specular/Metallic setup workflow
- Texture Channel Packing

![PBR5](./Screenshots/ParallaxMapping.gif)
![PBR3](./Screenshots/PBR3.png)
![PBR4](./Screenshots/PBR4.png)
![PBR1](./Screenshots/PBR1.png)
![PBR2](./Screenshots/PBR2.png)

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