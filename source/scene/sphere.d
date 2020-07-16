module scene.sphere;

import std.typecons : Nullable;

import geometry.ray : Ray;
import geometry.vector : Vector;
import geometry.sphere : Sphere;
import scene.material : Material;
import scene.sceneobject : SolidSceneObject;

/// Sphere, defined by center and radius.
class SphereSceneObject : SolidSceneObject
{
    Sphere sphere;

    this(in Material material, in Vector center, double radius) pure
    {
        super(material);
        this.sphere = Sphere(center, radius);
    }

    override Nullable!Ray computeHit(in Ray ray) const pure
    {
        return sphere.hit(ray);
    }
}