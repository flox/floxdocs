# flox documentation

Live at: [flox.dev/docs](https://flox.dev/docs).

## Usage

```
$ flox activate
✔ You are now using the environment 'floxdocs'.

λ (floxdocs) $ flox services start mkdocs
✔ Service 'mkdocs' started.

```
Once mkdocs service started you can preview the documentation at
`https://127.0.0.1:8000`.


## Guidelines

The documentation should follow the divio philosophy
https://documentation.divio.com/ with four clearly distinct approaches. A short
summary:

* **Tutorials**

  *learning oriented*: learn by doing. You are the teacher. It's ok if it's low
  level: get the user started. Provide concrete steps to get a feel for the
  work, and no more (no tangents or digressions).

* **How To's**

  *goal-oriented*: solve a problem, e.g "I want to package my Rust project".
  Don't explain: just do. "A how-to guide should allow for slightly different
  ways of doing the same thing."

* **Reference**

  *information-oriented*: the only job of technical reference is to describe.
  Austere and to the point. Think wikipedia, not a blog. Don't explain concepts
  or expand a discussion. For some developers, the only documentation they ever
  need.

* **Explanation**

  *understanding-oriented*: take a wider view, read this in a comfy armchair
  with a warm drink in hand. Consider things from multiple perspectives, add
  context, explore alternatives. Don't instruct, don't achieve a user's goal.

* Pages go in the `docs/` subdirectory. Do not attempt to represent the logical
  structure of the documentation in the filesystem layout, we've done that
  before and it's a nightmare to reorganize things when you do that.

* Pages referenced from multiple places in the index (e.g. the installation doc
  is referenced from both the getting started and managing sections) should be
  placed in the `include/` subdirectory and referenced from a document within
  the `pages/` subdirectory. Each entry in the documentation index should
  correspond to a single document within the `pages/` subdirectory, and no
  document in the `include/` subdirectory should not be linked directly from
  the index. This is all to prevent the mkdocs navigation from jumping to a
  different section of the index when referencing a page linked from multiple
  places.

* Filenames shall use `-` delimiters in preference to `_`.

* We strive to adopt _Semantic Line Breaks_ as documented in https://sembr.org/

* Avoid injecting trailing whitespace - please configure your editors/IDEs
  accordingly

* We avoid embedding the title in the document itself (as preceded by a single
  "#") so that the title can be governed by the master index in mkdocs.yml.
  The document will inherit the title from the index.


## External link checking

You can run a check for external link breakage with this command

```
$ flox activate -- ./check_links.sh
```

## Update mkdocs-material-insiders archive

```
$ git clone https://github.com/squidfunk/mkdocs-material-insiders
$ python -m env env
$ ./env/bin/pip install --upgrade build twine
$ ./env/bin/python -m build
$ cp dist/mkdocs_material-*.tar.gz path/to/floxdocs
```

