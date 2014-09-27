#!/usr/bin/env perl

use strict;
use warnings;

my %req_count;
my %req_time;
my %method_count;
my %status_count;
my $total_requests;

my $order = $ARGV[0] || '';

if ($order !~ /^(?:time|count)$/) {
    die "Usage: $0 <time|count>\n";
}

while (<STDIN>) {
    chomp;
    my %kv = map { split /:/ } split /\t/;
    my ($method, $path, $version) = split /\s+/, $kv{req};

    next if $method eq 'OPTIONS';

    my $sec = $kv{reqtime_microsec} ? $kv{reqtime_microsec} / 1_000_000
                                    : $kv{reqtime};

    $path =~ s/\d+/N/;
    $req_count{$path}++;
    $req_time{$path} += $sec;
    $method_count{$method}++;
    $status_count{$kv{status}}++ if $kv{status};
    $total_requests++;
}

my @ordered_paths;
if ($order eq 'time') {
    @ordered_paths = sort { $req_time{$b} <=> $req_time{$a} } keys %req_time;
} elsif ($order eq 'count') {
    @ordered_paths = sort { $req_count{$b} <=> $req_count{$a} } keys %req_count;
}

print "\n*** HTTP requests total: $total_requests ***\n";

print "\n*** HTTP requests stats order by $order ***\n";
for my $path (@ordered_paths) {
    my $count = $req_count{$path};
    my $total_time = $req_time{$path};
    my $mean_time = $total_time / $count;
    print "\ncount: $count, total: $total_time, mean: $mean_time\n" .
          "path: $path\n";
}

print "\n*** HTTP methods stats ***\n";
for my $method (sort keys %method_count) {
    print "$method: $method_count{$method}\n";
}

print "\n*** HTTP statuses stats ***\n";
for my $status (sort keys %status_count) {
    print "$status: $status_count{$status}\n";
}
