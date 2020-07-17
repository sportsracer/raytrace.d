module window;

import std.conv;
import std.experimental.logger;
import std.parallelism;
import std.stdio;

import cairo.Context;
import cairo.ImageSurface;
import cairo.Types;
import gtk.DrawingArea;
import gtk.Main;
import gtk.MainWindow;
import gtk.Widget;

import color.color : Color;
import scene.scene : Scene;
import util.logger : TimingLogger;

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

    void render(Logger logger)
    {
        immutable int width = img.getWidth(),
            height = img.getHeight(),
            stride = img.getStride(),
            depth = 4;

        // Helper function to log rendering progress
        uint rowsRendered;
        void rowRendered()
        {
            logger.infof(++rowsRendered % 100 == 0, "%d/%d rows rendered", rowsRendered, height);
        }

        // Array of row indices to iterate over
        int[] ys;
        foreach (int y; 0..height-1)
        {
            ys ~= y;
        }

        ubyte* pixels = img.getData();
        foreach (int y; ys.parallel)
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
            rowRendered();
        }

        logger.info("Done rendering");
    }

    bool onDraw(Scoped!Context context, Widget _)
    {
        if (!rendered) {
            auto logger = TimingLogger.createStderrLogger();
            render(logger);
            rendered = true;
        }

        context.setSourceSurface(img, 0, 0);
        context.paint();

        return true;
    }
}