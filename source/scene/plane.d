module scene.plane;

import std.typecons : Nullable;

import geometry.plane : Plane;
import geometry.ray : Ray;
import geometry.vector : Vector;
import scene.material : Material;
import scene.sceneobject : SolidSceneObject;

/// Infinite, two-dimensional plane.
class PlaneSceneObject : SolidSceneObject
{
    Plane plane;

    this(in Material material, in Plane plane) pure
    {
        super(material);
        this.plane = plane;
    }

    this(in Material material, in Vector point, in Vector normal) pure
    {
        const plane = Plane(Ray(point, normal));
        this(material, plane);
    }

    override Nullable!Ray computeHit(in Ray ray) const pure
    {
        return plane.hit(ray);
    }
}