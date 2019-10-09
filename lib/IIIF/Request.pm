package IIIF::Request;
use 5.014001;

our $VERSION = "0.01";

use Plack::Util::Accessor qw(region size rotation quality format);

our $XY = qr{[0-9]+};         # non-negative integer
our $WH = qr{[1-9][0-9]*};    # positive integer
our $PC = qr{[1-9][0-9]?(\.[0-9]+)?|0?\.[0-9]*[1-9][0-9]*|100(\.0+)?}; # >0..100
our $REGION = qr{full|square|($XY,$XY,$WH,$WH)|pct:($PC,$PC,$PC,$PC)};
our $FLOAT = qr{[0-9]*(\.[0-9]+)?};    # non-negative
our $SIZE     = qr{(\^)?(max|pct:($FLOAT)|($WH,)|(,$WH)|(!)?($WH,$WH))};
our $ROTATION = qr{([!])?($FLOAT)};
our $QUALITY  = qr{color|gray|bitonal|default};
our $FORMAT   = qr{[^.]+};

use overload '""' => \&as_string, fallback => 1;

sub new {
    my $class = shift;
    my $path = shift // "";

    my ( $rotation, $mirror, $degree, $quality, $format );
    my ( $region, $region_pct, $region_px );
    my ( $size, $upscale, $size_px, $size_pct, $limit );

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
        $limit   = $6;
        $size_px = $4 // $5 // $7;

        if ( defined $3 ) {
            $size_pct = 1 * $3;
            if ($upscale) {
                $size = "^pct:$size_pct";
            }
            else {
                die "invalid percentage in IIIF API request: $path"
                  if $size_pct == 0.0 || $size_pct > 100.0;
                $size = "pct:$size_pct";
            }
        }
    }

    if ( @parts && $parts[0] =~ /^$ROTATION$/ ) {
        shift @parts;
        $mirror = !!$1;

        # normalize to 0...<360 with up to 6 decimal points
        $degree = 1 * sprintf( "%.6f", $2 - int( $2 / 360 ) * 360 );
        $rotation = $mirror ? "!$degree" : "$degree";
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
        size_pct   => $size_pct,
        size_px    => $size_px,
        limit      => $limit,
        rotation   => $rotation // '0',
        mirror     => $mirror,
        degree     => $degree,
        quality    => $quality // 'default',
        format     => $format
    }, $class;
}

sub is_default {
    my ($self) = @_;

    return $self->as_string =~ qr{^full/max/0/default\.};
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

=item size_pct

=item size_px

=item limit

=item mirror

=item degree

=back

=head1 METHODS

=head2 new( [ $request ] )

Parses a request string. It's ok to only include selected image manipulations.

=head2 as_string

Returns the full request string.

=head2 is_default

Returns whether the request (without format) is the default request
C<full/max/0/default> to get an unmodified image.

=cut
