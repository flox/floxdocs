---
title: Python
description: Common questions and solutions for using Python with Flox
---

# Python

This provides an overview of how to create Flox environments for new or existing Python projects.

## Using Flox in a new project

Getting started with Flox is super simple. First, create and/or `cd` into your project directory.

```{ .sh .copy }
mkdir new-python-project && cd new-python-project
```

Next, initialize your Flox environment:

```{ .sh .copy }
flox init
```

This will suggest a few commands you can run next:

```console
$ flox init
⚡︎ Created environment 'new-python-project' (x86_64-linux)

Next:
  $ flox search <package>    <- Search for a package
  $ flox install <package>   <- Install a package into an environment
  $ flox activate            <- Enter the environment
  $ flox edit                <- Add environment variables and shell hooks
```

This Flox environment is now ready to be populated with packages.

### Select a Python interpreter

To begin, we need a Python interpreter. For this example, we will be using Python 3.11. Search for the version of Python your project requires, omitting the dot between major and minor numbers:

```{ .sh .copy }
flox search python311
```

This will show you the list of packages matching the major and minor version of Python you specified:

```console
$ flox search python311
python311      High-level dynamically-typed programming language
python311Full  High-level dynamically-typed programming language

Use 'flox show <package>' to see available versions
```

To see the specific versions of Python available in the Flox Catalog, use the `flox show` command:

```{ .sh .copy }
flox show python311Full
```

This will list all of the releases that match the major and minor numbers you provided:

```console
$ flox show python311Full
python311Full - High-level dynamically-typed programming language
    python311Full@python3-3.11.9
    python311Full@python3-3.11.8
    python311Full@python3-3.11.7
    python311Full@python3-3.11.6
    python311Full@python3-3.11.5
    python311Full@python3-3.11.4
    python311Full@python3-3.11.3
    python311Full@python3-3.11.2
    python311Full@python3-3.11.1
```

At this point, you can install the latest version by running `flox install` without a version specified:

```{ .sh .copy }
flox install python311Full
```

This will show a message indicating the package was successfully installed:

```console
$ flox install python311Full
✔ 'python311Full' installed to environment 'new-python-project'
$ flox list
python311Full: python311Full (python3-3.11.9)
```

When `flox upgrade` is run in this environment, the version of Python will be upgraded to the latest version available in the catalog matching those major and minor numbers. If you wish to pin your Flox environment to a specific release of Python, you can specify it in the `flox install` command:

```{ .sh .copy }
flox install python311Full@python3-3.11.3
```

### Add Python packages

Python projects often require a collection of packages in addition to an interpreter. Often these are installed using `pip`, but they can also be acquired from the Flox Catalog. This will allow them to be locked in the Flox Manifest alongside the other packages in your environment.

To find these Python packages in the Flox Catalog, use the same `flox search` syntax from before:

```{ .sh .copy }
flox search numpy
```

This will return the set of packages that match your search term:

```console
$ flox search numpy
[...]
python311Packages.numpy    Scientific tools for Python
[...]
```

Python packages will have a prefix of `pythonXXXPackages.` in their package name, with `XXX` matching the version of Python you have installed into your environment. To install them, use the entire package name including the prefix:

```{ .sh .copy }
flox install python311Packages.numpy python311Packages.pandas
```

You will see output indicating that the packages were successfully installed. If installation was not successful, you should see an error message indicating the failure:

```console
$ flox install python311Packages.numpy python311Packages.pandas
✔ 'numpy' installed to environment 'new-python-project'
✔ 'pandas' installed to environment 'new-python-project'
```

### Activate the new environment

Once the packages have been installed, activate the new environment:

```{ .sh .copy }
flox activate
```

This will put you into a new subshell with your environment active:

```console
$ flox activate
✔ You are now using the environment 'new-python-project'.
To stop using this environment, type 'exit'

flox [new-python-project] $
```

## Using Flox in an existing project

If you are working with an existing project that is already configured for Python - e.g. it has a `requirements.txt` or `pyproject.toml` - Flox provides an automated environment setup flow.

For this example we will clone the `eralchemy` repo, which already contains Python configuration:

```{ .sh .copy }
git clone https://github.com/eralchemy/eralchemy.git && cd eralchemy
```

### Auto-initialize the environment

Once inside the `eralchemy` project directory, initialize a new Flox environment:

```{ .sh .copy }
flox init
```

You will see the following question in the output:

```console
$ flox init
Flox detected a Python project with the following Python provider(s):

* pyproject (generic pyproject.toml)

  Installs python (3.12.5) with pip bundled.
  Adds a hook to setup a venv.
  Installs the dependencies from the pyproject.toml to the venv.

! Would you like Flox to set up a standard Python environment?
You can always change the environment's manifest with 'flox edit'
  Yes - with pyproject
  No
> Show suggested modifications
[Use '--auto-setup' to apply Flox recommendations in the future.]
```

When you initialize Flox and it finds a `pyproject.toml` or `requirements.txt` file inside a project directory, it automatically runs this wizard.

Here's what each option does:

