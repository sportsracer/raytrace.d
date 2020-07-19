module geometry.vector;

import std.math : acos, approxEqual, sqrt;
import std.traits : isFloatingPoint;

// Tolerance for some floating point comparisons.
immutable epsilon = 1e-6;

/// Vector of length three.
struct Vector3(T)
if (isFloatingPoint!T)
{
    T x, y, z;

    /// Add and subtract vectors.
    Vector3!T opBinary(string op)(in Vector3!T rhs) const pure
    if (op == "+" || op == "-")
    {
        return mixin("Vector3(x "~op~" rhs.x, y "~op~" rhs.y, z "~op~" rhs.z)");
    }

    /// Cross product.
    Vector3!T opBinary(string op)(in Vector3!T rhs) const pure
    if (op == "*")
    {
        return Vector3!T(
            y * rhs.z - z * rhs.y,
            z * rhs.x - x * rhs.z,
            x * rhs.y - y * rhs.x
        );
    }

    /// Scale vector by a factor.
    Vector3!T opBinary(string op)(T rhs) const pure
    if (op == "*")
    {
        return Vector3!T(
            x * rhs,
            y * rhs,
            z * rhs
        );
    }

    /// Modify this vector so that its direction is the same, but its length is 1.
    void normalize() pure
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
        immutable invLength = 1.0 / length;
        x *= invLength;
        y *= invLength;
        z *= invLength;
    }

    T length() const pure
    {
        return sqrt(length2);
    }

    /// Length of the vector squared; made available for comparing length of vectors without the costly sqrt.
    T length2() const pure
    {
        return x * x + y * y + z * z;
    }

    /// True if length is 1.0, approximately.
    bool isNormalized() const pure
    {
        return approxEqual(length2, 1.0, 0.0, epsilon);
    }

    /// Dot product.
    T dot(in Vector3!T rhs) const pure
    {
        return x * rhs.x + y * rhs.y + z * rhs.z;
    }

    /// True if perpendicular, i.e. at 90° angle to other vector.
    bool perpendicularTo(in Vector3!T other) const pure
    {
        return approxEqual(this.dot(other), 0, 0.0, epsilon);
    }

    /** Compute angle between this and other vector in radians. */
    double angleWith(in Vector3!T other) const pure
    {
        immutable double dot = this.dot(other),
            myLength = this.length(),
            otherLength = other.length(),
            term = dot / (myLength * otherLength);
        return acos(term);
    }

    /// Reflection of this vector on a surface represented by normal
    Vector3!T reflect(in Vector3!T normal) const pure
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

alias Vector = Vector3!double;

// Helper function for unit tests
version (unittest) bool approxEqualVector(T)(in Vector3!T v1, in Vector3!T v2) pure
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
        assert(v1.perpendicularTo(v2));
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

/// Support for multiple floating point types
unittest
{
    import std.math : approxEqual;

    alias Vector3r = Vector3!real;

    immutable Vector3r v1 = {1.0, -1.0, 2.0}, v2 = v1 * -1.0, v3 = v1 + v2;
    immutable real length = v3.length;
    assert(approxEqual(length, 0));
}