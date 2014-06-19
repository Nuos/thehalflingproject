/* The Halfling Project - A Graphics Engine and Projects
 *
 * The Halfling Project is the legal property of Adrian Astley
 * Copyright Adrian Astley 2013 - 2014
 */

#ifndef OBJ_LOADER_DEMO_HLSL_UTIL_H
#define OBJ_LOADER_DEMO_HLSL_UTIL_H


// Converts a normalized cartesian direction vector
// to spherical coordinates.
float2 CartesianToSpherical(float3 cartesian) {
	float2 spherical;

	// atan2 is not defined for (0, 0)
	// Therefore, we need to explicitly define it ourselves
	[flatten]
	if (any(cartesian.xy)) {
		spherical.x = atan2(cartesian.y, cartesian.x);
	} else {
		spherical.x = 0.0f;
	}
	spherical.y = acos(cartesian.z);

	return spherical;
}

// Converts a spherical coordinate to a normalized
// cartesian direction vector.
float3 SphericalToCartesian(float2 spherical) {
	float2 sinValue, cosValue;

	// spherical.x = theta
	// spherical.y = phi

	sincos(spherical, sinValue, cosValue);

	return float3(cosValue.x * sinValue.y, sinValue.x * sinValue.y, cosValue.y);
}

// Converts a z-buffer depth to linear depth
float LinearDepth(in float zw, in float4x4 projectionMatrix) {
    return projectionMatrix._43 / (zw - projectionMatrix._33);
}

// Calculates position from a depth value + pixel coordinate
float3 PositionFromDepth(in float zw, in uint2 pixelCoord, in float2 displaySize, in float4x4 invViewProjection) {
    float2 cpos = (pixelCoord + 0.5f) / displaySize;
    cpos *= 2.0f;
    cpos -= 1.0f;
    cpos.y *= -1.0f;
    float4 positionWS = mul(float4(cpos, zw, 1.0f), invViewProjection);
    return positionWS.xyz / positionWS.w;
}

// Perturbs a pixel normal given a normal map sample and the tangent
float3 PerturbNormal(float3 pixelNormal, float3 normalMapSample, float3 tangent)
{
	// Uncompress each component from [0,1] to [-1,1].
	// Add a negative because negating is free and MAD is faster than MUL & SUB
	float3 normalizedSample = normalMapSample * 2.0f + -1.0f;

	// Build orthonormal basis.
	float3 T = normalize(tangent - dot(tangent, pixelNormal) * pixelNormal);
	float3 B = cross(pixelNormal, T);

	float3x3 TBN = float3x3(T, B, pixelNormal);

	// Transform from tangent space to world space.
	float3 perturbedNormal = mul(normalizedSample, TBN);

	return normalize(perturbedNormal);
}

float4x4 CreateMatrixFromCols(float4 c0, float4 c1, float4 c2, float4 c3) {
	return float4x4(c0.x, c1.x, c2.x, c3.x,
	                c0.y, c1.y, c2.y, c3.y,
	                c0.z, c1.z, c2.z, c3.z,
	                c0.w, c1.w, c2.w, c3.w);
}

float4x4 CreateMatrixFromRows(float4 r0, float4 r1, float4 r2, float4 r3) {
	return float4x4(r0, r1, r2, r3);
}

#endif