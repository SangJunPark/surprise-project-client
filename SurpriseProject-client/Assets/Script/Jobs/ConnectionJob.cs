using Unity.Collections;
using Unity.Entities;
using Unity.Burst;
using Unity.Jobs;
using Unity.Mathematics;
using Unity.Transforms;
using UnityEngine;


struct IncrementByDeltaTimeJob : IJobParallelFor
{
    public NativeArray<float> values;
    public float deltaTime;

    public void Execute(int index)
    {
        float temp = values[index];
        temp += deltaTime;
        values[index] = temp;
    }
}