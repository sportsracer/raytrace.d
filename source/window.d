import std.stdio;

import cairo.Context;
import cairo.ImageSurface;
import cairo.Types;
import gtk.DrawingArea;
import gtk.Main;
import gtk.MainWindow;
import gtk.Widget;

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

    this(uint width, uint height)
    {
        super(width, height);
        img = ImageSurface.create(CairoFormat.RGB24, width, height);
        addOnDraw(&onDraw);
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
                ubyte val = cast(ubyte) y % 256;
                row[x * depth] = val;
            }
        }

        context.setSourceSurface(img, 0, 0);
        context.paint();

        return true;
    }
}