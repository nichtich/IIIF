package IIIF::ImageAPI;
use 5.014001;

our $VERSION = "0.01";

use parent 'Plack::Component';
use Plack::Util::Accessor qw(root);

use IIIF::Magick qw(info);
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
                my $info = info( $file, protocol => 'level0', id => $id );
                return json_response( $info, 200,
'application/ld+json;profile="http://iiif.io/api/image/3/context.json'
                );
            }
            else {
                # TODO
            }
        }
    }

    return error_response( 404, "Not Found" );
}

sub file {
    my ( $self, $identifier ) = @_;

    my $root = $self->root // '.';

    for my $format (qw(png jpg)) {
        my $file = File::Spec->catfile( $root, "$identifier.$format" );
        return $file if -f $file;
    }
}

sub error_response {
    my ( $code, $message ) = @_;

    json_response( { message => $message }, $code );
}

sub json_response {
    my ( $body, $code, $type ) = @_;

    state $JSON = JSON::PP->new->pretty->canonical(1);

    [
        $code // 200,
        [ 'Content-Type' => $type // 'application/json' ],
        [ $JSON->encode($body) ]
    ];
}

1;

=head1 SYNOPSIS

    plackup -Ilib -MIIIF::ImageAPI -e 'IIIF::ImageAPI->new(root => "t/img")'

=cut
