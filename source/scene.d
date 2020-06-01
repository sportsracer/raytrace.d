module scene;

import std.typecons : Nullable;

import camera : Camera;
import color : Color;
import light : PointLight;
import material : Material;
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
    PointLight lightSource;
    SceneObject[] objects;

    Color renderPoint(double x, double y) const
    {
        immutable Ray ray = camera.rayForPixel(x, y);
        return renderRay(ray, 1); // TODO parametrize render depth
    }

    Color renderRay(const Ray ray, uint depth, const SceneObject except = null) const
    {
        auto closest = intersect(ray, except);
        if (!closest.isNull)
        {
            return illuminationAt(ray, closest.get, depth);
        }

        return Color.black;
    }

    Nullable!SceneObjectIntersection intersect(const Ray ray, const SceneObject except = null) const
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

    Color illuminationAt(const Ray ray, const SceneObjectIntersection intersection, uint depth) const
    {
        Color color = Color.black;
        const Material material = intersection.sceneObject.material;

        // compute illumination
        immutable Ray toLight = Ray.fromTo(intersection.point, lightSource.pos);
        bool shadowed = false;
        auto closest = intersect(toLight, intersection.sceneObject);
        if (!closest.isNull)
        {
            immutable double distanceToLight = (lightSource.pos - intersection.point).length(),
                distanceToBlockingObject = (closest.get.point - intersection.point).length();
            if (distanceToBlockingObject < distanceToLight)
            {
                shadowed = true;
            }
        }

        // unless light from source is blocked, compute illumation from angle of surface normal to light
        if (!shadowed)
        {
            immutable double angle = toLight.dir.angleWith(intersection.normal);
            immutable Color diffuse = material.diffuseColor(angle),
                illumination = lightSource.illuminationAt(intersection.point);
            color = color + (diffuse * illumination);
        }

        // propagate more rays for reflection
        if (depth > 0)
        {
            if (material.reflective > 0)
            {
                immutable Vector reflectedDirection = ray.dir.reflect(intersection.normal);
                immutable Ray reflectedRay = Ray(intersection.point, reflectedDirection);
                immutable Color reflection = renderRay(reflectedRay, depth - 1, intersection.sceneObject);
                color = color + reflection * material.reflective;
            }
        }

        return color;
    }

}