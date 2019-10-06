use strict;
use Test::More 0.98;
use Plack::Test;
use HTTP::Request::Common;
use IIIF::ImageAPI;

use IPC::Cmd "can_run";
plan skip_all => "ImageMagick's identify missing" unless can_run "identify";

my $app = IIIF::ImageAPI->new(root => 't/img');
my $identifier = "67352ccc-d1b0-11e1-89ae-279075081939";

test_psgi $app, sub {
    my ($cb, $res) = @_;
    is $cb->(GET "/")->code, "404", "/";

    $res = $cb->(GET "/$identifier");
    is $res->code, 303, "/{identifier}";
    $res = $cb->(GET "/$identifier/");
    is $res->code, 303, "/{identifier}/";
    is $res->header('Location'), "http://localhost/$identifier/info.json";

    $res = $cb->(GET "/$identifier/info.json");
    is $res->code, 200, "/{identifier}/info.json";
};

done_testing;
