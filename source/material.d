module material;

import std.math : cos, PI_2;

import color : Color;

class Material
{
    Color color;
    double reflective;

    this(const Color color, double reflective)
    {
        this.color = color;
        this.reflective = reflective;
    }

    Color diffuseColor(double angle) const
    {
        if (angle > PI_2)
        {
            return Color.black;
        }
        return color * cos(angle);
    }

    static Material matteWhite()
    {
        return new Material(Color.white, 0.0);
    }

    static Material shinyBlack()
    {
        return new Material(Color(0.1, 0.1, 0.1), 0.5);
    }
}

unittest
{
    import std.math : PI;

    // ambient light is completely black at 180° angle
    immutable auto black = Material.matteWhite.diffuseColor(PI);
    assert(black == Color.black);

    // ... and not black if illuminated directly
    immutable auto notBlack = Material.matteWhite.diffuseColor(0);
    assert(notBlack.r > 0);
    assert(notBlack.g > 0);
    assert(notBlack.b > 0);
}