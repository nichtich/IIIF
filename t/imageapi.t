use strict;
use Test::More 0.98;
use Plack::Test;
use HTTP::Request::Common;
use IIIF::Magick;
use IIIF::ImageAPI;

plan skip_all => "ImageMagick missing" unless IIIF::Magick::available();

my $app = IIIF::ImageAPI->new(root => 't/img');
my $identifier = "67352ccc-d1b0-11e1-89ae-279075081939";

test_psgi $app, sub {
    my ($cb, $res) = @_;
    is $cb->(GET "/")->code, "404", "/";

    # Image Information Request
    $res = $cb->(GET "/$identifier");
    is $res->code, 303, "/{identifier}";
    $res = $cb->(GET "/$identifier/");
    is $res->code, 303, "/{identifier}/";
    is $res->header('Location'), "http://localhost/$identifier/info.json";

    $res = $cb->(GET "/$identifier/info.json");
    is $res->code, 200, "/{identifier}/info.json";

    # Image Request
    $res = $cb->(GET "/$identifier/pct:.1");
    is $res->code, 303, "abbreviated, lax image request";
    is $res->header('Location'), "http://localhost/$identifier/full/pct:0.1/0/default.png";

    $res = $cb->(GET "/$identifier/full/max/0/default.png");
    is $res->code, 200, "image request";    
};

$app = IIIF::ImageAPI->new(root => 't/img', canonical => 1);
test_psgi $app, sub {
    my ($cb, $res) = @_;
    $res = $cb->(GET "/example/pct:50");
    is $res->code, 303, "redirect to canonical request";
    is $res->header('Location'), "http://localhost/example/full/150,100/0/default.jpg";
};

done_testing;
