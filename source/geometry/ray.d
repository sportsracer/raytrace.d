module geometry.ray;

import geometry.vector : Vector;

/// Ray of light used to draw three-dimensional scenes, defined by an origin and a normalized direction.
struct Ray
{
    Vector orig, dir;

    this(in Vector orig, in Vector dir) pure
    {
        this.orig = orig;
        this.dir = dir;
        this.dir.normalize();
    }

    static Ray fromTo(in Vector orig, in Vector dest) pure
    in
    {
        assert(orig != dest);
    }
    do
    {
        immutable _dir = dest - orig;
        return Ray(orig, _dir);
    }
}

unittest
{
    import core.exception : AssertError;
    import std.exception : assertThrown;

    // Check that a ray's length gets normalized
    immutable r = Ray.fromTo(Vector(1, 1, 1), Vector(2, 2, 2));
    assert(r.dir.isNormalized());

    // Check that a ray with origin = destination, i.e. undefined direction, violates the method contract
    assertThrown!AssertError(Ray.fromTo(Vector(1, 1, 1), Vector(1, 1, 1)));
}