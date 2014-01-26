
/////////////////////////////////////////////////////////////////////////////////
/// @file AlloyUtils.cginc
/// @brief Alloy's utility functions and constants that can be used separately.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_UTILS_CGINC
#define ALLOY_UTILS_CGINC

#include "AlloyConfig.cginc"

/// A value close to zero.
/// This is used for preventing NaNs in cases where you can divide by zero.
#define ALLOY_EPSILON 1e-6f

/// A convenient way to multiply a value with itself.
half AlloySquared(half x) {
	return x * x;
}

/// A convenient way to multiply a value with itself.
half3 AlloySquared(half3 x) {
	return x * x;
}

/// A convenient way to multiply a value with itself twice.
half AlloyCubed(half x) {
	return x * x * x;
}

/// A convenient way to multiply a value with itself twice.
half3 AlloyCubed(half3 x) {
	return x * x * x;
}

/// Converts a value from gamma space to linear-space. 
/// This is used for cases when you have a color scaling factor, so that it can
/// have a perceptually linear gain in intensity. 
/// @param	value	Gamma-space value.
/// @return			Linear-space value.
half AlloyDeGamma(half value) {
#ifdef ALLOY_USE_GAMMA_SPACE
	return value;
#else
	// Quick and dirty approximation to pow(value, 2.2).
	return AlloySquared(value);
#endif
}

/// Converts a value from gamma space to linear-space. 
/// You should not need to use this, since Unity already automatically converts
/// colors from gamma space to linear space. 
/// @param	value	Gamma-space value.
/// @return			Linear-space value.
half3 AlloyDeGamma(half3 value) {
#ifdef ALLOY_USE_GAMMA_SPACE
	return value;
#else
	// Quick and dirty approximation to pow(value, 2.2).
	return AlloySquared(value);
#endif
}

/// Calculates the luminance of linear-space colors.
/// @param	color	Linear-space color.
/// @return			Linear-space luminance of the color.
half AlloyLinearLuminance(half3 color) {
#ifdef ALLOY_USE_GAMMA_SPACE
	return dot(color, half3(0.3h, 0.59h, 0.11h));
#else
	return dot(color, half3(0.2126h, 0.7152h, 0.0722h));
#endif
}

/// Calculates the chromaticity of linear-space colors.
/// @param	color	Linear-space color.
/// @return			Linear-space chromaticity of the color.
half3 AlloyLinearChromaticity(half3 color) {
	return color / (AlloyLinearLuminance(color) + ALLOY_EPSILON);
}

/// Used to calculate a rim light effect.
/// @param	rimTint 		Color of the rim light.
/// @param	rimIntensity	Intensity of the rim light.
/// @param	rimPower		Scales the spread of the rim light.
/// @param	dotNE			Dot product of the normal with the eye vector.
/// @return 				Rim lighting.
half3 AlloyRimLight(half3 rimTint, half rimIntensity, half rimPower, half dotNE) {
	return rimTint * (rimIntensity * pow(1.0h - dotNE, rimPower));
}

#endif // ALLOY_UTILS_CGINC
