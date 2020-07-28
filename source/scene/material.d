module scene.material;

import std.math : cos, PI_2;

import scene.color : Color;

struct Material
{
    Color color;
    double reflective;

    Color diffuseColor(double angle) const pure
    {
        if (angle > PI_2)
        {
            return Color.black;
        }
        return color * cos(angle);
    }

    immutable static {
        auto matteWhite = Material(Color.white, 0.0),
            shinyBlack = Material(Color(0.1, 0.1, 0.1), 0.5);
    }
}

unittest
{
    import std.math : PI;

    // ambient light is completely black at 180° angle
    immutable black = Material.matteWhite.diffuseColor(PI);
    assert(black == Color.black);

    // ... and not black if illuminated directly
    immutable notBlack = Material.matteWhite.diffuseColor(0);
    assert(notBlack.r > 0);
    assert(notBlack.g > 0);
    assert(notBlack.b > 0);
}