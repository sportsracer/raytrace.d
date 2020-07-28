module scene.light.directional;

import std.typecons : Nullable;

import geometry.ray : Ray;
import geometry.vector : Vector;
import scene.color : Color;
import scene.light.light : Light, PointLight;

/// Light source which casts parallel light rays; simulates a far-away light source such as the sun.
class DirectionalLight : Light
{
    private {
        immutable distance = 10.0;
        Vector direction;
    }

    this(in Vector direction, in Color color, in double intensity) pure
    {
        super(color, intensity);
        this.direction = direction;
        this.direction.normalize();
    }

    override Nullable!Ray computeHit(const Ray ray) const pure
    {
        Nullable!Ray hit;
        return hit;
    }

    override const(PointLight[]) samplePoints(in Vector at) const pure
    {
        immutable lightPos = at - direction * distance;
        return [PointLight(lightPos, color, intensity)];
    }

}

///
unittest
{
    const light = new DirectionalLight(Vector(0, 1, 0), Color.white, 1.0);

    // Directional light is not visible itself in scene, i.e. no intersection with any ray
    immutable hit = light.computeHit(Ray(Vector(0, 0, 0), Vector(0, 1, 0)));
    assert(hit.isNull);

    // Check that two different points are illuminated at same strength
    Color computeIlluminationAt(in Vector at)
    {
        const samplePoints = light.samplePoints(at);
        assert(samplePoints.length > 0);
        const PointLight pointLight = samplePoints[0];
        return pointLight.illuminationAt(at);
    }

    immutable illumination1 = computeIlluminationAt(Vector(1, -2, 5)),
        illumination2 = computeIlluminationAt(Vector(-5, -3, 2));
    assert(illumination1 == illumination2);
}