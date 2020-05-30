module sceneobject;

import std.typecons : Nullable;

import ray : Ray;

/** Object which can be rendered to a raytraced scene. */
abstract class SceneObject
{
    /** Return a ray consisting of intersection point plus surface normal if `r` hits this object's geometry, null
    otherwise. */
    abstract Nullable!Ray hit(const Ray r) const;
}