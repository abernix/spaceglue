[![Circle CI](https://circleci.com/gh/abernix/spaceglue/tree/master.svg?style=svg)](https://circleci.com/gh/abernix/meteord/tree/master)
# SpaceGlue

Another Docker image for Meteor

#### Low-Memory Environment

If your app is running in low memory environment, the default garbage collection settings of node can lead to out-of-memory crashes even when there are no leaks.
To fix that and for other diagnosis purposes, you can expose `NODE_OPTIONS` as environment variable and pass whatever is supported.

Example: `-e NODE_OPTIONS=--max-old-space-size=150` sets the heap limit before gc is aggressively freeing up memory to 150 MB instead of 1500 MB.
For more information on the available options, run: `node --v8-options` or `node -h`.


