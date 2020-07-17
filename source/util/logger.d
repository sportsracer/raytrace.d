module util.logger;

import std.experimental.logger;
import std.datetime.stopwatch;
import std.stdio;

/// Logger which prefixes log messages with seconds elapsed since its creation.
class TimingLogger : Logger
{
    private File file;
    private StopWatch stopWatch;

    this(File file, LogLevel lv = LogLevel.all) @safe
    {
        super(lv);
        this.file = file;
        this.stopWatch.start();
    }

    override void writeLogMsg(ref LogEntry payload) @safe
    {
        auto time = 0.001 * this.stopWatch.peek.total!"msecs";
        this.file.writefln("[%5.1fs] %s", time, payload.msg);
    }

    static TimingLogger createStderrLogger(LogLevel lv = LogLevel.all)
    {
        return new TimingLogger(stderr, lv);
    }
}
