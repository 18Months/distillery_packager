# Distillery Packager

[![Coverage Status](https://coveralls.io/repos/github/18Months/distillery_packager/badge.svg?branch=master)](https://coveralls.io/github/18Months/distillery_packager?branch=master)
[![Build Status](https://travis-ci.org/18Months/distillery_packager.svg?branch=master)](https://travis-ci.org/18Months/distillery_packager)

Elixir lib for creating Debian and RPM packages with Distillery.

## Features

 1. [x] Able to build Debian packages
     1. [x] With control file
     2. [x] With customizable pre/post install/remove scripts
     3. [x] With capability to add custom files/scripts to the package
 2. [ ] Able to build RPM packages
 3. [x] Automatically builds init scripts, which are all customizable, for:
     1. [x] Systemd
     2. [x] Upstart
     3. [x] SysVinit

## Required OS dependencies

Before using distillery_packager, you'll need the following packages installed and in your path:

 - `tar` (or `gtar` if you're on a mac - you can `brew install gnu-tar` if you don't already have it)
 - `ar`
 - `uname`

## Installation

Add distillery_packager to your list of dependencies in `mix.exs`:

```bash
def deps do
  [{:distillery_packager, "~> 0.4"}]
end
```

## General configuration

Distillery_packager relies on the following data in the `mix.exs` file being set:

```diff
defmodule Testapp.Mixfile do
   use Mix.Project

   def project do
      [app: :testapp,
      version: "0.0.1",
      elixir: "~> 1.4",
+     description: "Elixir lib for creating linux packages with Distillery",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
-     deps: deps()]
+     deps: deps(),
+     deb_package: deb_package()]
   end
```

### Debian package configuration

The `deb_package` function must be set as:

```bash
def deb_package do
   [
      vendor: "18Months S.r.l.",
      maintainers: ["18Months <info@18months.it>"],
      homepage: "https://www.18months.it",
      external_dependencies: [],
      maintainer_scripts: [
         pre_install: "rel/distillery_packager/debian/install_scripts/pre_install.sh",
         post_install: "rel/distillery_packager/debian/install_scripts/post_install.sh",
         pre_uninstall: "rel/distillery_packager/debian/install_scripts/pre_uninstall.sh"
      ]
      config_files: ["/etc/init/.conf"],
      additional_files: [{"configs", "/etc/distillery_packager/configs"}]
      owner: [user: "root", group: "root"]
   ]
end
```

A list of configuration options you can add to `deb_package/0`:

 - `vendor`
   - String
   - The distribution vendor that's creating the debian package. I normally just put my name or company name.
 - `maintainers`
   - Array of Strings
   - Should be in the format `name <email>`
 - `homepage`
   - String
   - Should be in the format `https://www.18months.it`
 - `external_dependencies`
   - Array of Strings
   - Should be in the format of `package-name (operator version_number)` where operator is either `<<`, `<=`, `=`, `>=`, or `>>` - [read more about this here.][1]
 - `maintainer_scripts`
   - A keyword list of Strings
   - The keyword should be one of: `:pre_install`, `:post_install`, `:pre_uninstall`, or `:post_uninstall`
   - The keyword should point to the path of a script you want to run at the moment in question.
 - `config_file`
   - Array of Strings
   - Should contain the absolute path of the config file to be overwritten.
 - `additional_files`
   - List of Tuples
   - Should contain the relative path of the source folder in the first position of the tuple.
     All files present in the source folder will be copied to the destination folder.
   - Should contain the path of the destination folder, relative to the target system where the package will be installed, in the second position of the tuple.
   - Source path here should be specified excluding the base path "rel/distillery_packager/debian/additional_files" in your project.
     A dedicated generator can be used to setup base path, for further details refer to the section below.
 - `owner`
   - A keyword list of Strings
   - If set, requires both `user` and `group` keys to be set.
   - This is used when building the archive to set the correct user and group
   - Defaults to root for user & group.

## Distillery configuration

You can build a deb by adding `plugin DistilleryPackager.Plugin` to your `rel/config.exs` file.

You can also specify target distribution and architecture with `plugin DistilleryPackager.Plugin, %{distribution: "xenial", architecture: "amd64"}`

The name and version is taken from the `rel/config.exs` file.

## Usage

### Base path

You can generate the base path for additional files to be added to the package with:

```bash
mix release.deb.prepare_base_path
```

### Customising deb config files

You can customise the debs that are being built by copying the template files used and modifying them:

```bash
mix release.deb.generate_templates
```

### Build

Packages are build with the `mix release` command built in Distillery.

[1]:https://www.debian.org/doc/manuals/maint-guide/dreq.en.html#control
