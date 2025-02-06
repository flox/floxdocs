---
title: Python
description: Common questions and solutions for using Python with Flox
---

# Python

This provides an overview of how to create Flox environments for new or existing Python projects.

## Using Flox in a new project

Getting started with Flox is super simple. First, create and/or `cd` into your project directory.

```
mkdir new-python-project && cd new-python-project
```

Next, initialize your Flox environment:

```
flox init
```

This will suggest a few commands you can run next:

```
$ flox init
✨ Created environment 'new-python-project' (x86_64-linux)

Next:
  $ flox search <package>    <- Search for a package
  $ flox install <package>   <- Install a package into an environment
  $ flox activate            <- Enter the environment
  $ flox edit                <- Add environment variables and shell hooks
```

This Flox environment is now ready to be populated with packages.

### Select a Python interpreter

To begin, we need a Python interpreter. For this example, we will using Python 3.11. Search for the version of Python your project requires:

```
flox search python311
```

This will show you the list of packages matching the major and minor version of Python you need:

```
$ flox search python311
python311      High-level dynamically-typed programming language
python311Full  High-level dynamically-typed programming language

Use 'flox show <package>' to see available versions
```

To see the specific versions of Python available in the Flox Catalog, use the `flox show` command:

```
flox show python311Full
```

This will list all of the releases that match the major and minor numbers you provided:

```
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

```
flox install python311Full
```

This will show a message indicating the package was successfully installed:

```
$ flox install python311Full
✅ 'python311Full' installed to environment 'new-python-project'
$ flox list
python311Full: python311Full (python3-3.11.9)
```

When `flox upgrade` is run in this environment, the version of Python will be upgraded to the latest version available in the catalog. If you wish to pin your Flox environment to a specific version of Python, you can specify it in the `flox install` command:

```
flox install python311Full@python3-3.11.3
```

### Add Python packages

Python projects often require a collection of packages in addition to an interpreter. Often these are installed using `pip`, but they can also be acquired from the Flox Catalog. This will allow them to be locked in the Flox Manifest alongside the other packages in your environment.

To find these Python packages in the Flox Catalog, use the same `flox search` syntax from before:

```
flox search numpy
```

This will return the set of packages that match your search term:

```
$ flox search numpy
[...]
python311Packages.numpy    Scientific tools for Python
[...]
```

Python packages will have a prefix of `pythonXXXPackages.` in their package name. To install them, use the entire package name including the prefix:

```
flox install python311Packages.numpy python311Packages.pandas
```

You will see output indicating that the packages were successfully installed. If installation was not successful, you should see an error message indicating the failure.

```
$ flox install python311Packages.numpy python311Packages.pandas
✅ 'numpy' installed to environment 'new-python-project'
✅ 'pandas' installed to environment 'new-python-project'
```

### Activate and verify packages

Once the packages have been installed, activate the new environment:

```
flox activate
```

This will put you into a new subshell with your environment active:

```
$ flox activate
✅ You are now using the environment 'new-python-project'.
To stop using this environment, type 'exit'

flox [new-python-project] $
```

## Using Flox in an existing project

If you are working with an existing project that is already configured to work with Python - e.g. it has a `requirements.txt` or `pyproject.toml` - Flox provides an automated environment setup flow.

For this example we will clone the `eralchemy` repo, which already contains Python configuration:

```
git clone https://github.com/eralchemy/eralchemy.git && cd eralchemy
```

### Auto-initialize the environment

Once inside `eralchemy`s project directory, initialize a new Flox environment:

```
flox init
```

You will see the following question in the output:

```
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
- “Show” previews the configuration you'd get by selecting “Yes,” letting you vet your environment's setup.

And here's what happens if you choose the “Show” option:

```
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

If you choose “Yes” to accept this configuration, you can edit or customize it once Flox finishes building just by typing `flox edit`. And you can automate the setup process for Python environments just by running:

```
flox init --auto-setup
```

### Add system packages

The only dependency from `pyproject.toml` that Flox did not install for us is [Graphviz](https://graphviz.org/), an open source tool for creating and visualizing graphs.

To do this, we could `flox edit` and add `graphviz` to the `[install]` section of our environment's software manifest, but it's just as easy to install it from the command line. So let’s do that.

```
flox install graphviz
```

Now it's time to put this environment through its paces.

### Activate and verify the environment

First let's activate the environment:

```
flox activate
```

You should see output indicating that the Python virtual environment has been created:

```
$ flox activate
✅ You are now using the environment 'eralchemy'.
To stop using this environment, type 'exit'

Creating python virtual environment in /home/floxfan/eralchemy/.flox/cache/python
Activating python virtual environment
```

At this point, the version of `eralchemy` is available within your environment.

```
(python) flox [eralchemy] $ which eralchemy
/home/floxfan/eralchemy/.flox/cache/python/bin/eralchemy
```
