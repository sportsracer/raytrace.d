module window;

import std.stdio;

import cairo.Context;
import cairo.ImageSurface;
import cairo.Types;
import gtk.DrawingArea;
import gtk.Main;
import gtk.MainWindow;
import gtk.Widget;

import render.image : Image, toRGBBytes;
import scene.color : Color;
import scene.scene : Scene;

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
    ImageSurface imgSurface;
    bool rendered;

    this(Scene scene, uint width, uint height)
    {
        super(width, height);
        this.scene = scene;
        this.imgSurface = ImageSurface.create(CairoFormat.RGB24, width, height);
        addOnDraw(&onDraw);
    }

    void render()
    {
        immutable int width = imgSurface.getWidth(),
            height = imgSurface.getHeight(),
            stride = imgSurface.getStride(),
            depth = 4;

        const img = scene.camera.render(scene, width, height);

        ubyte* pixels = imgSurface.getData();
        foreach (y; 0..height)
        {
            ubyte* row = &pixels[y * stride];
            foreach (x; 0..width)
            {
                immutable Color color = img[x, y];
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
            render();
            rendered = true;
        }

        context.setSourceSurface(imgSurface, 0, 0);
        context.paint();

        return true;
    }
}