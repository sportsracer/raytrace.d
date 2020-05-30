module vector;

import std.math : acos, approxEqual, sqrt;

struct Vector
{
    double x, y, z;

    pure {

        Vector opBinary(string op)(const Vector rhs) const
        if (op == "+" || op == "-")
        {
            return mixin("Vector(x "~op~" rhs.x, y "~op~" rhs.y, z "~op~" rhs.z)");
        }

        Vector opBinary(string op)(const Vector rhs) const
        if (op == "*")
        {
            return Vector(
                y * rhs.z - z * rhs.y,
                z * rhs.x - x * rhs.z,
                x * rhs.y - y * rhs.x
            );
        }

        Vector opBinary(string op)(const double rhs) const
        if (op == "*")
        {
            return Vector(
                x * rhs,
                y * rhs,
                z * rhs
            );
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

        bool perpendicularTo(const Vector other) const
        {
            return approxEqual(this.dot(other), 0);
        }

        double angleWith(const Vector other) const
        {
            immutable double dot = this.dot(other),
                myLength = this.length(),
                otherLength = other.length(),
                term = dot / (myLength * otherLength);
            return acos(term);
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

/// Vector cross product
unittest
{
    import std.math : approxEqual;

    immutable Vector fwd = {0, 0, 1},
    up = {0, 1, 0},
    right = fwd * up;

    assert(approxEqual(right.x, -1));
    assert(approxEqual(right.y, 0));
    assert(approxEqual(right.z, 0));
}

/// Vector scaling
unittest
{
    immutable Vector v = {1, 2, 3},
        vScaled = v * 3;

    import std.math : approxEqual;

    assert(approxEqual(vScaled.x, 3));
    assert(approxEqual(vScaled.y, 6));
    assert(approxEqual(vScaled.z, 9));
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

    {
        immutable Vector v1 = {1, 2, 3},
            v2 = {4, 5, 6};
        auto dot = v1.dot(v2);
        assert(approxEqual(dot, 32));
        assert(!v1.perpendicularTo(v2));
    }

    {
        immutable Vector v1 = {1, 0, 0},
            v2 = {0, 2, 0};
        assert(v1.perpendicularTo( v2));
    }
}

/// Computing angles
unittest
{
    import std.math : approxEqual, PI, PI_2;

    immutable Vector v1 = {1, 0, 0};

    {
        immutable Vector v2 = {2, 0, 0};
        assert(approxEqual(v1.angleWith(v2), 0));
    }

    {
        immutable Vector v2 = {-1, 0, 0};
        assert(approxEqual(v1.angleWith(v2), PI));
    }

    {
        immutable Vector v2 = {0, 1, 0};
        assert(approxEqual(v1.angleWith(v2), PI_2));
    }

    {
        immutable Vector v2 = {0, 0.00001, 0};
        assert(v1.angleWith(v2) < PI_2);
    }
}