void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void SG_OneSeeThroughObject(float2 _ObjectPosition, float _Size, float _Smoothness, float _Opacity, float2 NDCPosition, out
float OutVector1_1)
{
    float _OpacityProperty = _Opacity;
    float _SmoothnessProperty = _Smoothness;
    float4 _ScreenPosition = float4(NDCPosition.xy, 0, 0);
    float2 _ObjectPositionProperty = _ObjectPosition;
    float2 _RemappedObjectPosition;
    
    Unity_Remap_float2(_ObjectPositionProperty, float2(0, 1), float2(0.5, -1.5), _RemappedObjectPosition);
    
    float2 _AddedObjectPosition;
    Unity_Add_float2((_ScreenPosition.xy), _RemappedObjectPosition, _AddedObjectPosition);
    float2 _OffsetObjectPosition;
    
    Unity_TilingAndOffset_float((_ScreenPosition.xy), float2(1, 1), _AddedObjectPosition, _OffsetObjectPosition);

    float2 _MultipliedObjectPosition;
    Unity_Multiply_float2_float2(_OffsetObjectPosition, float2(2, 2), _MultipliedObjectPosition);

    float2 _SubtractedObjectPosition;
    Unity_Subtract_float2(_MultipliedObjectPosition, float2(1, 1), _SubtractedObjectPosition);

    float _SizeProperty = _Size;
    float _ScreenRatio;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _ScreenRatio);
    
    float _FinalSize;
    Unity_Multiply_float_float(_SizeProperty, _ScreenRatio, _FinalSize);
    
    float2 _SizeVector = float2(_FinalSize, _SizeProperty);
    
    float2 _NormalizedPosition;
    Unity_Divide_float2(_SubtractedObjectPosition, _SizeVector, _NormalizedPosition);
    
    float _Length;
    Unity_Length_float2(_NormalizedPosition, _Length);
    
    float _OneMinusLength;
    Unity_OneMinus_float(_Length, _OneMinusLength);
    
    float _SaturatedDistance;
    Unity_Saturate_float(_OneMinusLength, _SaturatedDistance);
    
    float _SmoothstepValue;
    Unity_Smoothstep_float(float(0), _SmoothnessProperty, _SaturatedDistance, _SmoothstepValue);
    
    float _OpacityResult;
    Unity_Multiply_float_float(_OpacityProperty, _SmoothstepValue, _OpacityResult);
    
    float _FinalResult;
    Unity_OneMinus_float(_OpacityResult, _FinalResult);
    
    OutVector1_1 = _FinalResult;
}