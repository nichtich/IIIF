package IIIF;
use 5.014001;

our $VERSION = "0.01";

use Exporter;
our @EXPORT_OK = qw(info available);

use IPC::Cmd;
use IPC::Run3;

sub available {
    return IPC::Cmd::can_run "identify";
}

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

    my $info = IIIF::info($file, profile => " level0 ", id => " ... ") ;

=head1 DESCRIPTION

Module IIIF provides an implementation of L<IIIF Image API|https://iiif.io/api/image/3.0/>.

The implementation is based on L<ImageMagick|https://www.imagemagick.org/> to be installed.

=head1 FUNCTIONS

=head2 info( $file, id => $id, profile => $profile )

Returns L<image information|https://iiif.io/api/image/3.0/#5-image-information>
object with fields C<@context>, C<type>, C<protocol>, C<width>, and C<height>.
Fields C<id> and C<profile> must be added for full IIIF compliance.

=head2 available

Returns whether implementation will not throw an error because of missing ImageMagick.

=head1 LICENSE

Copyright (C) Jakob Voss.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jakob Voss E<lt>voss@gbv.deE<gt>

=cut

