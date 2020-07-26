module scene.sceneobject;

import std.typecons : Nullable;

import color.color : Color;
import geometry.ray : Ray;
import geometry.vector : Vector;
import scene.light.light : Light, PointLight;
import scene.material : Material;
import scene.scene : Scene;

/// Object which can be rendered to a raytraced scene.
abstract class SceneObject
{
    Scene scene;

    /** Return a ray consisting of intersection point plus surface normal if `r` hits this object's geometry, null
    otherwise. */
    Nullable!Ray computeHit(in Ray r) const pure;

    /**
    * Calculate visible color at a point on the surface of this object.
    *
    * Params:
    *   hit = Point on surface of this object, and surface normal
    *   ray = Ray that is being traced; for effects that depend on viewing direction, such as reflection
    *   depth = Current rendering depth; rendering aborts when this value reaches zero
    */
    Color illuminationAt(in Ray hit, in Ray ray, uint depth) const pure;
}

abstract class SolidSceneObject : SceneObject
{
    Material material;

    this(in Material material) pure
    {
        this.material = material;
    }

    override Color illuminationAt(in Ray hit, in Ray ray, uint depth) const pure
    {
        Color color = Color.black;

        // compute illumination
        foreach (const Light light; scene.lights)
        {
            foreach (PointLight lightSource; light.samplePoints(hit.orig))
            {
                immutable Ray toLight = Ray.fromTo(hit.orig, lightSource.pos);
                bool shadowed = false;
                const closest = scene.intersect(toLight, light, this);
                if (!closest.isNull)
                {
                    immutable double distanceToLight = (lightSource.pos - hit.orig).length2,
                        distanceToBlockingObject = (closest.get.intersection.orig - hit.orig).length2;
                    if (distanceToBlockingObject < distanceToLight)
                    {
                        shadowed = true;
                    }
                }

                // unless light from source is blocked, compute illumation from angle of surface normal to light
                if (!shadowed)
                {
                    immutable double angle = toLight.dir.angleWith(hit.dir);
                    immutable Color diffuse = material.diffuseColor(angle),
                        illumination = lightSource.illuminationAt(hit.orig);
                    color = color + (diffuse * illumination);
                }
            }
        }

        // propagate more rays for reflection
        if (depth > 0)
        {
            if (material.reflective > 0)
            {
                immutable Vector reflectedDirection = ray.dir.reflect(hit.dir);
                immutable Ray reflectedRay = Ray(hit.orig, reflectedDirection);
                immutable Color reflection = scene.renderRay(reflectedRay, depth - 1, this);
                color = color + reflection * material.reflective;
            }
        }

        return color;
    }
}