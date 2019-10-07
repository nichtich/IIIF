package IIIF::Request;
use 5.014001;

our $VERSION = "0.01";

use Plack::Util::Accessor qw(region size rotation quality format);

our $INT    = qr{[0-9]+};                   # also allows 0
our $PCT    = qr{[0-9]+|[0-9]*\.[0-9]+};    # also allows 0 and >100
our $DEGREE = $PCT;
our $REGION   = qr{full|square|($INT,$INT,$INT,$INT)|pct:($PCT,$PCT,$PCT,$PCT)};
our $SIZE     = qr{(\^)?(max|$INT,|,$INT|pct:$PCT|[!]?$INT,$INT)};
our $ROTATION = qr{([!])?($DEGREE)};
our $QUALITY  = qr{color|gray|bitonal|default};
our $FORMAT   = qr{[^.]+};

use overload '""' => \&as_string, fallback => 1;

sub new {
    my ( $class, $path ) = @_;
    my ( $region,     $size,      $rotation, $quality, $format );
    my ( $region_pct, $region_px, $upscale,  $mirror,  $degree );

    my @parts = split '/', $path;

    if ( @parts && $parts[0] =~ /^$REGION$/ ) {
        $region = shift @parts;
        if ($1) {
            $region_px = [ split ',', $1 ];
        }
        elsif ($2) {
            $region_pct = [ split ',', $2 ];
        }
    }

    if ( @parts && $parts[0] =~ /^$SIZE$/ ) {
        $size    = shift @parts;
        $upscale = $1;
    }

    if ( @parts && $parts[0] =~ /^$ROTATION$/ ) {
        $rotation = shift @parts;
        ( $mirror, $degree ) = ( !!$1, $2 );
    }

    if ( @parts && $parts[0] =~ /^(($QUALITY)([.]($FORMAT))?|[.]($FORMAT))$/ ) {
        $quality = $2;
        $format = $4 // $5;
        shift @parts;
    }

    die "invalid IIIF API request: $path" if @parts;

    bless {
        region => $region // 'full',
        region_pct => $region_pct,
        region_px  => $region_px,
        size       => $size // 'max',
        upscale    => $upscale,
        rotation   => $rotation // '0',
        mirror     => $mirror,
        degree     => $degree,
        quality    => $quality // 'default',
        format     => $format
    }, $class;
}

sub as_string {
    my ($self) = @_;

    my $str = join '/', map { $self->{$_} } qw(region size rotation quality);
    return defined $self->{format} ? "$str.$self->{format}" : $str;
}

1;
__END__

=head1 NAME

IIIF::Request - IIIF Image API request object

=head1 SYNOPSIS

    use IIIF::Request;

    my $request = IIIF::Request->new('125,15,120,140/90,/!345/gray.jpg');

=head1 DESCRIPTION

Stores the part of an IIIF Image API URL after C<{identifier}>:

    {region}/{size}/{rotation}/{quality}.{format}

In contrast to the IIIF Image API Specification, all parts are optional.
Omitted parts are set to their default value except for C<format> which may be
undefined. In addition, the following fields may be set:

=over

=item region_pct 

=item region_px

=item upscale

=item mirror

=item degree

=back

=head1 METHODS

=head2 new( [ $request ] )

Parses a request string. It's ok to only include selected image manipulations.

=head2 as_string

Returns the full request string.

=cut
