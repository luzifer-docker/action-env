# action-env

Tool image for GitHub Actions jobs. It provides a common environment with
frequently used CI, container, and deployment tools pre-installed.

## Usage

Use the image as the job container in a GitHub Actions workflow:

```yaml
jobs:
  example:
    runs-on: ubuntu-latest

    container:
      image: ghcr.io/luzifer-docker/action-env:master

    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1

      - run: make test
```

For reproducible runs, pin the image to a digest and/or use calver-tags.

## Versioning

In addition to the rolling `master` tag, images are tagged using CalVer in the
format `YYYY.WW.N`, based on the ISO week date. `N` is a counter starting at
zero for each week.

A new CalVer tag is created only when the digest behind `master` has changed
since the latest CalVer tag.
