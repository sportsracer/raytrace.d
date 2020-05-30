import std.conv;
import std.stdio;

import cairo.Context;
import cairo.ImageSurface;
import cairo.Types;
import gtk.DrawingArea;
import gtk.Main;
import gtk.MainWindow;
import gtk.Widget;

import camera : Camera;
import scene : Scene;
import sceneobject : SceneObject;
import sphere : Sphere;
import vector : Vector;

void createWindow(string[] args, const uint width, const uint height)
{
    Main.init(args);

    stderr.writeln("Creating window of size ", width, "x", height);
    MainWindow w = new MainWindow("raytrace.d");
    w.addOnDestroy(delegate void(Widget _) { Main.quit(); });
    w.setSizeRequest(width, height);

    auto canvas = new Canvas(width, height);
    w.add(canvas);

    w.showAll();

    Main.run();
}

class Canvas : DrawingArea
{
    ImageSurface img;
    Scene scene;

    this(uint width, uint height)
    {
        super(width, height);
        img = ImageSurface.create(CairoFormat.RGB24, width, height);
        addOnDraw(&onDraw);

        // construct scene
        scene = new Scene();
        scene.camera = Camera.construct(Vector(0, 0, 4), Vector(0, 0, -2), Vector(0, -1, 0), 1.0, 0.75);
        scene.objects = [
            new Sphere(Vector(0, 1, -6), 1),
            new Sphere(Vector(1, 0, -4), 1),
            new Sphere(Vector(-0.8, 0, -2), 1),
        ];
        scene.lightSource = Vector(0, -4, 0);
    }

    bool onDraw(Scoped!Context context, Widget _)
    {
        immutable int width = img.getWidth(),
            height = img.getHeight(),
            stride = img.getStride(),
            depth = 4;

        // fill the image with some gibberish
        ubyte* pixels = img.getData();
        foreach (int y; 0..height-1)
        {
            ubyte* row = &pixels[y * stride];
            foreach (int x; 0..width-1)
            {
                immutable double xf = to!double(x) / width,
                    yf = to!double(y) / height,
                    brightness = scene.renderPoint(xf, yf);
                immutable ubyte val = to!ubyte(brightness * 255.0);
                row[x * depth] = val;
                row[x * depth + 1] = val;
                row[x * depth + 2] = val;
            }
        }

        context.setSourceSurface(img, 0, 0);
        context.paint();

        return true;
    }
}