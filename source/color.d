module color;

import std.typecons : Tuple, tuple;
import std.conv : to;

alias RGBBytes = Tuple!(ubyte, "r", ubyte, "g", ubyte, "b");

struct Color
{
    double r, g, b;

    Color opBinary(string op)(const Color rhs) const
    if (op == "+")
    {
        return Color(r + rhs.r, g + rhs.g, b + rhs.b);
    }

    Color opBinary(string op)(float factor) const
    if (op == "*")
    {
        return Color(r * factor, g * factor, b * factor);
    }

    RGBBytes toRGBBytes() const
    {
        immutable ubyte _r = to!ubyte( 255.0 * this.r),
        _g = to!ubyte( 255.0 * this.g),
        _b = to!ubyte( 255.0 * this.b);
        return RGBBytes( _r, _g, _b);
    }

    static auto black = Color(0.0, 0.0, 0.0);
    static auto white = Color(1.0, 1.0, 1.0);
}

/// Colors can be added and scaled by a factor
unittest
{
    import std.math : approxEqual;

    immutable red = Color(1, 0, 0),
        green = Color(0, 1, 0),
        blue = Color(0, 0, 1),
        white = red + green + blue;
    assert(approxEqual(white.r, 1));
    assert(approxEqual(white.g, 1));
    assert(approxEqual(white.b, 1));

    immutable gray = white * 0.5;
    assert(approxEqual(gray.r, 0.5));
    assert(approxEqual(gray.g, 0.5));
    assert(approxEqual(gray.b, 0.5));
}

/// Conversion to bytes
unittest
{
    immutable lightRed = Color(1, 0.5, 0.5),
        bytes = lightRed.toRGBBytes();
    assert(bytes.r == 255);
    assert(bytes.g == 127);
    assert(bytes.b == 127);
}