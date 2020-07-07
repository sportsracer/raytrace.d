module window;

import std.conv;
import std.datetime.stopwatch;
import std.stdio;

import cairo.Context;
import cairo.ImageSurface;
import cairo.Types;
import gtk.DrawingArea;
import gtk.Main;
import gtk.MainWindow;
import gtk.Widget;

import color : Color;
import scene : Scene;

void createWindow(string[] args, Scene scene, const uint width, const uint height)
{
    Main.init(args);

    stderr.writeln("Creating window of size ", width, "x", height);
    MainWindow w = new MainWindow("raytrace.d");
    w.addOnDestroy(delegate void(Widget _) { Main.quit(); });
    w.setSizeRequest(width, height);

    auto canvas = new Canvas(scene, width, height);
    w.add(canvas);
    w.showAll();

    Main.run();
}

class Canvas : DrawingArea
{
    Scene scene;
    ImageSurface img;
    bool rendered;

    this(Scene scene, uint width, uint height)
    {
        super(width, height);
        this.scene = scene;
        this.img = ImageSurface.create(CairoFormat.RGB24, width, height);
        addOnDraw(&onDraw);
    }

    void render()
    {
        immutable int width = img.getWidth(),
            height = img.getHeight(),
            stride = img.getStride(),
            depth = 4;

        ubyte* pixels = img.getData();
        foreach (int y; 0..height-1)
        {
            ubyte* row = &pixels[y * stride];
            foreach (int x; 0..width-1)
            {
                immutable double xf = to!double(x) / width,
                    yf = to!double(y) / height;
                immutable Color color = scene.renderPoint(xf, yf);
                immutable rgb = color.toRGBBytes();
                row[x * depth] = rgb.b;
                row[x * depth + 1] = rgb.g;
                row[x * depth + 2] = rgb.r;
            }
        }
    }

    bool onDraw(Scoped!Context context, Widget _)
    {
        if (!rendered) {
            StopWatch stopwatch;
            stopwatch.start();

            render();

            stopwatch.stop();
            const secs = stopwatch.peek.total!"seconds";
            stderr.writeln("Rendered scene in ", secs, "s");

            rendered = true;
        }

        context.setSourceSurface(img, 0, 0);
        context.paint();

        return true;
    }
}