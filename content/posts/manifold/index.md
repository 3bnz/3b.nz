---
title: I really like the Manifold library.
date: 2026-04-28
description: A d.i.y. software stack for parametric 3d modeling
---

![Geometry Tree](./tree.webp) _Image showing three main
[CSG](https://en.wikipedia.org/wiki/Constructive_solid_geometry) boolean
operations_

## Status Quo

I've been an [OpenSCAD](https://openscad.org/) user for quite some time now.
It's _the_ pragmatic choice for parametric 3D modeling and my go-to solution for
mechanical parts.

The tool comes with a `script -> geometry` compiler which uses a dedicated
[DSL](https://en.wikipedia.org/wiki/Domain-specific_language). The language
(while having C inspired syntax) is functional - constants only, pure functions,
etc. Additionally, to produce any geometry, one must use its dedicated `module`
system:

```scad
// A `module` is a block,
// which evaluates (implicitly returns?) some geometry
module highlight() {
    color("red") children();
}

// Modules can be chained
// leading to haskell style right-to-left syntax
scale(2.2) highlight() sphere(10.0);
```

While OpenSCAD does have it's quirks it generally gets the job done and is
widely supported.

## However..

There are some things I don't like about it. Especially when it comes to
building larger, more complex models or using some of its (also not so small)
third party libraries:

- Since it's weakly typed, the errors need to be checked at runtime using
  [test functions](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Type_Test_Functions) -
  `is_num`, `is_list` etc. Many of these errors could be inferred at
  compile-time or via static analysis.
- I wish the order of operation order would be left-to-right i.e.
  `cube(..) translate(..)` instead of `translate(...) cube(..)` While the first
  option might feel more "english" there are many benefits to chaining
  operations after the object. You can read more about "pipelining" here:
  [Pipelining might be my favorite programming language feature](https://herecomesthemoon.net/2025/04/pipelining/).
- While still in active development, the last official release was over _five_
  years ago. So to get latest fixed and improvements one must use development
  snapshots[^1].

And _boy_ there have been improvements - after switching to a developer snapshot
compilation of my models went from tens of seconds to pretty much instantaneous!
Like..huh? How is such improvement even possible?

## Manifold

A library by [Emmett Lalish](https://elalish.blogspot.com/) that's responsible
for turning solids into a triangle mesh and supports
[3mf](https://github.com/3MFConsortium/spec_core) export. As opposed to STL,
this file format **shares vertices between adjacent triangles**[^2] which avoids
broken, disjointed meshes and subsequent
[fixing](https://blog.prusa3d.com/repair-3d-models-errors_7529/). i.e. manifold
always produces _"watertight"_ models with exact known volume.

Additionally it has broad set of
[bindings](https://github.com/elalish/manifold#bindings--packages) which means
we can use well supported general purpose language with mature tooling to
generate our geometry.

Since the library can be compiled to wasm - there even is a reference web
interface [ManifoldCAD](https://manifoldcad.org/). It's a great demo, but I
would like to create local setup, which can be launched from CLI, use my
`$EDITOR` of choice and have version control with git.

## Local Setup

![webp](./screen.webp)

Choosing among the many available languages comes down to a few constraints
imposed by our local setup:

1. The language must be interpreted and dynamic, so the library itself doesn't
   need to be loaded in memory on every model change - only the geometry code
   does.
2. The wasm target is currently single-threaded, and available memory is limited
   by the V8 engine. Id like to run it "bare metal"

Together, these constraints basically leaves us with Python. Luckily due to it's
use in robotics and ml-vision there are also many 3d viewers available. I chose
[viser](https://viser.studio/main/) since it has good rendering of
semi-transparent models and updates are fast. After spending some time wiring
convenience wrappers, implementing hot-reload and file export we are left
syntax, which is quite a bit more expressive than `scad` language.

If you'd like to try this out - there is a
[repository](https://github.com/3bnz/manifold)

## Bonus - Setting Tolerances

![desmos](desmos.webp) _Given an n sided polygon inscribed in circle - this
formula calculates the required number of segments that satisfy some maximum
tolerance ε. Screenshot from
[desmos](https://www.desmos.com/calculator/johoyslpy2) playground_

Since manifold works on
[triangulated meshes](https://en.wikipedia.org/wiki/Triangulation) - any API for
generating continuous shapes (cylinders, spheres) expects an explicit segments
count.

Previously I'd eyeball the segment count, or set it globally with
[$fn](https://www.openscad.info/index.php/2020/06/05/fn-system-variable/). Neither is great since [$fn](https://www.openscad.info/index.php/2020/06/05/fn-system-variable/)
applies the same segment count to every circular shape regardless of size, so
small shapes end up overly dense.

For manufacturing, often we actually care about tolerance (ε). i.e. the maximum
permissible deviation of the triangulated model from its
[SDF](https://en.wikipedia.org/wiki/Signed_distance_function)

For a simple circle the math is pretty straight forward it also approximates
sphere close enough. Then - using formula from above and clamping it to
something reasonable we get:

```python
def segments(radius: float) -> int:
    tolerance = 0.05
    n = math.pi / math.acos(1.0 - tolerance / radius)
    return min(1024, max(8, math.ceil(n)))
```

Then this function can be used as the default segments parameter

---

[^1]: According to homebrew statistics around 25% of users are running nightly
    instead of release version of OpenSCAD

[^2]: In [3mf](https://github.com/3MFConsortium/spec_core) vertex data is stored
    in a separate array. Then - mesh is created by indexing into it.
