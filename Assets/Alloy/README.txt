Greetings!
Welcome to the Alloy Shader Framework Readme

Before using this shader set, there are a couple things you _must_ set up in your project. If you do not set up these options, you will get visual artifacts caused by broken math.

Setup Steps:

1. Open Edit->Project Settings->Player
2. Open the 'Other Settings' rollout
3. Set 'Color Space' to 'Linear'
4. If you want to use lots of dynamic lights, set 'Rendering Path' to 'Deferred Lighting'
5. Select your camera in your scene
6. Check the 'HDR' box
!!!SUPER IMPORTANT STEP!!!
7. Now save a scene, and CLOSE UNITY COMPLETELY
-This is necessary for the overwritten deferred shader to 'kick in' for the project.-
8. Open Unity and your project back up.
Now you're ready to play!

See the Alloy Documentation PDF for full usage details.

