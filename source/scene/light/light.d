module scene.light.light;

import geometry.ray : Ray;
import geometry.vector : Vector;
import scene.color : Color;
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
    const(PointLight[]) samplePoints(in Vector at) const pure;
}


/// Point light
unittest
{
    immutable whiteLight = PointLight(Vector(0, 0, 0), Color.white, 10.0),
        colorNear = whiteLight.illuminationAt(Vector(1, 1, 1)),
        colorFar = whiteLight.illuminationAt(Vector(2, 2, 2));

    assert(colorNear.r + colorNear.g + colorNear.b > colorFar.r + colorFar.g + colorFar.b);
}

