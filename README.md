# Road to Technical Artist

## <a name="contents">Contents</a>
| Solution  | Description | Key Techniques |
| --------- | ------ | ----------|
|      |        | |
| <a href="#beetle">Fresnel-like Effects</a><br/>天牛彩壳   | Fresnel Effect is the effect of differing reflectance on a surface depending on viewing angle, where as you approach the grazing angle more light is reflected. Hereby I create a waxing and polishing feeling with similar principles.  |1. Calculate the angle between the surface normal and the view direction. Use the cosine value(clamped to [0,1]) to sample a gradient ramp.<br/> 2. Adopt material captures to enrich view-dependent visual effects.   |
| <a href="#flame">Flame</a><br/>小火苗 |  A most common phenomenon with endless details. |1. Simulate the irregular combustion effects by: Sampling a noise texture with a constant speed and apply a smoothstep function to make the flame gradually disappear during the ascent process.<br/> 2. Smoothly increase the G-channel to differentiate inner and outer flames.<br/> 3. Always apply noise and gradient to provide more details.  4. Post-processing: Bloom|
|<a href="#sky">Sky Mirror</a><br/>天空之镜   | A dreamlike great lake scenario mainly based on planar reflection.      |1. Create an extra camera to implement planar reflection(with some blur effects).<br/> 2. Sample a bump texture in different directions and speeds, then combine them to imitate the ripples. <br/> 3. Again calculate Fresnel item to generate water surface view.(That is when you look nearly vertically downwards you'll see the lakebed, while when you look into the distance you can only see the reflection light.)<br/> 4. Supplement specular light where the sun shines based on Blinn-Phong model. |
|<a href="#dragon">Dragon Splatting</a><br/>蛟龙化水    | The solution name is inspired by the famous <i>'Gaussian Splatting'</i>. This solution focuses on physics simulation rather than rendering effects. You may refer to my <a href="https://github.com/DukeofCambridge/HKUST_Advanced_Digital_Design_Project">project</a>.|1. MPM algorithm.<br/> 2. Model representation conversion between point cloud and mesh.    | 

<!-- 突然想到，成为TA意味着我可以把我的心像风景都呈现出来，伴以故事和音乐  
灵魂：Realm of Archons  七元素  文明
沙漠的热浪效果
筑梦边境
终有一天希望人类做海洋的技术能达到极盗者那种程度
-->


<!-- Research Directions  -->
<!-- 1. Asset Creation(Model/Image/Audio/Animation) & Reconstruction
     2. 几何曲线建模 & CAD曲线/曲面重建 & 毛发、硬表面建模
     3. Meta Human
     4. 物理解算 Houdini Solver, 布料/流体/发丝模拟
     5. USD Plugins Development
     6. 动捕动画
     7. 传统几何处理
     8. Differentiable Rendering
     9. 渲染管线开发，移动端优化
-->

## Demonstration
<a name="beetle">Fresnel-like effects on a beetle</a> &nbsp; &nbsp; &nbsp;   Return to <a href="#contents">Contents</a>

https://github.com/DukeofCambridge/Road2Technical_Artist/assets/68137344/bc6c85da-1a73-446f-aaf1-7a07ad51bb85

<a name="flame">Flame effects</a> &nbsp; &nbsp; &nbsp;   Return to <a href="#contents">Contents</a>

https://github.com/DukeofCambridge/Road2Technical_Artist/assets/68137344/81945e5c-dd8c-4b6e-af11-56a1ea2f02cd

<a name="sky">Sky Mirror</a> &nbsp; &nbsp; &nbsp;   Return to <a href="#contents">Contents</a>


https://github.com/DukeofCambridge/Road2Technical_Artist/assets/68137344/2c2ddfbf-b06d-4df3-a3a9-50e8db41b6e1

<a name="dragon">Dragon Splatting</a> &nbsp; &nbsp; &nbsp;   Return to <a href="#contents">Contents</a>

https://github.com/DukeofCambridge/Road2Technical_Artist/assets/68137344/5645819c-a826-4033-8106-102629f5c7ca

