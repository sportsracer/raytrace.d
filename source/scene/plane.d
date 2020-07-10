module scene.plane;

import std.typecons : Nullable;

import geometry.plane : Plane;
import geometry.ray : Ray;
import geometry.vector : Vector;
import scene.material : Material;
import scene.sceneobject : SolidSceneObject;

class PlaneSceneObject : SolidSceneObject
{
    Plane plane;

    this(const Material material, const Plane plane)
    {
        super(material);
        this.plane = plane;
    }

    this(const Material material, const Vector point, const Vector normal)
    {
        const plane = Plane(Ray(point, normal));
        this(material, plane);
    }

    override Nullable!Ray computeHit(const Ray ray) const
    {
        return plane.hit(ray);
    }
}