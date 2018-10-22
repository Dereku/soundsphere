require("libraries.packagePath")
require("tweaks")
require("Cache")
sqlite = require("ljsqlite3")
ffi = require("ffi")
require("iconv_ffi")

cache = Cache:new()
cache:init()
cache:lookup(args[1], args[2])
cache:clean(args[1])
