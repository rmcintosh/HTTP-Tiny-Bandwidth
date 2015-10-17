#!/usr/bin/env perl
use strict;
use warnings;
use lib "lib", "../lib";
use HTTP::Tiny::Bandwidth;

my $content;
open my $content_fh, "+>", \$content;

my $limit_bps = 5 * (1024**2); # 5Mbps
my $http = HTTP::Tiny::Bandwidth->new;
my $res = $http->get(
    "http://www.cpan.org/src/5.0/perl-5.22.0.tar.gz",
    { data_callback => $http->limit_data_callback($content_fh, $limit_bps) },
);
close $content_fh;
$res->{content} = $content;
