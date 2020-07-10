module scene.sphere;

import std.typecons : Nullable;

import geometry.ray : Ray;
import geometry.vector : Vector;
import geometry.sphere : Sphere;
import scene.material : Material;
import scene.sceneobject : SolidSceneObject;

class SphereSceneObject : SolidSceneObject
{
    Sphere sphere;

    this(const Material material, const Vector center, const double radius)
    {
        super(material);
        this.sphere = Sphere(center, radius);
    }

    override Nullable!Ray computeHit(const Ray ray) const
    {
        return sphere.hit(ray);
    }
}

/// Ray-sphere intersection
unittest
{
    import std.math : approxEqual;

    SphereSceneObject s = new SphereSceneObject(Material.matteWhite, Vector(0, 0, -2), 1);

    // ray pointing straight at center
    {
        const r = Ray.fromTo(Vector( 0, 0, 0), Vector(0, 0, -1)),
        hit = s.computeHit(r).get;
        // intersection point
        assert(approxEqual(hit.orig.x, 0));
        assert(approxEqual(hit.orig.y, 0));
        assert(approxEqual(hit.orig.z, -1));
        // surface normal
        assert(approxEqual(hit.dir.x, 0));
        assert(approxEqual(hit.dir.y, 0));
        assert(approxEqual(hit.dir.z, 1));
    }

    // ray pointing at point within sphere from "behind"
    {
        immutable Ray r = Ray.fromTo(Vector(1, 1, -3), Vector(0.5, 0.5, -1.5));
        assert(!s.computeHit(r).isNull);
    }

    // ray pointing away from sphere
    {
        immutable Ray r = Ray.fromTo(Vector(0, 0, 0), Vector(0, 0, 1));
        assert(s.computeHit(r).isNull);
    }
}