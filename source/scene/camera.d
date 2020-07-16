module scene.camera;

import geometry.ray : Ray;
import geometry.vector : Vector;

/** Representation of a view frustrum = camera. */
struct Camera
{
    Vector origin; /// Perspective origin
    Vector upperLeft; /// Point in camera plane which corresponds to upper left corner of rendered image
    Vector width; /// Vector which describes the horizontal border of the camera plane
    Vector height; /// Vector which describes the vertical border of the camera plane

    static Camera construct(in Vector origin, in Vector direction, in Vector up, double width, double height) pure
    in
    {
        assert(direction.perpendicularTo(up));
    }
    do
    {
        Vector directionNorm = direction; directionNorm.normalize();
        Vector upNorm = up; upNorm.normalize();

        immutable Vector center = origin + direction,
            left = directionNorm * upNorm,
            _upperLeft = center + up * height * 0.5 + left * width * 0.5,
            _width = left * -width,
            _height = up * -height;

        return Camera(origin, _upperLeft, _width, _height);
    }

    Ray rayForPixel(double x, double y) const pure
    {
        immutable Vector pointInPlane = upperLeft + width * x + height * y;
        return Ray.fromTo(origin, pointInPlane);
    }
}

unittest
{
    import core.exception : AssertError;
    import std.exception : assertThrown;
    import std.math : approxEqual;

    const auto c = Camera.construct(Vector(0, 0, 8), Vector(0, 0, -2), Vector(0, -1, 0), 1, 0.75);
    assert(approxEqual(c.upperLeft.z, 6));

    // Camera construction fails if up vector is not perpendicular to viewing direction
    assertThrown!AssertError(Camera.construct(Vector(0, 0, 0), Vector(1, 1, 1), Vector(1, 1, 2), 1, 0.75));
}