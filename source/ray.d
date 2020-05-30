module ray;

import vector : Vector;

/** Ray of light used to draw three-dimensional scenes. */
struct Ray
{
    Vector orig, dir;

    this(const Vector orig, const Vector dir)
    {
        this.orig = orig;
        this.dir = dir;
        this.dir.normalize();
    }

    static Ray fromTo(const Vector orig, const Vector dest)
    in
    {
        assert(orig != dest);
    }
    do
    {
        immutable Vector _dir = dest - orig;
        return Ray(orig, _dir);
    }
}

unittest
{
    import core.exception : AssertError;
    import std.exception : assertThrown;
    import std.math : approxEqual;

    // Check that a ray's length gets normalized
    immutable Ray r = Ray.fromTo(Vector(1, 1, 1), Vector(2, 2, 2));
    assert(approxEqual(r.dir.length(), 1));

    // Check that a ray with origin = destination, i.e. undefined direction, violates the method contract
    assertThrown!AssertError(Ray.fromTo(Vector(1, 1, 1), Vector(1, 1, 1)));
}