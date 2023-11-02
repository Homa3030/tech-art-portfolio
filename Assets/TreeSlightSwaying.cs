using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TreeSlightSwaying : MonoBehaviour
{
    [SerializeField][Range(0, 90)] private float _minAngleDegrees;
    [SerializeField][Range(0, 90)] private float _maxAngleDegrees;
    [SerializeField] private float _speed;
    [SerializeField] private AnimationCurve _curve;
    private Quaternion _minRotationWorld;
    private Quaternion _maxRotationWorld;
    private float _phase;

    void Start()
    {
        float angle = Random.Range(_minAngleDegrees, _maxAngleDegrees);
        float axisAngle = Random.Range(0, Mathf.PI * 2);
        _phase = Random.Range(0f, 1f);

        var axis = new Vector3(Mathf.Cos(axisAngle), 0, Mathf.Sin(axisAngle));
        var maxRotation = Quaternion.AngleAxis(angle, axis);
        var minRotation = Quaternion.AngleAxis(-angle, axis);

        Quaternion startRotation = transform.rotation;
        _maxRotationWorld = maxRotation * startRotation;
        _minRotationWorld = minRotation * startRotation;
    }

    void Update()
    {
        float t = Time.time * _speed;
        t = Mathf.PingPong(t + _phase, 1);
        t = _curve.Evaluate(t);

        Quaternion currentRotation = Quaternion.Slerp(_minRotationWorld, _maxRotationWorld, t);
        transform.rotation = currentRotation;
    }
}
