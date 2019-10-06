# NAME

IIIF - IIIF Image API implementation

# SYNOPSIS

    use IIIF;

    my $info = IIIF::info($file, profile => "level0", id => "...") ;

# DESCRIPTION

Module IIIF provides an implementation of [IIIF Image API](https://iiif.io/api/image/3.0/).

# FUNCTIONS

## info( $file, id => $id, profile => $profile )

Returns [https://iiif.io/api/image/3.0/#5-image-information](https://metacpan.org/pod/image&#x20;information)
object with fields `@context`, `type`, `protocol`, `width`, and `height`.
`id` and `profile` must be added to get full IIIF compliant image information.

# LICENSE

Copyright (C) Jakob Voss.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Jakob Voss <voss@gbv.de>

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 53:

    alternative text 'https://iiif.io/api/image/3.0/#5-image-information' contains non-escaped | or /
