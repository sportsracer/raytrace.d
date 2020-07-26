module scene.light.spherical;

import std.array : array;
import std.algorithm.iteration : map;
import std.typecons : Nullable;

import color.color : Color;
import geometry.ray : Ray;
import geometry.sphere : Sphere;
import geometry.vector : Vector;
import scene.light.light : Light, PointLight;

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

    override const(PointLight[]) samplePoints(in Vector at) const pure
    {
        return precomputedSamplePoints;
    }

    override Nullable!Ray computeHit(const Ray ray) const pure
    {
        return sphere.hit(ray);
    }
}

///
unittest
{
    const center = Vector(1, 1, 1),
    sphere = Sphere(center, 2),
    sphericalLight = new SphericalLight(sphere, Color.white, 1.0);

    const samplePoints = sphericalLight.samplePoints(Vector(0, 0, 0));
    assert(samplePoints.length > 0);
    foreach (PointLight samplePoint; samplePoints)
    {
        assert(samplePoint.color == Color.white);
        if (samplePoints.length > 1)
        {
            assert(samplePoint.intensity < sphericalLight.intensity);
        }
    }
}
