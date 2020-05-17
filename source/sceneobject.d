module sceneobject;

import ray : Ray;

/** Object which can be rendered to a raytraced scene. */
abstract class SceneObject
{
    abstract bool hit(const Ray r) const;
}