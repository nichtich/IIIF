package IIIF;
use 5.014001;

our $VERSION = "0.01";

1;
__END__

=encoding utf-8

=head1 NAME

IIIF - IIIF Image API implementation

=begin markdown 

[![Linux Build Status](https://travis-ci.com/nichtich/IIIF.svg?branch=master)](https://travis-ci.com/nichtich/IIIF)
[![Windows Build Status](https://ci.appveyor.com/api/projects/status/dko0d7647jvfgu8w?svg=true)](https://ci.appveyor.com/project/nichtich/iiif)
[![Coverage Status](https://coveralls.io/repos/nichtich/IIIF/badge.svg)](https://coveralls.io/r/nichtich/IIIF)
[![Kwalitee Score](http://cpants.cpanauthors.org/dist/IIIF.png)](http://cpants.cpanauthors.org/dist/IIIF)

=end markdown

=head1 DESCRIPTION

Module IIIF provides an implementation of L<IIIF Image API|https://iiif.io/api/image/3.0/>.

The implementation is based on L<ImageMagick|https://www.imagemagick.org/> to be installed.

=head1 MODULES

=over

=item L<IIIF::Magick>

=item L<IIIF::Request>

=item L<IIIF::ImageAPI>

=back

=head1 LICENSE

Copyright (C) Jakob Voss.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jakob Voss E<lt>voss@gbv.deE<gt>

=cut

