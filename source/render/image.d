module render.image;

import std.algorithm : min;
import std.typecons : Tuple;
import std.conv : to;

import scene.color : Color;

/// Generalized two-dimensional data container
class Matrix(T)
{
    private {
        T[][] data;
    }

    this(size_t width, size_t height) pure
    {
        this.data = new T[][](height, width);
    }

    size_t height() pure const
    {
        return data.length;
    }

    size_t width() pure const
    in
    {
        assert(height > 0);
    }
    do
    {
        return data[0].length;
    }

    T opIndex(size_t col, size_t row) pure const
    {
        return data[row][col];
    }

    ref T opIndexAssign(in T val, size_t col, size_t row) pure
    {
        return data[row][col] = val;
    }
}

/// Image, defined as a matrix of `Color` values
alias Image = Matrix!Color;

/// Representation of a color as triplet of bytes.
alias RGBBytes = Tuple!(ubyte, "r", ubyte, "g", ubyte, "b");

/// Convert a color to an RGB tuple
RGBBytes toRGBBytes(in Color color) pure
{
    ubyte toByte(in double val)
    {
        return to!ubyte(255.0 * min(val, 1.0));
    }
    return RGBBytes(toByte(color.r), toByte(color.g), toByte(color.b));
}

/// Image creation and manipulation
unittest
{
    import core.exception : RangeError;
    import std.exception : assertThrown;

    const width = 100, height = 50;
    auto img = new Image(width, height);
    assert(img.width == width);
    assert(img.height == height);

    // Initialize image to white
    foreach (x; 0..width)
    {
        foreach (y; 0..height)
        {
            img[x, y] = Color.white;
            assert(img[x, y] == Color.white);
        }
    }

    // Going out of image bounds triggers exception
    assertThrown!RangeError(img[width + 1, height + 1]);
}

/// Conversion of colors to bytes
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