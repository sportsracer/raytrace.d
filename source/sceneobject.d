module sceneobject;

import std.typecons : Nullable;

import material : Material;
import ray : Ray;

/** Object which can be rendered to a raytraced scene. */
abstract class SceneObject
{
    const Material material;

    this(const Material material)
    {
        this.material = material;
    }

    /** Return a ray consisting of intersection point plus surface normal if `r` hits this object's geometry, null
    otherwise. */
    abstract Nullable!Ray hit(const Ray r) const;
}