module sphere;

import std.math : sqrt;

import ray : Ray;
import sceneobject : SceneObject;
import vector : Vector;

/** Three-dimensional sphere, defined by a center and radius. */
class Sphere : SceneObject
{
    Vector center;
    double radius;

    this(const Vector center, const double radius)
    {
        this.center = center;
        this.radius = radius;
    }

    override bool hit(const Ray ray) const
    {
        // implement sphere-ray intersection
        immutable Vector oc = ray.orig - center;
        immutable double a = ray.dir.dot(ray.dir),
            b = 2.0 * oc.dot(ray.dir),
            c = oc.dot(oc) - radius * radius,
            discriminant = b * b - 4.0 * a * c;
        if (discriminant < 0)
        {
            return false;
        }
        double numerator = -b - sqrt(discriminant);
        if (numerator > 0)
        {
            return true;
        }
        numerator = -b + sqrt(discriminant);
        if (numerator > 0)
        {
            return true;
        }
        return false;
    }
}

unittest
{
    Sphere s = new Sphere(Vector(0, 0, -2), 1);

    // ray pointing straight at center
    {
        immutable Ray r = Ray.fromTo( Vector( 0, 0, 0), Vector(0, 0, -1));
        assert(s.hit(r));
    }

    // ray pointing at point within sphere from "behind"
    {
        immutable Ray r = Ray.fromTo(Vector(1, 1, -3), Vector(0.5, 0.5, -1.5));
        assert(s.hit(r));
    }

    // ray pointing away from sphere
    {
        immutable Ray r = Ray.fromTo(Vector(0, 0, 0), Vector(0, 0, 1));
        assert(!s.hit(r));
    }
}