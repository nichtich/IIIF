package IIIF;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Exporter;
our @EXPORT_OK = qw(info);

use IPC::Run3;

sub info {
    my $file = shift;

    -f $file or die "$file: No such file\n";
    run3 [ qw(identify -format %Wx%H), $file ], undef, \( my $out );
    ( $out =~ /^(\d+)x(\d+)$/ ) or die "$file: Failed to get image dimensions";

    return {
        '@context' => 'http://iiif.io/api/image/3/context.json',
        type       => 'ImageService3',
        protocol   => 'http://iiif.io/api/image',
        width      => 1 * $1,
        height     => 1 * $1,
        @_
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

IIIF - IIIF Image API implementation

=head1 SYNOPSIS

    use IIIF;

    my $info = IIIF::info($file, profile => "level0", id => "...") ;

=head1 DESCRIPTION

Module IIIF provides an implementation of L<IIIF Image API|https://iiif.io/api/image/3.0/>.

=head1 FUNCTIONS

=head2 info( $file, id => $id, profile => $profile )

Returns L<https://iiif.io/api/image/3.0/#5-image-information|image information>
object with fields C<@context>, C<type>, C<protocol>, C<width>, and C<height>.
C<id> and C<profile> must be added to get full IIIF compliant image information.

=head1 LICENSE

Copyright (C) Jakob Voss.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jakob Voss E<lt>voss@gbv.deE<gt>

=cut

