module geometry.plane;

import std.typecons : Nullable;

import geometry.ray : Ray;
import geometry.vector : Vector;

/// A plane defined by a point on the plane, and a surface normal. Extends infinitely in all directions.
struct Plane
{
    Ray pointNormal;

    /// Returns `Ray(intersection, surfaceNormal)` in case `ray` intersects this plane, and null otherwise
    Nullable!Ray hit(in Ray ray) const pure
    {
        Nullable!Ray hit;
        immutable denom = pointNormal.dir.dot(ray.dir);
        if (denom != 0)
        {
            immutable planeToRay = pointNormal.orig - ray.orig,
                t = planeToRay.dot(pointNormal.dir) / denom;

            if (t > 0)
            {
                immutable intersection = ray.orig + ray.dir * t;
                hit = Ray(intersection, pointNormal.dir);
            }
        }
        return hit;
    }
}

/// Ray-plane intersection
unittest
{
    import std.math : approxEqual;

    immutable plane = Plane(Ray(Vector(0, 1, 0), Vector(0, -1, 0)));

    // ray pointing away from plane
    {
        immutable ray = Ray(Vector(0, 0, 0), Vector(0, -1, 0)),
            hit = plane.hit(ray);
        assert(hit.isNull);
    }

    // ray pointing at front of plane
    {
        immutable pointInPlane = Vector(0, 1, 0),
            ray = Ray.fromTo(Vector(0, 0, 0), pointInPlane),
            hit = plane.hit(ray);
        assert(!hit.isNull);
        assert(approxEqual( hit.get.orig.x, pointInPlane.x));
        assert(approxEqual( hit.get.orig.y, pointInPlane.y));
        assert(approxEqual(hit.get.orig.z, pointInPlane.z));
    }

    // ray pointing at back of plane
    {
        immutable pointInPlane = Vector(-2, 1, 3),
            ray = Ray.fromTo(Vector(0, 2, 0), pointInPlane),
            hit = plane.hit(ray);
        assert(!hit.isNull);
    }

}