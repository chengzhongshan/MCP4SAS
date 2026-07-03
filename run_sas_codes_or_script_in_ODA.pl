#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
exec $^X, "$Bin/run_sas_codes_or_files_in_ODA.pl", @ARGV;
die "Could not exec run_sas_codes_or_files_in_ODA.pl: $!\n";
