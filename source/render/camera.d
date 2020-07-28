module render.camera;

import std.conv : to;
import std.parallelism;

import geometry.ray : Ray;
import geometry.vector : Vector;
import render.image : Image;
import scene.scene : Scene;
import util.logger : TimingLogger;

immutable renderDepth = 2; /// How many rays are cast recursively?

/** Representation of a view frustrum = camera. */
struct Camera
{
    Vector origin; /// Perspective origin
    Vector upperLeft; /// Point in camera plane which corresponds to upper left corner of rendered image
    Vector width; /// Vector which describes the horizontal border of the camera plane
    Vector height; /// Vector which describes the vertical border of the camera plane

    /**
    * Initialize a camera.
    *
    * Params:
    *   origin = Camera location
    *   direction = Vector from camera location to center of near clipping plane
    *   up = Which direction is up? Determines camera orientation. Assumed to be perpendicular to `direction`
    *   width = Width of the near clipping plane
    *   height = Height of the near clipping plane; determines aspect ratio together with `width`
    */
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

    /// Construct a ray corresponding to a point in near viewing plane, identified by x and y coordinate in [0, 1].
    Ray rayForPixel(double x, double y) const pure
    in
    {
        assert(0 <= x && x <= 1);
        assert(0 <= y && y <= 1);
    }
    do
    {
        immutable Vector pointInPlane = upperLeft + width * x + height * y;
        return Ray.fromTo(origin, pointInPlane);
    }

    /// Render an image of a scene
    Image render(in Scene scene, uint width, uint height) const
    {
        auto logger = TimingLogger.createStderrLogger();
        auto img = new Image(width, height);

        int[] ys;
        foreach (row; 0..height)
        {
            ys ~= row;
        }

        // Helper function to log rendering progress
        uint rowsRendered;
        void rowRendered()
        {
            logger.infof(++rowsRendered % 100 == 0, "%d/%d rows rendered", rowsRendered, height);
        }

        foreach (row; ys.parallel)
        {
            const yf = to!double(row) / height;
            foreach (col; 0..width)
            {
                const xf = to!double(col) / width;
                immutable ray = rayForPixel(xf, yf);
                immutable color = scene.renderRay(ray, renderDepth);
                img[col, row] = color;
            }
            rowRendered();
        }

        logger.info("Done rendering");

        return img;
    }
}

/// Camera construction
unittest
{
    import core.exception : AssertError;
    import std.exception : assertThrown;
    import std.math : approxEqual;

    const c = Camera.construct(Vector(0, 0, 8), Vector(0, 0, -2), Vector(0, -1, 0), 1, 0.75);
    assert(approxEqual(c.upperLeft.z, 6));

    // Camera construction fails if up vector is not perpendicular to viewing direction
    assertThrown!AssertError(Camera.construct(Vector(0, 0, 0), Vector(1, 1, 1), Vector(1, 1, 2), 1, 0.75));
}

/// Rendering
unittest
{
    import scene.color : Color;

    const c = Camera.construct(Vector(0, 0, 0), Vector(0, 0, -1), Vector(0, -1, 0), 1, 1);

    auto scene = new Scene();

    const width = 100, height = 75;
    auto img = c.render(scene, width, height);
    assert(img.width == width);
    assert(img.height == height);

    // empty scene is rendered black
    foreach (x; 0..img.width)
    {
        foreach (y; 0 .. img.height)
        {
            assert(img[x, y] == Color.black);
        }
    }
}