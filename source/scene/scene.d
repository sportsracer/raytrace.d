module scene.scene;

import std.algorithm.searching : any;
import std.range : chain;
import std.typecons : Nullable, Tuple;

import color.color : Color;
import geometry.ray : Ray;
import geometry.vector : Vector;
import scene.camera : Camera;
import scene.light.light : Light;
import scene.sceneobject : SceneObject, SolidSceneObject;

// How many rays are cast recursively?
immutable renderDepth = 2;

/// Point and surface normal on a scene object.
alias Hit = Tuple!(SceneObject, "sceneObject", Ray, "intersection");

/// A collection of three-dimensional lights and objects which can be rendered, and a camera representing a viewpoint.
class Scene
{
    Camera camera;
    Light[] lights;
    SolidSceneObject[] objects;

    /// Add a light to this scene.
    void addObject(Light light) pure
    {
        this.lights ~= light;
        light.scene = this;
    }

    /// Add a solid object to this scene.
    void addObject(SolidSceneObject solidSceneObject) pure
    {
        this.objects ~= solidSceneObject;
        solidSceneObject.scene = this;
    }

    /// Render color for ray representing the coordinates (x, y) in the camera frustum.
    Color renderPoint(double x, double y) const pure
    {
        immutable ray = camera.rayForPixel(x, y);
        return renderRay(ray, renderDepth);
    }

    /**
    * Render color for `ray`.
    *
    * Params:
    *   ray = Ray representing line of sight, either originating from camera origin, or somewhere else in scene
    *       e.g for reflections
    *   depth = Remaining recursive render depth; this gets decreased for recursively cast rays, and stops at zero.
    *   skipObject = Don't render this object; used for rays originating on surface of an object, to avoid
    *       self-collision aka "surface acne"
    */
    Color renderRay(in Ray ray, uint depth, in SceneObject skipObject = null) const pure
    {
        const closest = intersect(ray, skipObject);
        if (!closest.isNull)
        {
            const Hit hit = closest.get;
            const Ray intersection = hit.intersection;
            const SceneObject sceneObject = hit.sceneObject;
            return sceneObject.illuminationAt(intersection, ray, depth);
        }
        return Color.black;
    }

    /// Return the closest intersection with a scene object, or null if there is none.
    Nullable!Hit intersect(in Ray ray, in SceneObject[] skipObjects ...) const pure
    {
        Nullable!Hit closest;
        double closestDistance = double.max;

        foreach (object; chain(objects, lights))
        {
            alias isThisObject = (skipObject) => (skipObject is object);
            if (any!isThisObject(skipObjects))
            {
                continue;
            }

            immutable hit = object.computeHit(ray);
            if (!hit.isNull)
            {
                immutable Vector rayToIntersection = hit.get.orig - ray.orig;
                immutable double distance = rayToIntersection.length2;
                if (closest.isNull || distance < closestDistance)
                {
                    // TODO It's not nice that I cast away const-ness here, is there a better way?
                    closest = Hit(cast(SceneObject)object, hit.get);
                    closestDistance = distance;
                }
            }
        }

        return closest;
    }

}
