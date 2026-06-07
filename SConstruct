import os

env = SConscript("D:/godotEngine/godot-cpp-4.5/SConstruct")

env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp")

library_name = "school_day"

if env["platform"] == "windows":
    library = env.SharedLibrary("bin/{}.{}.{}.dll".format(library_name, env["platform"], env["target"]), source=sources)
else:
    library = env.SharedLibrary("bin/lib{}.{}.{}.so".format(library_name, env["platform"], env["target"]), source=sources)

Default(library)