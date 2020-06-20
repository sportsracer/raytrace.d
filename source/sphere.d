module sphere;

import std.math : sqrt;
import std.typecons : Nullable;

import material : Material;
import ray : Ray;
import sceneobject : SceneObject;
import vector : Vector;

/** Three-dimensional sphere, defined by a center and radius. */
class Sphere : SceneObject
{
    Vector center;
    double radius;

    this(const Material material, const Vector center, const double radius)
    {
        super(material);
        this.center = center;
        this.radius = radius;
    }

    private double intersectionDistance(const Ray ray) const
    {
        immutable Vector oc = ray.orig - center;
        immutable double a = ray.dir.dot(ray.dir),
            b = 2.0 * oc.dot(ray.dir),
            c = oc.dot(oc) - radius * radius,
            discriminant = b * b - 4.0 * a * c;
        if (discriminant >= 0)
        {
            foreach (numerator; [-b - sqrt(discriminant), -b + sqrt(discriminant)])
            {
                if (numerator > 0)
                {
                    return numerator / (2.0 * a);
                }
            }
        }
        return -1.0;
    }

    override Nullable!Ray hit(const Ray ray) const
    {
        Nullable!Ray intersection;
        immutable distance = intersectionDistance(ray);
        if (distance >= 0)
        {
            immutable Vector intersectionPoint = ray.orig + ray.dir * distance,
                normal = intersectionPoint - center;
            intersection = Ray(intersectionPoint, normal);
        }
        return intersection;
    }
}

unittest
{
    import std.math : approxEqual;

    Sphere s = new Sphere(Material.matteWhite, Vector(0, 0, -2), 1);

    // ray pointing straight at center
    {
        immutable Ray r = Ray.fromTo( Vector( 0, 0, 0), Vector(0, 0, -1)),
            hit = s.hit(r).get;
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
        assert(!s.hit(r).isNull);
    }

    // ray pointing away from sphere
    {
        immutable Ray r = Ray.fromTo(Vector(0, 0, 0), Vector(0, 0, 1));
        assert(s.hit(r).isNull);
    }
}