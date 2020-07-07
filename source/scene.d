module scene;

import std.typecons : Nullable;

import camera : Camera;
import color : Color;
import light : Light;
import material : Material;
import ray : Ray;
import sceneobject : Hit, SceneObject, SolidSceneObject;
import vector : Vector;

immutable renderDepth = 1;

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
            return hit.sceneObject.illuminationAt(hit, ray, depth);
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

            const hit = object.computeHit(ray);
            if (!hit.isNull)
            {
                immutable distance = (hit.get.point - camera.origin).length2;
                if (closest.isNull || distance < closestDistance)
                {
                    closest = Hit(object, hit.get.intersection);
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