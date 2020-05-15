module vector;

import std.math : sqrt;

struct Vector
{
    double x, y, z;

    pure {

        Vector opBinary(string op)(const Vector rhs) const
        if (op == "+" || op == "-")
        {
            return mixin("Vector(x "~op~" rhs.x, y "~op~" rhs.y, z "~op~" rhs.z)");
        }

        void normalize()
        {
            immutable double invLength = 1.0 / length;
            x *= invLength;
            y *= invLength;
            z *= invLength;
        }

        double length() const
        {
            return sqrt(x * x + y * y + z * z);
        }

        double dot(const Vector rhs) const
        {
            return x * rhs.x + y * rhs.y + z * rhs.z;
        }

    }
}

/// Addition & subtraction of vectors
unittest
{
    import std.math : approxEqual;

    immutable Vector v1 = {1, 2, 3},
        v2 = {4, 5, 6},
        vSum = v1 + v2,
        vDiff = v1 - v2;

    assert(approxEqual(vSum.x, 5));
    assert(approxEqual(vSum.y, 7));
    assert(approxEqual(vSum.z, 9));

    assert(approxEqual(vDiff.x, -3));
    assert(approxEqual(vDiff.y, -3));
    assert(approxEqual(vDiff.z, -3));
}

/// Vector length
unittest
{
    import std.math : approxEqual;

    immutable Vector v1 = {1, 0, 0},
        v2 = {3, 3, 3};

    assert(approxEqual(v1.length(), 1));
    assert(approxEqual(v2.length(), sqrt(27.0)));
}

/// Normalization
unittest
{
    import std.math : approxEqual;

    Vector v1 = {2, 0, 0},
        v2 = {1, 1, 1};

    v1.normalize();
    assert(approxEqual(v1.x, 1));
    assert(approxEqual(v1.length(), 1));

    v2.normalize();
    assert(approxEqual(v2.x, 1.0 / sqrt(3.0)));
    assert(approxEqual(v2.length(), 1));
}

/// Dot product
unittest
{
    import std.math : approxEqual;

    immutable Vector v1 = {1, 2, 3},
        v2 = {4, 5, 6};

    auto dot = v1.dot(v2);
    assert(approxEqual(dot, 32));
}