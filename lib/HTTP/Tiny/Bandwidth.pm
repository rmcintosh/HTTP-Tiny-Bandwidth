package HTTP::Tiny::Bandwidth;
use strict;
use warnings;
use Time::HiRes ();

our $VERSION = '0.01';
use parent 'HTTP::Tiny';

our $LIMIT_UNIT_SECOND = 0.001;

sub limit_data_callback {
    shift;
    my ($fh, $limit_bps) = @_;
    if (!$limit_bps) {
        return sub { print {$fh} $_[0] };
    }
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

# copy from HTTP::Tiny
sub mirror {
    my ($self, $url, $file, $args) = @_;
    @_ == 3 || (@_ == 4 && ref $args eq 'HASH')
    or Carp::croak(q/Usage: $http->mirror(URL, FILE, [HASHREF])/ . "\n");
    if ( -e $file and my $mtime = (stat($file))[9] ) {
        $args->{headers}{'if-modified-since'} ||= $self->_http_date($mtime);
    }
    my $tempfile = $file . int(rand(2**31));

    require Fcntl;
    sysopen my $fh, $tempfile, Fcntl::O_CREAT()|Fcntl::O_EXCL()|Fcntl::O_WRONLY()
    or Carp::croak(qq/Error: Could not create temporary file $tempfile for downloading: $!\n/);
    binmode $fh;
    $args->{data_callback} = $self->limit_data_callback($fh, $args->{limit_bps});
    my $response = $self->request('GET', $url, $args);
    close $fh
        or Carp::croak(qq/Error: Caught error closing temporary file $tempfile: $!\n/);

    if ( $response->{success} ) {
        rename $tempfile, $file
            or Carp::croak(qq/Error replacing $file with $tempfile: $!\n/);
        my $lm = $response->{headers}{'last-modified'};
        if ( $lm and my $mtime = $self->_parse_http_date($lm) ) {
            utime $mtime, $mtime, $file;
        }
    }
    $response->{success} ||= $response->{status} eq '304';
    unlink $tempfile;
    return $response;
}

1;
__END__

=encoding utf-8

=head1 NAME

HTTP::Tiny::Bandwidth - HTTP::Tiny with limitation of download speed

=head1 SYNOPSIS

  use HTTP::Tiny::Bandwidth;

  my $http = HTTP::Tiny::Bandwidth->new;

  my $res = $http->mirror(
    "http://www.cpan.org/src/5.0/perl-5.22.0.tar.gz",
    "/path/to/save/perl-5.22.0.tar.gz",
    { limit_bps => 5 * (1024**2), }, # limit 5Mbps
  );

=head1 DESCRIPTION

HTTP::Tiny::Bandwidth is a HTTP::Tiny subclass which can limits download speed.

If you want to use LWP::UserAgent with limitation of download speed,
see L<eg|https://github.com/shoichikaji/HTTP-Tiny-Bandwidth/tree/master/eg> directory.

HTTP::Tiny::Bandwidth->mirror accepts C<< { limit_bps => LIMIT_BIT_PER_SEC } >> argument.

C<mirror> method get content in a file.
If you want to get content as perl variable, try this:

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

  # do something with $res

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Shoichi Kaji

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
