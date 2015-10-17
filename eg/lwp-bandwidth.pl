#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename 'basename';
use LWP::UserAgent;
use Time::HiRes ();

=head1 DESCRIPTION

This script shows how to get perl-5.22.0.tar.gz with limit 5Mbps using LWP::UserAgent.

=cut

my $LIMIT_UNIT_SECOND = 0.001;

sub limit_data_callback {
    my ($fh, $limit_bps) = @_;
    my $previous = [ [Time::HiRes::gettimeofday], 0 ];
    sub {
        print {$fh} $_[0];
        my $elapsed = Time::HiRes::tv_interval($previous->[0]);
        return 1 if $elapsed < $LIMIT_UNIT_SECOND;
        my $sleep = 8 * (tell($fh) - $previous->[1]) / $limit_bps - $elapsed;
        if ($sleep > 0) {
            select undef, undef, undef, $sleep;
            $previous->[0] = [Time::HiRes::gettimeofday];
            $previous->[1] = tell($fh);
        }
    };
}

my $url = "http://www.cpan.org/src/5.0/perl-5.22.0.tar.gz";
my $file = basename $url;
open my $fh, ">", $file or die;
binmode $fh;

my $limit_bps = 5 * (1024**2); # 5Mbps
my $res = LWP::UserAgent->new->get($url, ':content_cb' => limit_data_callback($fh, $limit_bps));
close $fh;
