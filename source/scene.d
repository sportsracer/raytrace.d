module scene;

import std.typecons : Nullable;

import camera : Camera;
import color : Color;
import ray : Ray;
import sceneobject : SceneObject;
import vector : Vector;

// Point and surface normal on a scene object
struct SceneObjectIntersection {
    const {
        SceneObject sceneObject;
        Ray intersection;
    }

    // convenience accessors
    Vector point() const
    {
        return intersection.orig;
    }

    Vector normal() const
    {
        return intersection.dir;
    }
}

class Scene
{
    Camera camera;
    Vector lightSource;
    SceneObject[] objects;

    Color renderPoint(double x, double y) const
    {
        immutable Ray ray = camera.rayForPixel(x, y);

        auto closest = intersect(ray);
        if (!closest.isNull)
        {
            return illuminationAt(closest.get);
        }

        return Color.black;
    }

    Nullable!SceneObjectIntersection intersect(const Ray ray) const
    {
        return intersect(ray, null);
    }

    Nullable!SceneObjectIntersection intersect(const Ray ray, const SceneObject except) const
    {
        Nullable!SceneObjectIntersection closest;
        double closestDistance = double.max;

        foreach (object; objects)
        {
            if (object == except)
            {
                continue;
            }
            immutable auto hit = object.hit(ray);
            if (!hit.isNull)
            {
                immutable double distance = (hit.get.orig - camera.origin).length();
                if (closest.isNull || distance < closestDistance)
                {
                    closest = SceneObjectIntersection(object, hit.get);
                    closestDistance = distance;
                }
            }
        }
        return closest;
    }

    Color illuminationAt(const SceneObjectIntersection intersection) const
    {
        immutable Ray toLight = Ray.fromTo(intersection.point, lightSource);

        auto closest = intersect(toLight, intersection.sceneObject);
        if (!closest.isNull)
        {
            immutable double distanceToLight = (lightSource - intersection.point).length(),
                distanceToBlockingObject = (closest.get.point - intersection.point).length();
            if (distanceToBlockingObject < distanceToLight)
            {
                return Color.black;
            }
        }

        // compute illumation from angle of surface normal to light
        immutable angle = toLight.dir.angleWith(intersection.normal);
        auto material = intersection.sceneObject.material;
        return material.diffuseColor(angle);
    }

}