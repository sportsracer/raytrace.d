import std.stdio;

import gtk.Main;
import gtk.MainWindow;
import gtk.Widget;

void createWindow(string[] args, const uint width, const uint height)
{
    Main.init(args);

    stderr.writeln("Creating window of size ", width, "x", height);
    MainWindow w = new MainWindow("raytrace.d");
    w.addOnDestroy(delegate void(Widget w) { Main.quit(); });
    w.setSizeRequest(width, height);
    w.showAll();

    Main.run();
}