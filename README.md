# NAME

IIIF - IIIF Image API implementation

[![Linux Build Status](https://travis-ci.com/nichtich/IIIF.svg?branch=master)](https://travis-ci.com/nichtich/IIIF)
[![Windows Build Status](https://ci.appveyor.com/api/projects/status/dko0d7647jvfgu8w?svg=true)](https://ci.appveyor.com/project/nichtich/iiif)
[![Coverage Status](https://coveralls.io/repos/nichtich/IIIF/badge.svg)](https://coveralls.io/r/nichtich/IIIF)
[![Kwalitee Score](http://cpants.cpanauthors.org/dist/IIIF.png)](http://cpants.cpanauthors.org/dist/IIIF)

# SYNOPSIS

    use IIIF;

    my $info = IIIF::info($file, profile => "level0", id => "...") ;

# DESCRIPTION

Module IIIF provides an implementation of [IIIF Image API](https://iiif.io/api/image/3.0/).

The implementation is based on [ImageMagick](https://www.imagemagick.org/) to be installed.

# FUNCTIONS

## info( $file, id => $id, profile => $profile )

Returns [image information](https://iiif.io/api/image/3.0/#5-image-information)
object with fields `@context`, `type`, `protocol`, `width`, and `height`.
Fields `id` and `profile` must be added for full IIIF compliance.

## available

Returns whether implementation will not throw an error because of missing ImageMagick.

# LICENSE

Copyright (C) Jakob Voss.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Jakob Voss <voss@gbv.de>
