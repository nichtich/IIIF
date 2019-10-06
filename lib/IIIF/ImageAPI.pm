package IIIF::ImageAPI;
use 5.014001;

our $VERSION = "0.01";

use parent 'Plack::Component';
use Plack::Util::Accessor qw(root);

use IIIF;
use File::Spec;
use Try::Tiny;
use Plack::Request;
use JSON::PP;

sub call {
    my ( $self, $env ) = @_;
    my $req = Plack::Request->new($env);

    my $path = $req->path_info;    # /identifier/...
    if ( $path =~ qr{^/([^/]+)(.*)} ) {
        my ( $identifier, $local ) = ( $1, $2 );

        if ( my $file = $self->file($identifier) ) {
            my $id = $req->base . $identifier;

            if ( $local =~ qr{^/?$} ) {
                return [ 303, [ Location => $id . '/info.json' ], [] ];
            }
            elsif ( $local eq '/info.json' ) {
                my $info = IIIF::info( $file, protocol => 'level0', id => $id );
                return info_response($info);
            }
            else {
                # TODO
            }
        }
    }

    return http_response_404();
}

sub file {
    my ( $self, $identifier ) = @_;

    my $root = $self->root // '.';

    for my $format (qw(png jpg)) {
        my $file = File::Spec->catfile( $root, "$identifier.$format" );
        return $file if -f $file;
    }
}

sub info_response {
    state $JSON = JSON::PP->new->pretty;

    [
        200,
        [
            'Content-Type' =>
'application/ld+json;profile="http://iiif.io/api/image/3/context.json'
        ],
        [ $JSON->encode(@_) ]
    ];
}

sub http_response_404 {
    [
        404,
        [
            'Content-Type'   => 'text/plain',
            'Content-Length' => 12,
        ],
        ['404 Not Found']
    ];
}

1;

=head1 SYNOPSIS

    plackup -Ilib -MIIIF::ImageAPI -e 'IIIF::ImageAPI->new(root => "t/img")'

=cut
