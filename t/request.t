use strict;
use Test::More 0.98;
use IIIF::Request;

my @tests = (
    max => 'full/max/0/default',
    42  => 'full/max/42/default',
    'square/1,' => 'square/1,/0/default',
    'pct:41.6,7.5,40,70' => 'pct:41.6,7.5,40,70/max/0/default',
    '125,15,120,140/90,/!345/gray.jpg' => '125,15,120,140/90,/!345/gray.jpg',
);

while (@tests) {
    my ($req, $expect) = splice @tests, 0, 2;
    is(IIIF::Request->new($req)->as_string, $expect, "$req = $expect");
}

done_testing;
