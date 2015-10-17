[![Build Status](https://travis-ci.org/shoichikaji/HTTP-Tiny-Bandwidth.svg?branch=master)](https://travis-ci.org/shoichikaji/HTTP-Tiny-Bandwidth)

# NAME

HTTP::Tiny::Bandwidth - HTTP::Tiny with limitation of download speed

# SYNOPSIS

    use HTTP::Tiny::Bandwidth;

    my $http = HTTP::Tiny::Bandwidth->new;

    my $res = $http->mirror(
      "http://www.cpan.org/src/5.0/perl-5.22.0.tar.gz",
      "/path/to/save/perl-5.22.0.tar.gz",
      { limit_bps => 5 * (1024**2), }, # limit 5Mbps
    );

# DESCRIPTION

HTTP::Tiny::Bandwidth is a HTTP::Tiny subclass which can limits download speed.
If you want to use LWP with limitation of download speed,
see [eg](https://github.com/shoichikaji/HTTP-Tiny-Bandwidth/tree/master/eg) directory.

HTTP::Tiny::Bandwidth->mirror accepts `{ limit_bps => LIMIT_BIT_PER_SEC }` argument.

`mirror` method get content in a file.
If you want to get content as perl variable, try this:

    my $content;
    open my $content_fh, ">+", \$content;

    my $limit_bps = 5 * (1024**2); # 5Mbps
    my $http = HTTP::Tiny::Bandwidth->new;
    my $res = $http->get(
      "http://example.com/data.bin",
      { data_callback => $http->limit_data_callback($content_fh, $limit_bps) },
    );
    close $content_fh;
    $res->{content} = $content;

    # do something with $res

# COPYRIGHT AND LICENSE

Copyright 2015 Shoichi Kaji

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
