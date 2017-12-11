[![Circle CI](https://circleci.com/gh/abernix/spaceglue/tree/node-4.8.6.svg?style=svg)](https://circleci.com/gh/abernix/spaceglue/tree/node-4.8.6)
# SpaceGlue

A Docker image for Meteor.  Intended to work independently but also as a drop-in image for [Zodern's (_previously Kardira's_) Meteor Up](https://github.com/zodern/meteor-up) (not the `meteorhacks` version or "MupX" though!)

Due to Docker caching layers, and an aggressive attempt for ease-of-use, the resulting images are **offensively large**.  Maybe not the most offensive you've ever seen, but certainly far from a "*micro*service" image.   This SpaceGlue branch was ultimately an attempt to have an easier to maintain structure for the original [MeteorD image](https://github.com/kadirahq/meteord) so I could more rapidly release updates to [Node.js](https://nodejs.org) (with auto-CI builds, tests, pushes, etc.).  It accomplished that.  However, you should consider other, more efficient Docker images if it's a concern to you or look into something like [docker-squash](https://github.com/jwilder/docker-squash) (maybe? dunno.).  It might not be a huge deal if you have a fast upstream (to upload new images) and your container host can quickly move around larger images (it probably can) and you don't get charged too much for storing the images (it's possible).

## Supported tags

Please see the explanation of the [tag variations](#tag-variations) (e.g. `-builddeps`, `-onbuild`) below.

### Node 4 (Meteor 1.4+)

#### Node 4.8.6

* `node-4`, `node-4.8.6`
* `node-4-builddeps`, `node-4.8.6-builddeps`
* `node-4-onbuild`, `node-4.8.6-onbuild`

#### Node 4.8.4

* `node-4.8.4`
* `node-4.8.4-builddeps`
* `node-4.8.4-onbuild`

#### Node 4.8.0

* `node-4.8.0`
* `node-4.8.0-builddeps`
* `node-4.8.0-onbuild`

#### Node 4.7.2

* `node-4.7.2`
* `node-4.7.2-builddeps`
* `node-4.7.2-onbuild`

#### Node 4.7.0

* `node-4.7.0`
* `node-4.7.0-builddeps`
* `node-4.7.0-onbuild`

#### Node 4.6.2

* `node-4.6.2`
* `node-4.6.2-builddeps`
* `node-4.6.2-onbuild`

## Usage

### Standalone

0. Add a `Dockerfile` to the root of your Meteor app that uses this image:

        FROM abernix/spaceglue:node-4-onbuild

0. `docker build .`

0. Run the new image!

    You can run it however you would normally run a Docker image.  Maybe on a Container service or just using `docker run` – how ever you'd like.

    Be sure to set any environment variables that Meteor would normally need, like:

    * `MONGO_URL`
    * `ROOT_URL`
    * `METEOR_SETTINGS`

### Meteor Up ([website](https://github.com/zodern/meteor-up))

This will only work with the newest `mup` which is the one provided in the `zodern` GitHub organization.  If your project uses `mup.json` (note the `.json` extension!), you are using an old version and should update to one that uses the one which uses the `mup.js` format.

**It will not work with the original `meteorhacks` Mup, nor will it work with the MupX branch!**

0. Set two `docker` settings in your `mup.js`.

    * `image: 'abernix/spaceglue:node-4-onbuild'`
    * `imagePort: 3000`

    If you don't already have a `docker` setting, you need to add it in the `meteor` object:

    ```js
    module.exports = {
      servers: {
        // existing server stuff here.
      },

      meteor: {
        name: 'app', // your app may vary
        path: '../app',

        // This is the section you need to add/modify
        docker: {
          image: 'abernix/spaceglue:node-4-builddeps',
          imagePort: 3000,
        },

        // other settings, which may have already been there!
      },

      // more settings, like mongo...maybe? depends if it was already there!
      mongo: {
        // see docs.
      },
    };
    ```

0. `mup deploy`

## Tag Variations

There are three variations of each major Node-based release.

* "Base" (No tag suffix)
* `-builddeps`
* `-onbuild`

### Base (No tag suffix)
You probably can't use this.  This image is suitable if you have NO binary dependencies in your project (honestly, you probably have some) OR if you're running your `meteor build` on the same architecture as this image, meaning no recompilation of said binary dependencies will be necessary.  This means that you need to be running Debian Jessie 64-bit, but you might get away with others.

This can be used with [Meteor Up](https://github.com/kadirahq/meteor-up), but only if the above requirement is met.  You probably want the next image though.

### with Build Dependencies `-builddeps`
This image comes with the build dependencies needed to recompile your binary dependencies.  This is necessary when you are running `meteor build` on one platform/architecture, but deploying to another.

If you're using [Meteor Up](https://github.com/kadirahq/meteor-up) this is probably the image you want.

### Built in Docker `-onbuild`
If your intention is to build a Docker image straight out of your repo, then this is the image for you.  You can basically create a `Dockerfile` with `FROM abernix/spaceglue:node-4-onbuild` and run `docker build .` and you'll get an image that is ready to deploy.

## Advanced Configuration Environment Variables

### With Docker

To set these when using `docker run`, pass along a `-e NAME=VALUE` argument for the setting you'd like to use.

### With Meteor Up

To set these when using Meteor Up, add an enter to the `env` section of the `meteor` object in your `mup.js`.  This will be where you already have your `ROOT_URL`, `MONGO_URL`, etc.:

```js
  env: {
    ROOT_URL: 'http://app.com',
    // Add it here!
    NAME: 'VALUE',
  },
```

#### `NODE_OPTIONS`

This can be used for various settings that will be passed to `node`.  Some are outlined below, but run: `node --v8-options` or `node -h` to see all possible options.  These might include:

##### Low-Memory Environment

If your app is running in low memory environment, the default garbage collection settings of node can lead to out-of-memory crashes even when there are no leaks.

Setting `NODE_OPTIONS` to `--max-old-space-size=150` sets the heap limit before garbage-collection begins aggressively freeing up memory to 150 MB instead of 1500 MB (the default).


