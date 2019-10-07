package IIIF::Magick;
use 5.014001;

our $VERSION = "0.01";

use Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(info available convert);

use IPC::Cmd qw(can_run);

sub available {
    return can_run("magick") || ( can_run("identify") && can_run("convert") );
}

sub info {
    my $file = shift;

    -f $file or die "$file: No such file\n";
    my $out = run( qw(identify -format %Wx%H), $file );

    ( $out =~ /^(\d+)x(\d+)$/ ) or die "$file: Failed to get image dimensions";

    return {
        '@context' => 'http://iiif.io/api/image/3/context.json',
        type       => 'ImageService3',
        protocol   => 'http://iiif.io/api/image',
        width      => 1 * $1,
        height     => 1 * $2,
        @_
    };
}

sub args {
    my ($req) = @_;

    my @args;

    if ( $req->{region} ne 'full' ) {
        my $crop;
        if ( my $px = $req->{region_px} ) {
            $crop = "$px->[2]x$px->[3]+$px->[0]x$px->[1]";
        }
        push @args, '-crop', $crop if defined $crop;
    }

    return @args;
}

sub convert {
    my ( $req, $in, $out ) = @_;
    run( 'convert', args($req), $in, $out );
    return !$?;
}

# adopted from <https://metacpan.org/release/ShellQuote-Any-Tiny>
sub shell_quote {
    my $arg = shift;

    if ( $^O eq 'MSWin32' ) {
        if ( $arg =~ /\A\w+\z/ ) {
            return $arg;
        }
        $arg =~ s/\\(?=\\*(?:"|$))/\\\\/g;
        $arg =~ s/"/\\"/g;
        return qq("$arg");
    }
    else {
        if ( $arg =~ /\A[\w,_+-]+\z/ ) {
            return $arg;
        }
        $arg =~ s/'/'"'"'/g;
        return "'$arg'";
    }
}

sub run {
    unshift @_, "magick" if can_run("magick");
    my $command = join ' ', map &shell_quote, @_;
    qx{$command};
}

1;
__END__

=head1 SYNOPSIS

    use IIIF::Magick qw(info);

    my $info = info($file, profile => "level0", id => "...") ;

=head1 FUNCTIONS

=head2 available

Returns whether ImageMagick is available.

=head2 info( $file, id => $id, profile => $profile )

Returns L<image information|https://iiif.io/api/image/3.0/#5-image-information>
object with fields C<@context>, C<type>, C<protocol>, C<width>, and C<height>.
Fields C<id> and C<profile> must be added for full IIIF compliance.

=cut
