module geometry.sphere;

import std.conv : to;
import std.math : cos, round, sin, sqrt, PI;
import std.typecons : Nullable;

import geometry.ray : Ray;
import geometry.vector : Vector;

/** Three-dimensional sphere, defined by a center and radius. */
struct Sphere
{
    Vector center;
    double radius;

    private double intersectionDistance(const Ray ray) const
    {
        immutable Vector oc = ray.orig - center;
        immutable double a = ray.dir.dot(ray.dir),
            b = 2.0 * oc.dot(ray.dir),
            c = oc.dot(oc) - radius * radius,
            discriminant = b * b - 4.0 * a * c;
        if (discriminant >= 0)
        {
            foreach (numerator; [-b - sqrt(discriminant), -b + sqrt(discriminant)])
            {
                if (numerator > 0)
                {
                    return numerator / (2.0 * a);
                }
            }
        }
        return -1.0;
    }

    Nullable!Ray hit(const Ray ray) const
    {
        Nullable!Ray intersection;
        immutable distance = intersectionDistance(ray);
        if (distance >= 0)
        {
            immutable Vector intersectionPoint = ray.orig + ray.dir * distance,
                normal = intersectionPoint - center;
            intersection = Ray(intersectionPoint, normal);
        }
        return intersection;
    }

    /** Return a point on this sphere determined by its spherical coordinates. */
    Vector pointFromSphericalCoords(const double polar, const double azimuth) const
    {
        return center + Vector(
            sin(polar) * cos(azimuth),
            sin(polar) * sin(azimuth),
            cos(polar)
        ) * radius;
    }

    /**
    * Implementation of https://www.cmu.edu/biolphys/deserno/pdf/sphere_equi.pdf
    */
    Vector[] equidistantPoints(int numPoints) const
    {
        Vector[] vectors;

        immutable a = 4.0 * PI / numPoints,
            d = sqrt(a),
            mPolar = to!int(round(PI / d)),
            dPolar = PI / mPolar,
            dAzimuth = a / dPolar;

        foreach (m; 0 .. mPolar - 1)
        {
            immutable polar = PI * (m + 0.5) / mPolar,
                mAzimuth = to!int(round(2.0 * PI * sin(polar) / dAzimuth));
            foreach (n; 0 .. mAzimuth - 1)
            {
                immutable azimuth = 2.0 * PI * n / mAzimuth;
                vectors ~= pointFromSphericalCoords(polar, azimuth);
            }
        }

        return vectors;
    }
}

/// Spherical coordinates
unittest
{
    import std.math : approxEqual, PI_2;

    const sphere = new Sphere(Vector(1, 1, 1), 2);

    // generate a point on this sphere, and verify it's actually on the sphere's surface
    immutable point = sphere.pointFromSphericalCoords(PI_2, 3.0 * PI_2),
        dist = sphere.center - point;
    assert(approxEqual(dist.length, sphere.radius));
}

/// Creation of equidistant points on sphere surface
unittest
{
    const numPoints = 32;
    {
        const unitSphere = Sphere(Vector(0, 0, 0), 1),
            points = unitSphere.equidistantPoints( numPoints);
        // The algorithm has no strong guarantees on the number of sampled points generated. Let's assert it's in the same
        // order of magnitude, at least.
        assert(numPoints / 10 < points.length);
        assert(points.length < numPoints * 10);

        // since we're on the surface of a unit sphere, all vectors have length one
        foreach (Vector point; points)
        {
            assert(point.isNormalized());
        }
    }

    {
        const smallSphere = Sphere(Vector(0, 0, 0), 0.1),
            points = smallSphere.equidistantPoints(numPoints);
        assert(numPoints / 10 < points.length);
        assert(points.length < numPoints * 10);
    }
}