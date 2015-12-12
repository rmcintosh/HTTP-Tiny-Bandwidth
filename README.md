[![Build Status](https://travis-ci.org/shoichikaji/HTTP-Tiny-Bandwidth.svg?branch=master)](https://travis-ci.org/shoichikaji/HTTP-Tiny-Bandwidth)

# NAME

HTTP::Tiny::Bandwidth - HTTP::Tiny with limitation of download/upload speed

# SYNOPSIS

    use HTTP::Tiny::Bandwidth;

    my $http = HTTP::Tiny::Bandwidth->new;

    # limit download speed
    my $res = $http->get("http://www.cpan.org/src/5.0/perl-5.22.0.tar.gz", {
      download_limit_bps => 5 * (1024**2), # limit 5Mbps
    });

    # you can save memory with mirror method
    my $res = $http->mirror(
      "http://www.cpan.org/src/5.0/perl-5.22.0.tar.gz",
      "/path/to/save/perl-5.22.0.tar.gz",
      { download_limit_bps => 5 * (1024**2) }, # limit 5Mbps
    );

    # limit upload speed
    my $res = $http->post("http://example.com", {
      content_file     => "big-file.txt", # or content_fh
      upload_limit_bps => 5 * (1024**2),  # limit 5Mbps
    });

# DESCRIPTION

HTTP::Tiny::Bandwidth is a subclass of [HTTP::Tiny](https://metacpan.org/pod/HTTP::Tiny) which can limit download/upload speed.

If you want to use LWP::UserAgent with limitation of download/upload speed,
see [eg](https://github.com/shoichikaji/HTTP-Tiny-Bandwidth/tree/master/eg) directory.

## HOW TO LIMIT DOWNLOAD SPEED

HTTP::Tiny::Bandwidth's `request/get/...` and `mirror` methods accepts
`download_limit_bps` option:

    my $http = HTTP::Tiny::Bandwidth->new;

    my $res = $http->get("http://www.cpan.org/src/5.0/perl-5.22.0.tar.gz", {
      download_limit_bps => 5 * (1024**2),
    });

    my $res = $http->mirror(
      "http://www.cpan.org/src/5.0/perl-5.22.0.tar.gz",
      "/path/to/save/perl-5.22.0.tar.gz",
      { download_limit_bps => 5 * (1024**2) },
    );

## HOW TO LIMIT UPLOAD SPEED

HTTP::Tiny::Bandwidth's `request/post/put/...` methods accepts
`content_file`, `content_fh`, `upload_limit_bps` options:

    my $http = HTTP::Tiny::Bandwidth->new;

    # content_file
    my $res = $http->post("http://example.com", {
      content_file     => "big-file.txt",
      upload_limit_bps => 5 * (1024**2), # limit 5Mbps
    });

    # or, you can specify content_fh
    open my $fh, "<", "big-file.txt" or die;
    my $res = $http->post("http://example.com", {
      content_fh       => $fh,
      upload_limit_bps => 5 * (1024**2), # limit 5Mbps
    });

# SEE ALSO

[HTTP::Tiny](https://metacpan.org/pod/HTTP::Tiny)

# COPYRIGHT AND LICENSE

Copyright 2015 Shoichi Kaji

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
