module light;

import color : Color;
import vector : Vector;

struct PointLight
{
    Vector pos;
    Color color;
    double intensity;

    Color illuminationAt(const Vector at) const
    {
        if (pos == at)
        {
            return color;
        }
        immutable auto lightDir = at - pos;
        immutable double distanceSquared = lightDir.length2;
        return color * (intensity / distanceSquared);
    }
}

unittest
{
    immutable auto whiteLight = PointLight(Vector(0, 0, 0), Color.white, 10.0);
    immutable auto colorNear = whiteLight.illuminationAt(Vector(1, 1, 1)),
        colorFar = whiteLight.illuminationAt(Vector(2, 2, 2));

    assert(colorNear.r + colorNear.g + colorNear.b > colorFar.r + colorFar.g + colorFar.b);
}