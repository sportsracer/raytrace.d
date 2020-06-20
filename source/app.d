import std.getopt;
import std.random;
import std.stdio;

import camera : Camera;
import color : Color;
import light : PointLight;
import material : Material;
import scene : Scene;
import sceneobject : SceneObject;
import sphere : Sphere;
import vector : Vector;
import window : createWindow;

Scene buildScene()
{
    Scene scene = new Scene();
    scene.lightSource = PointLight(Vector(0, -4, 0), Color.white, 20.0);
    scene.camera = Camera.construct(Vector(0, 0, 4), Vector(0, 0, -2), Vector(0, -1, 0), 1.0, 0.75);

    // generate objects
    scene.objects = [];

    // ten smaller spheres closer to light source
    foreach (i; 0 .. 10)
    {
        const auto color = Color(uniform(0.5, 1), uniform(0.0, 0.5), uniform(0.0, 0.5));
        const auto material = new Material(color, 0.2);
        immutable double x = uniform(-2.0, 2.0),
        y = uniform(-2.0, 0.0),
        z = uniform(-4.0, -2.0);
        scene.objects ~= new Sphere(material, Vector(x, y, z), 0.2);
    }
    
    // ten larger spheres at bottom of scene, so we can see shadows in action
    foreach (i; 0 .. 10)
    {
        immutable double x = uniform(-2.0, 2.0),
        y = uniform(0.0, 2.0),
        z = uniform(-4.0, -2.0);
        scene.objects ~= new Sphere(Material.matteWhite, Vector(x, y, z), 0.8);
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

    auto scene = buildScene();
    createWindow(args, scene, width, height);
    return 0;
}