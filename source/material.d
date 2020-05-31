module material;

import std.math : cos, PI_2;

import color : Color;

class Material
{
    Color color;

    this(const Color color)
    {
        this.color = color;
    }

    Color diffuseColor(double angle) const
    {
        if (angle > PI_2)
        {
            return Color.black;
        }
        return color * cos(angle);
    }

    static Material white()
    {
        return new Material(Color.white);
    }
}

unittest
{
    import std.math : PI;

    // ambient light is completely black at 180° angle
    immutable auto black = Material.white.diffuseColor(PI);
    assert(black == Color.black);

    // ... and not black if illuminated directly
    immutable auto notBlack = Material.white.diffuseColor(0);
    assert(notBlack.r > 0);
    assert(notBlack.g > 0);
    assert(notBlack.b > 0);
}