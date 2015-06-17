# grunt-bower-link-snapshot

> Grunt Task: tag linked bower components into bower.json for build servers

## Getting Started
This plugin requires Grunt `~0.4.5`

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```shell
npm install grunt-bower-link-snapshot --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('grunt-bower-link-snapshot');
```

## The "bower_link_snapshot" task

### Project Setup

When developing bower components for use across multiple projects, it is common to use 'bower link' to symlink a dev copy. http://bower.io/docs/api/#link

The problem comes when uploading your package to a build server, your working copy is ahead of the copy which will be used to build the project.

This solution

- Ensure the latest changes to the bower component are committed (if not, throws)
- Ensure the latest commit has a tag (if not, bumps a minor version)
- Update the project's bower.json to reflect the concrete tagged versions.

It does not

- commit or push changes
- 'bower unlink' the component - you keep the symlinked version for dev

Issues

- Should check if the bower components are linked or installed - noop on installed
- Should accept CLI parameters for the version bump
- Uses the CLI tools for grunt and bower.
- Manually re-writes the bower.json file, should use the bower js code.
- No tests, no build step, CS and JS committed together

Ideas for configurable extensions

- git push --tags after bumping


This really only works on your dev machine, don't include it in a tool-chain on a build server.

### Overview
In your project's Gruntfile, add a section named `bower_link_snapshot` to the data object passed into `grunt.initConfig()`.

```js
grunt.initConfig({
  bower_link_snapshot: {
    options: {
      packages: ["package_a", "package_b"] 
    },
    your_target: {
      // Target-specific file lists and/or options go here.
    },
  },
});
```

