module scene;

import std.typecons : Nullable, Tuple;

import camera : Camera;
import color : Color;
import light : Light;
import ray : Ray;
import sceneobject : SceneObject, SolidSceneObject;

immutable renderDepth = 1;

/* Point and surface normal on a scene object */
alias Hit = Tuple!(SceneObject, "sceneObject", Ray, "intersection");

class Scene
{
    Camera camera;
    Light[] lights;
    SolidSceneObject[] objects;

    void addObject(Light light)
    {
        this.lights ~= light;
        light.scene = this;
    }

    void addObject(SolidSceneObject solidSceneObject)
    {
        this.objects ~= solidSceneObject;
        solidSceneObject.scene = this;
    }

    Color renderPoint(double x, double y) const
    {
        immutable Ray ray = camera.rayForPixel(x, y);
        return renderRay(ray, renderDepth);
    }

    Color renderRay(const Ray ray, uint depth, const SceneObject except = null) const
    {
        const closest = intersect(ray, except);
        if (!closest.isNull)
        {
            const Hit hit = closest.get;
            const SceneObject sceneObject = hit.sceneObject;
            return sceneObject.illuminationAt(hit.intersection, ray, depth);
        }

        return Color.black;
    }

    Nullable!Hit intersect(const Ray ray, const SceneObject except = null) const
    {
        Nullable!Hit closest;
        double closestDistance = double.max;

        void findClosestHit(const SceneObject object)
        {
            if (object == except)
            {
                return;
            }

            immutable hit = object.computeHit(ray);
            if (!hit.isNull)
            {
                immutable distance = (hit.get.orig - camera.origin).length2;
                if (closest.isNull || distance < closestDistance)
                {
                    // TODO It's not nice that I cast away const-ness here, is there a better way?
                    closest = Hit(cast(SceneObject)object, hit.get);
                    closestDistance = distance;
                }
            }
        }

        foreach (object; objects)
        {
            findClosestHit(object);
        }

        foreach (light; lights)
        {
            findClosestHit(light);
        }

        return closest;
    }

}