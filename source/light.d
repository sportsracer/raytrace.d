module light;

import std.typecons : Nullable;

import color : Color;
import ray : Ray;
import scene : Scene;
import sceneobject : Hit, SceneObject;
import sphere : Sphere;
import vector : Vector;

/**
* A light represented by a single point in space. Volumetric lights are expressed as a collection of several point
* lights.
*/
struct PointLight
{
    Vector pos;
    Color color;
    double intensity;

    Color illuminationAt(const Vector at) const
    {
        if (pos == at)
        {
            return color;
        }
        immutable lightDir = at - pos,
            distanceSquared = lightDir.length2;
        return color * (intensity / distanceSquared);
    }
}

/** Base object for volumetric lights, defined as a collection of point lights. */
abstract class Light : SceneObject
{
    const(PointLight[]) samplePoints() const;
}

class SphericalLight : Light
{
    Sphere sphere;
    Color color;
    double intensity;

    private PointLight[] precomputedSamplePoints;

    immutable numSamples = 32;

    this(const Sphere sphere, const Color color, double intensity)
    {
        this.sphere = sphere;
        this.color = color;
        this.intensity = intensity;

        this.precomputedSamplePoints = this.precomputeSamplePoints();
    }

    this(const Vector pos, double radius, const Color color, double intensity)
    {
        const sphere = Sphere(pos, radius);
        this(sphere, color, intensity);
    }

    private PointLight[] precomputeSamplePoints()
    {
        const Vector[] points = this.sphere.equidistantPoints(numSamples);
        immutable sampleIntensity = intensity / points.length;
        PointLight[] samplePoints;
        foreach (point; points)
        {
            samplePoints ~= PointLight(point, color, sampleIntensity);
        }
        return samplePoints;
    }

    override const(PointLight[]) samplePoints() const
    {
        return precomputedSamplePoints;
    }

    override Nullable!Hit computeHit(const Ray ray) const
    {
        Nullable!Hit hit;
        auto intersection = sphere.hit(ray);
        if (!intersection.isNull)
        {
            hit = Hit(this, intersection.get);
        }
        return hit;
    }

    // TODO move to super type
    override Color illuminationAt(const Hit hit, const Ray ray, uint depth) const
    {
        return color * intensity;
    }

}

/// Point light
unittest
{
    immutable whiteLight = PointLight(Vector(0, 0, 0), Color.white, 10.0),
        colorNear = whiteLight.illuminationAt(Vector(1, 1, 1)),
        colorFar = whiteLight.illuminationAt(Vector(2, 2, 2));

    assert(colorNear.r + colorNear.g + colorNear.b > colorFar.r + colorFar.g + colorFar.b);
}

/// Spherical light
unittest
{
    const center = Vector(1, 1, 1),
        sphere = Sphere(center, 2),
        sphericalLight = new SphericalLight(sphere, Color.white, 1.0);

    foreach (PointLight samplePoint; sphericalLight.samplePoints)
    {
        assert(samplePoint.color == Color.white);
        assert(samplePoint.intensity < sphericalLight.intensity);
    }
}