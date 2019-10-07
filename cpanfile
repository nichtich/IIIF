requires 'perl', '5.008001';

requires 'Plack', '1.0';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'HTTP::Request::Common';
};

