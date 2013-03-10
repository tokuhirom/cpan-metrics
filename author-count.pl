#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;

use Getopt::Long;
use Time::Piece;
use Time::Seconds qw(ONE_DAY);
use Furl;
use JSON;

my $dt = localtime->strftime('%Y-%m-%d');
my $query = sprintf(<<'...');
{
    "size":1
}
...
my $url = 'http://api.metacpan.org/v0/author/_search';

my $ua = Furl->new();
my $res = $ua->post($url, [], $query);
print $res->status_line, "\n";
# print $res->content, "\n";
my $total = decode_json($res->content)->{hits}->{total} // die;
print "Total: $total\n";

$ua->post('http://hf.64p.org/api/cpan/authors/author_count', [], {
    number      => $total,
    datetime    => $dt,
});
