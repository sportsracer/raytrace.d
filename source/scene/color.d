module scene.color;

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

    immutable static {
        auto black = Color(0.0, 0.0, 0.0),
            white = Color(1.0, 1.0, 1.0);
    }
}

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
