module scene;

import std.math : PI_2;
import std.typecons : Nullable;

import camera : Camera;
import ray : Ray;
import sceneobject : SceneObject;
import vector : Vector;

class Scene
{
    Camera camera;
    Vector lightSource;
    SceneObject[] objects = [];

    Nullable!Ray intersect(const Ray ray) const
    {
        Nullable!Ray closest;
        double closestDistance = double.max;

        foreach (object; objects)
        {
            immutable auto hit = object.hit(ray);
            if (!hit.isNull)
            {
                immutable double distance = (hit.get.orig - camera.origin).length();
                if (closest.isNull || distance < closestDistance)
                {
                    closest = hit;
                    closestDistance = distance;
                }
            }
        }
        return closest;
    }

    double renderPoint(double x, double y) const
    {
        immutable Ray ray = camera.rayForPixel(x, y);

        auto closest = intersect(ray);
        if (!closest.isNull)
        {
            return illuminationAt(closest.get);
        }

        return 0.0;
    }

    double illuminationAt(const Ray pointNormal) const
    {
        immutable Ray toLight = Ray.fromTo(pointNormal.orig, lightSource);

        auto closest = intersect(toLight);
        if (!closest.isNull)
        {
            immutable double distanceToLight = (lightSource - pointNormal.orig).length(),
                distanceToBlockingObject = (closest.get.orig - pointNormal.orig).length();
            // TODO Find more elegant solution to objects not blocking their own light
            if (distanceToBlockingObject > 0.001 && distanceToBlockingObject < distanceToLight)
            {
                return 0.0;
            }
        }

        // compute illumation from angle of surface normal to light
        immutable angle = toLight.dir.angleWith(pointNormal.dir);
        if (angle > PI_2)
        {
            return 0.0;
        }
        return 1.0 - angle / PI_2;
    }

}