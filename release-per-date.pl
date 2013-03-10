#!/usr/bin/env perl
# =========================================================================
# Released modules at the day
#
# =========================================================================
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

# ref. http://explorer.metacpan.org/?url=%2Frelease%2F_search&content=%7B%0D%0A++++++++++++%22query%22%3A+%7B+%22range%22+%3A+%7B%0D%0A++++++++++++++++++++%22release.date%22+%3A+%7B%0D%0A++++++++++++++++++++++++%22from%22+%3A+%222013-03-07T00%3A00%3A00%22%2C%0D%0A++++++++++++++++++++++++%22to%22+%3A+%222013-03-08T00%3A00%3A00%22%0D%0A++++++++++++++++++++%7D%0D%0A++++++++++++++++%7D%0D%0A++++++++++++%7D%2C%0D%0A++%22fields%22%3A+%5B%22release.license%22%2C+%22release.name%22%2C+%22release.distribution%22%2C+%22release.date%22%2C+%22release.version_numified%22%5D%2C%0D%0A++++++++++++%22size%22%3A10%0D%0A++++++++%7D

my $dt = shift || localtime->add(- ONE_DAY())->strftime('%Y-%m-%d');
my $query = sprintf(<<'...', $dt, $dt);
{
    "query": {
        "range" : {
            "release.date" : {
                "from" : "%sT00:00:00",
                "to" : "%sT23:59:59"
            }
        }
    },
    "fields": [
        "release.license", "release.name", "release.distribution", "release.date", "release.version_numified"
    ],
    "size":10
}
...
my $url = 'http://api.metacpan.org/v0/release/_search';

my $ua = Furl->new();
my $res = $ua->post($url, [], $query);
print $res->status_line, "\n";
# print $res->content, "\n";
my $total = decode_json($res->content)->{hits}->{total} // die;
print "Total: $total\n";

$ua->post('http://hf.64p.org/api/cpan/releases/release_count', [], {
    number      => $total,
    datetime    => $dt,
});
