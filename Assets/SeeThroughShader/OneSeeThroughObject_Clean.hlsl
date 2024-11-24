void SG_OneSeeThroughObject(float2 _ObjectPosition, float _Size, float _Smoothness, float _Opacity, float2 NDCPosition, out
float OutVector1_1)
{
    float _OpacityProperty = _Opacity;
    float _SmoothnessProperty = _Smoothness;
    float4 _ScreenPosition = float4(NDCPosition.xy, 0, 0);
    float2 _ObjectPositionProperty = _ObjectPosition;
    float2 _RemappedObjectPosition;
    
    // Remap _ObjectPosition to a new range
    _RemappedObjectPosition = (_ObjectPositionProperty - float2(0, 1)) * (float2(0.5, -1.5) - float2(0, 1)) / (float2(1, 0) - float2(0, 1)) + float2(0.5, -1.5);
    
    // Add _ScreenPosition.xy and _RemappedObjectPosition
    float2 _AddedObjectPosition = _ScreenPosition.xy + _RemappedObjectPosition;

    // Apply tiling and offset
    float2 _OffsetObjectPosition = _AddedObjectPosition;

    // Multiply the offset position by 2
    float2 _MultipliedObjectPosition = _OffsetObjectPosition * float2(2, 2);

    // Subtract (1, 1) from the multiplied position
    float2 _SubtractedObjectPosition = _MultipliedObjectPosition - float2(1, 1);

    // Calculate screen ratio
    float _ScreenRatio = unity_OrthoParams.y / unity_OrthoParams.x;

    // Calculate the final size
    float _FinalSize = _Size * _ScreenRatio;
    
    // Create the size vector
    float2 _SizeVector = float2(_FinalSize, _Size);

    // Normalize the object position by dividing by size vector
    float2 _NormalizedPosition = _SubtractedObjectPosition / _SizeVector;
    
    // Calculate the length of the normalized position
    float _Length = length(_NormalizedPosition);
    
    // Calculate 1 minus the length
    float _OneMinusLength = 1.0 - _Length;
    
    // Saturate the result between 0 and 1
    float _SaturatedDistance = saturate(_OneMinusLength);
    
    // Apply smoothstep
    float _SmoothstepValue = smoothstep(0.0, _SmoothnessProperty, _SaturatedDistance);
    
    // Multiply opacity by smoothstep value
    float _OpacityResult = _OpacityProperty * _SmoothstepValue;
    
    // Calculate the final result as 1 minus opacity result
    float _FinalResult = 1.0 - _OpacityResult;
    
    // Output the final result
    OutVector1_1 = _FinalResult;
}
