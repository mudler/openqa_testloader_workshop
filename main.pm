
use strict;
use testapi;
use autotest;
use distribution;
use lib './lib';

use OpenQA::Test::Loader;

testapi::set_distribution(distribution->new);

my $test_specdata = get_var("_TESTSPEC");

die "No specdata supplied" unless defined $test_specdata && length $test_specdata > 0;

my $loader = OpenQA::Test::Loader->new()->_from_binary($test_specdata);
$loader->load;
