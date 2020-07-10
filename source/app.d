import std.conv;
import std.getopt;
import std.random;
import std.stdio;

import color.color : Color;
import geometry.vector : Vector;
import scene.camera : Camera;
import scene.light : SphericalLight;
import scene.material : Material;
import scene.scene : Scene;
import scene.sphere : SphereSceneObject;
import scene.sceneobject : SceneObject;
import window : createWindow;

Scene buildScene(double aspectRatio)
{
    auto scene = new Scene();

    auto light = new SphericalLight(Vector(0.5, 0.5, 0.5), 0.2, Color.white, 5.0);
    scene.addObject(light);

    light = new SphericalLight(Vector(0, -4, -3), 0.5, Color(1, 0, 0), 5.0);
    scene.addObject(light);

    scene.camera = Camera.construct(Vector(0, 0, 4), Vector(0, 0, -2), Vector(0, -1, 0), 1.0, 1.0 / aspectRatio);

    // generate objects

    // ten smaller spheres closer to light source
    foreach (i; 0 .. 10)
    {
        const color = Color(uniform(0.5, 1), uniform(0.0, 0.5), uniform(0.0, 0.5)),
            material = new Material(color, 0.2);
        const double x = uniform(-2.0, 2.0),
            y = uniform(-2.0, 0.0),
            z = uniform(-4.0, -2.0);
        auto sphere = new SphereSceneObject(material, Vector(x, y, z), 0.2);
        scene.addObject(sphere);
    }

    // ten larger spheres at bottom of scene, so we can see shadows in action
    foreach (i; 0 .. 10)
    {
        const double x = uniform(-2.0, 2.0),
            y = uniform(0.0, 2.0),
            z = uniform(-4.0, -2.0);
        auto sphere = new SphereSceneObject(Material.matteWhite, Vector(x, y, z), 0.8);
        scene.addObject(sphere);
    }
    return scene;
}

int main(string[] args)
{
    uint width = 800, height = 600;
    GetoptResult opts;
    try
    {
        opts = getopt(
            args,
            "width", "Window width", &width,
            "height", "Window height", &height
        );
    }
    catch (GetOptException ex)
    {
        stderr.writeln(ex.msg);
        stderr.writeln("Run with --help to see usage");
        return 1;
    }

    if (opts.helpWanted)
    {
        defaultGetoptPrinter("Usage:", opts.options);
        return 0;
    }

    auto scene = buildScene(to!double(width) / height);
    createWindow(args, scene, width, height);
    return 0;
}