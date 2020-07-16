module color.color;

import std.algorithm : min;
import std.typecons : Tuple;
import std.conv : to;



/// Color value in the RGB model.
struct Color
{
    double r, g, b;

    Color opBinary(string op)(in Color rhs) const pure
    if (op == "+" || op == "*")
    {
        return mixin("Color(r "~op~" rhs.r, g "~op~" rhs.g, b "~op~" rhs.b)");
    }

    Color opBinary(string op)(float factor) const pure
    if (op == "*")
    {
        return Color(r * factor, g * factor, b * factor);
    }

    RGBBytes toRGBBytes() const pure
    {
        ubyte toByte(in double val)
        {
            return to!ubyte(255.0 * min(val, 1.0));
        }
        return RGBBytes(toByte(this.r), toByte(this.g), toByte(this.b));
    }

    immutable static {
        auto black = Color(0.0, 0.0, 0.0),
            white = Color(1.0, 1.0, 1.0);
    }
}

/// Representation of a color as triplet of bytes.
alias RGBBytes = Tuple!(ubyte, "r", ubyte, "g", ubyte, "b");

/// Colors can be added, multiplied and scaled by a factor
unittest
{
    import std.math : approxEqual;

    immutable red = Color(1, 0, 0),
        green = Color(0, 1, 0),
        blue = Color(0, 0, 1),
        white = red + green + blue;
    assert(approxEqual([white.r, white.g, white.b], 1));

    immutable gray = white * 0.5;
    assert(approxEqual([gray.r, gray.g, gray.b], 0.5));

    immutable darkRed = red * gray;
    assert(darkRed.r < 1);
    assert(darkRed.g == 0);
    assert(darkRed.b == 0);
}

/// Conversion to bytes
unittest
{
    immutable lightRed = Color(1, 0.5, 0.5),
        bytes = lightRed.toRGBBytes();
    assert(bytes.r == 255);
    assert(bytes.g == 127);
    assert(bytes.b == 127);

    // test that "HDR" color values greater than 1.0 are truncated to 255 when converting to bytes
    immutable hdr = Color(0.5, 2.0, 2.0),
        hdrBytes = hdr.toRGBBytes();
    assert(hdrBytes.r == 127);
    assert(hdrBytes.g == 255);
    assert(hdrBytes.b == 255);
}