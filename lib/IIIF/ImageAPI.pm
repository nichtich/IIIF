package IIIF::ImageAPI;
use 5.014001;

our $VERSION = "0.01";

use parent 'Plack::Component';
use Plack::Util::Accessor qw(root);

use IIIF::Magick qw(info convert);
use File::Spec;
use Try::Tiny;
use Plack::Request;
use IIIF::Request;
use JSON::PP;
use File::Temp qw(tempdir);
use HTTP::Date;
use Plack::MIME;
use Cwd;
use Plack::Util;

our $TEMPDIR = tempdir( CLEANUP => 1 );

sub call {
    my ( $self, $env ) = @_;
    my $req = Plack::Request->new($env);

    my $path = $req->path_info;

    if ( $path =~ qr{^/([^/]+)/?(.*)$} ) {
        my ( $identifier, $local ) = ( $1, $2 );

        if ( my $file = $self->file($identifier) ) {
            my $id = $req->base . $identifier;

            if ( $local eq '' ) {
                return [ 303, [ Location => $id . '/info.json' ], [] ];
            }
            elsif ( $local eq 'info.json' ) {
                my $info = info( $file, protocol => 'level0', id => $id );
                return json_response( $info, 200,
'application/ld+json;profile="http://iiif.io/api/image/3/context.json'
                );
            }
            else {
                # TODO: avoid convert if unmodified
                # TODO: add caching
                my $tmpfile = File::Spec->catfile( $TEMPDIR, "xxx.png" );
                my $image_request = IIIF::Request->new($local);
                if ( convert( $image_request, $file, $tmpfile ) ) {
                    return image_response($tmpfile);
                }
                else {
                    return error_response( 500, "Conversion failed" );
                }
            }
        }
    }

    return error_response( 404, "Not Found" );
}

# adopted from Plack::App::File
sub image_response {
    my ($file) = @_;

    open my $fh, "<:raw", $file
      or return error_response( 403, "Forbidden" );

    my $content_type = Plack::MIME->mime_type($file) || 'text/plain';

    my @stat = stat $file;

    Plack::Util::set_io_path( $fh, Cwd::realpath($file) );

    return [
        200,
        [
            'Content-Type'   => $content_type,
            'Content-Length' => $stat[7],
            'Last-Modified'  => HTTP::Date::time2str( $stat[9] )
        ],
        $fh,
    ];
}

sub file {
    my ( $self, $identifier ) = @_;

    my $root = $self->root // '.';

    for my $format (qw(png jpg gif)) {
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
