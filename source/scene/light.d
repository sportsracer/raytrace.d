module scene.light;

import std.array : array;
import std.algorithm.iteration : map;
import std.typecons : Nullable;

import color.color : Color;
import geometry.ray : Ray;
import geometry.sphere : Sphere;
import geometry.vector : Vector;
import scene.scene : Scene;
import scene.sceneobject : SceneObject;

/**
* A light represented by a single point in space. Volumetric lights are expressed as a collection of several point
* lights.
*/
struct PointLight
{
    Vector pos;
    Color color;
    double intensity;

    /// Calculate illumination of point `at` by this point light, assuming it's not obstructed/shadowed.
    Color illuminationAt(in Vector at) const pure
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

/// Base object for volumetric lights, defined as a collection of point lights.
abstract class Light : SceneObject
{
    Color color;
    double intensity;

    this(in Color color, double intensity) pure
    {
        this.color = color;
        this.intensity = intensity;
    }

    override Color illuminationAt(const Ray hit, const Ray ray, uint depth) const
    {
        return color * intensity;
    }

    /// Volumetric lights overload this method to return point lights on their surface
    // TODO Return a range instead?
    const(PointLight[]) samplePoints() const pure;
}

/// Spherical light, represented by point lights on its surface.
class SphericalLight : Light
{
    Sphere sphere;

    private PointLight[] precomputedSamplePoints;
    private immutable numSamples = 32;

    this(in Sphere sphere, in Color color, in double intensity)
    {
        super(color, intensity);
        this.sphere = sphere;
        this.precomputedSamplePoints = this.precomputeSamplePoints();
    }

    this(in Vector pos, double radius, in Color color, double intensity)
    {
        immutable sphere = Sphere(pos, radius);
        this(sphere, color, intensity);
    }

    private PointLight[] precomputeSamplePoints()
    {
        const Vector[] points = this.sphere.equidistantPoints(numSamples);
        // split this light's intensity equally among the point lights
        immutable sampleIntensity = intensity / points.length;
        alias createPointLight = point => PointLight(point, color, sampleIntensity);
        auto samplePoints = points.map!createPointLight;
        return samplePoints.array;
    }

    override const(PointLight[]) samplePoints() const pure
    {
        return precomputedSamplePoints;
    }

    override Nullable!Ray computeHit(const Ray ray) const pure
    {
        return sphere.hit(ray);
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