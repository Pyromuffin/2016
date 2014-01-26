
/////////////////////////////////////////////////////////////////////////////////
/// @file AlloyConfig.cginc
/// @brief Alloy's preprocessor definition switches to enable/disable features.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_CONFIG_CGINC
#define ALLOY_CONFIG_CGINC

// Switches
// These ones should be used in individual surface shaders, and are just here for
// documentation purposes.
//#define ALLOY_USE_TRANSLUCENCY

// Turns off features that assume linear space. 
// This path is not officially supported, but is here for the curious.
//#define ALLOY_USE_GAMMA_SPACE
//#define ALLOY_USE_PER_LIGHT_FRESNEL_IN_FORWARD_MODE
#define ALLOY_USE_FRESNEL_SPHERICAL_GAUSSIAN_APPROXIMATION
#define ALLOY_USE_BLINN_PHONG_SPHERICAL_GAUSSIAN_APPROXIMATION

#endif // ALLOY_CONFIG_CGINC