# docker-wix
Yet another dockerized WiX toolset

This docker image is focused on ease of use. Instead of
modifying the Dockerfile or the necessity of special syntax like
"wine candle.exe ...", this image comes with a builtin generator
for creating wrapper scripts on the host. This results in a seamless,
transparent user experience like "candle product.wxs" Due to a clever
combination of a docker mount and a combination of wrapper scripts,
it can handle both relative and absolute pathes in parameters.

## First usage
Before starting your regular work with this image, you must create
wrapper scripts for the various WiX tools on your host system.
For this, the special command mkhostwrappers is used like this:

Change into a suitable directory in your **PATH**, then run
```
docker run --rm felfert/wix mkhostwrappers | sh
```
Notice the **absence** of the usual *-it* parameter. Of course, you need write
permissions, so if you want to do create the wrappers in /sr/local/bin, then
you would use instead:
```
docker run --rm felfert/wix mkhostwrappers | sudo sh
```
Alternatively, use a newly created directory and later set your **PATH** variable
accordingly.

The above command creates a wrapper script (candle) as well as a bunch of symlinks.
From now on, you simply can invoke the various WiX tools as if the were native
to your Linux system. E.g.:
```
candle MyProduct.wxs
light -sval MyProduct.wixobj
```
## Known bug
The "light" tool **must** be invoked with **disabled msi validation** (-sval option),
otherwise it fails on wine.
