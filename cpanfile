requires 'perl', '5.008005';
requires 'HTTP::Tiny';

on develop => sub {
    requires 'Plack';
    requires 'Test::TCP';
};

on test => sub {
    requires 'Test::More', '0.98';
};