- “Yes” builds the environment using the `pyproject.toml` file;
- “No” skips automatic setup. You can use `pip` or `poetry` with `pyproject.toml` to build your environment;
- “Show” previews the configuration you'd get by selecting “Yes,” allowing you to vet your environment's setup.

If you would like to preview the proposed changes, you can choose the "Show" option. It will show you the proposed changes to each section of your environment manifest, e.g.:

```console
> Show suggested modifications for pyproject
[Use '--auto-setup' to apply Flox recommendations in the future.]


[install]
python3.pkg-path = "python3"
python3.version = ">=3.8"

[hook]
on-activate = '''
  # Setup a Python virtual environment

  export PYTHON_DIR="$FLOX_ENV_CACHE/python"
  if [ ! -d "$PYTHON_DIR" ]; then
    echo "Creating python virtual environment in $PYTHON_DIR"
    python -m venv "$PYTHON_DIR"
  fi

  # Quietly activate venv and install packages in a subshell so
  # that the venv can be freshly activated in the profile section.
  (
    source "$PYTHON_DIR/bin/activate"
    # install the dependencies for this project based on pyproject.toml
    # <https://pip.pypa.io/en/stable/cli/pip_install/>
    pip install -e . --quiet
  )
'''

[profile]
bash = '''
  echo "Activating python virtual environment" >&2
  source "$PYTHON_DIR/bin/activate"
'''
fish = '''
  echo "Activating python virtual environment" >&2
  source "$PYTHON_DIR/bin/activate.fish"
'''
tcsh = '''
  echo "Activating python virtual environment" >&2
  source "$PYTHON_DIR/bin/activate.csh"
'''
zsh = '''
  echo "Activating python virtual environment" >&2
  source "$PYTHON_DIR/bin/activate"
'''
```

If you choose “Yes” to accept this configuration, you can edit or customize it once Flox finishes building just by typing `flox edit`. For future projects, you can automate this setup process for Python environments by running:

```{ .sh .copy }
flox init --auto-setup
```

### Add system packages

The only dependency from `pyproject.toml` that Flox did not install for us is [Graphviz](https://graphviz.org/), an open source tool for creating and visualizing graphs.

To do this, we could run `flox edit` and add `graphviz` to the `[install]` section of our environment's software manifest, but it's just as easy to install it from the command line. So let’s do that instead:

```{ .sh .copy }
flox install graphviz
```

Now it's time to put this environment through its paces.

### Activate and verify the environment

First let's activate the environment:

```{ .sh .copy }
flox activate
```

You should see output indicating that the Python virtual environment has been created:

```console
$ flox activate
✔ You are now using the environment 'eralchemy'.
To stop using this environment, type 'exit'

Creating python virtual environment in /home/floxfan/eralchemy/.flox/cache/python
Activating python virtual environment
```

At this point, the version of `eralchemy` is available within your environment.

```console
(python) flox [eralchemy] $ which eralchemy
/home/floxfan/eralchemy/.flox/cache/python/bin/eralchemy
```

## Build with Flox

Not only can you _develop_ your software with Flox, but you can _build_ it as well.
See the [builds][build-concept] concept page for more details.

### Manifest builds

#### Pip

For Python projects using `pip`, a build looks like installing the project to the `$out` directory.

```toml
[build.myproject]
command = '''
  pip install --target=$out .
'''
```

Note the trailing `.` to indicate that you're installing the package in the
current directory.
If you're working in a repository with multiple packages in subdirectories,
you would replace `.` with the path to the package sources.

#### Poetry

For Poetry and tools that create a virtual environment for you, a build entails installing the virtual environment to `$out`.
Poetry in particular does not allow you to choose the location (or name) of the virtual environment directory itself, but it does allow you to configure the _parent_ directory of the virtual environment.
The build command shown below uses environment variables to tell Poetry to use the `$out` directory as the parent of the virtual environment.
After running `poetry install` you should have a directory structure that looks like this:

```console
$out/
  myproject-<hash>-py3.12/
    ...
```

Since Poetry doesn't let you decide where _exactly_ this virtual environment belongs, you need to symlink any executables from the virtual environment into the `$out/bin` directory yourself to ensure that the build output adheres to the Filesystem Hierarchy Standard (FHS).
You also need to install a Python interpreter and add it to `runtime-packages` so that the virtual environment can reference it.

The full manifest for a build using Poetry is shown below:

```toml
version = 1

[install]
python3.pkg-path = "python3"
python3.version = ">=3.12"
poetry.pkg-path = "poetry"

[build.myproject]
command = '''
  # Install to a new virtualenv.
  export POETRY_VIRTUALENVS_PATH=$out
  export POETRY_VIRTUALENVS_IN_PROJECT=false
  export POETRY_VIRTUALENVS_OPTIONS_NO_PIP=true
  poetry install

  # Symlink any executables from the virtualenv.
  mkdir -p "${out}/bin"
  cd $out/bin
  ln -s ../*/bin/myproject .
'''
runtime-packages = [
  "python3",
]
```

[build-concept]: ../concepts/builds.md
