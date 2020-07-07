module sceneobject;

import std.typecons : Nullable;

import color : Color;
import light : Light, PointLight;
import material : Material;
import ray : Ray;
import scene : Scene;
import vector : Vector;

/* Point and surface normal on a scene object */
struct Hit {
    const SceneObject sceneObject;
    const Ray intersection;

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

/** Object which can be rendered to a raytraced scene. */
abstract class SceneObject
{
    Scene scene;

    /** Return a ray consisting of intersection point plus surface normal if `r` hits this object's geometry, null
    otherwise. */
    Nullable!Hit computeHit(const Ray r) const;

    Color illuminationAt(const Hit hit, const Ray ray, uint depth) const;
}

abstract class SolidSceneObject : SceneObject
{
    const Material material;

    this(const Material material)
    {
        this.material = material;
    }

    override Color illuminationAt(const Hit hit, const Ray ray, uint depth) const
    {
        Color color = Color.black;

        // compute illumination
        foreach (const Light light; scene.lights)
        {
            foreach (PointLight lightSource; light.samplePoints)
            {
                immutable Ray toLight = Ray.fromTo(hit.point, lightSource.pos);
                bool shadowed = false;
                const closest = scene.intersect(toLight, light);
                if (!closest.isNull && closest.get.sceneObject != this)
                {
                    immutable double distanceToLight = (lightSource.pos - hit.point).length2,
                        distanceToBlockingObject = (closest.get.point - hit.point).length2;
                    if (distanceToBlockingObject < distanceToLight)
                    {
                        shadowed = true;
                    }
                }

                // unless light from source is blocked, compute illumation from angle of surface normal to light
                if (!shadowed)
                {
                    immutable double angle = toLight.dir.angleWith(hit.normal);
                    immutable Color diffuse = material.diffuseColor( angle),
                        illumination = lightSource.illuminationAt(hit.point);
                    color = color + (diffuse * illumination);
                }
            }
        }

        // propagate more rays for reflection
        if (depth > 0)
        {
            if (material.reflective > 0)
            {
                immutable Vector reflectedDirection = ray.dir.reflect(hit.normal);
                immutable Ray reflectedRay = Ray(hit.point, reflectedDirection);
                immutable Color reflection = scene.renderRay(reflectedRay, depth - 1, this);
                color = color + reflection * material.reflective;
            }
        }

        return color;
    }
}