import std.getopt;
import std.stdio;

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

    writeln("Width ", width, ", height ", height);
    return 0;
}