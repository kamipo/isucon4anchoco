#!/usr/bin/env perl

use strict;
use warnings;

my $rotate_nginx = '/home/isucon/nginx/sbin/nginx -s reopen';
my $rotate_mysql = '/usr/bin/mysqladmin -u root flush-logs';

my $mode = $ARGV[0] || '';
my $logfile = $ARGV[1];

if ($mode !~ /^(?:nginx|mysql)$/) {
    die "Usage: $0 <nginx|mysql> <logfile>\n";
}

unless (-f $logfile) {
    die "Usage: $0 <nginx|mysql> <logfile>\n";
}

my $date = `date +'%Y-%m-%d-%H%M'`;
chomp $date;

rename $logfile, "$logfile.$date";

my $run_command;
if ($mode eq 'nginx') {
    $run_command = $rotate_nginx;
} elsif ($mode eq 'mysql') {
    $run_command = $rotate_mysql;
}

if ($ENV{DRY_RUN}) {
    print "dry-run: $run_command\n";
} else {
    system($run_command);
}

print "$logfile -> $logfile.$date\n";
