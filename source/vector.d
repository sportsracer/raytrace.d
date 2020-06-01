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
        in
        {
            assert(length > 0);
        }
        out
        {
            assert(approxEqual(length, 1));
        }
        do
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

        bool isNormalized() const
        {
            return approxEqual(length, 1);
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

        /// Reflection of this vector on a surface represented by normal
        Vector reflect(const Vector normal) const
        in
        {
            // the implementation is simplified by assuming the surface normal is of length 1
            assert(normal.isNormalized());
        }
        out (result)
        {
            assert(approxEqual(this.length, result.length));
        }
        do
        {
            return this - normal * 2 * this.dot(normal);
        }
    }
}

// Helper function for unit tests
bool approxEqualVector(const Vector v1, const Vector v2)
{
    return approxEqual(v1.x, v2.x)
        && approxEqual(v1.y, v2.y)
        && approxEqual(v1.z, v2.z);
}

/// Addition & subtraction of vectors
unittest
{
    immutable Vector v1 = {1, 2, 3},
        v2 = {4, 5, 6},
        vSum = v1 + v2,
        vDiff = v1 - v2;

    assert(vSum.approxEqualVector(Vector(5, 7, 9)));
    assert(vDiff.approxEqualVector(Vector(-3, -3, -3)));
}

/// Vector cross product
unittest
{
    immutable Vector fwd = {0, 0, 1},
        up = {0, 1, 0},
        right = fwd * up;

    assert(approxEqualVector(right, Vector(-1, 0, 0)));
}

/// Vector scaling
unittest
{
    immutable Vector v = {1, 2, 3},
        vScaled = v * 3;

    assert(approxEqualVector(vScaled, Vector(3, 6, 9)));
}

/// Vector length
unittest
{
    immutable Vector v1 = {1, 0, 0},
        v2 = {3, 3, 3};

    assert(approxEqual(v1.length(), 1));
    assert(approxEqual(v2.length(), sqrt(27.0)));
}

/// Normalization
unittest
{
    import core.exception : AssertError;
    import std.exception : assertThrown;

    {
        Vector v = {2, 0, 0};
        assert(!v.isNormalized());
        v.normalize();
        assert(approxEqual(v.x, 1));
        assert(v.isNormalized());
    }

    {
        Vector v = {1, 1, 1};
        assert(!v.isNormalized());
        v.normalize();
        assert(approxEqual(v.x, 1.0 / sqrt( 3.0)));
        assert(v.isNormalized());
    }

    {
        // can't normalize vector of length zero
        Vector v = {0, 0, 0};
        assertThrown!AssertError(v.normalize());
    }
}

/// Dot product
unittest
{
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
    import std.math : PI, PI_2;

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

/// Reflecting vectors
unittest
{
    immutable Vector normal = {0, 0, 1};

    {
        immutable Vector vIn = {0, 0, -2},
            vOut = vIn.reflect(normal);
        assert(approxEqualVector(vOut, Vector(0, 0, 2)));
    }

    {
        immutable Vector vIn = {1, 1, 1},
            vOut = vIn.reflect(normal);
        assert(approxEqualVector(vOut, Vector(1, 1, -1)));
    }

}