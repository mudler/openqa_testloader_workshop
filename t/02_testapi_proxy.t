use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;

use OpenQA::Test::Loader::TestAPI;

use Mojo::File 'tempfile';

subtest 'Can be correctly loaded' => sub {
  my $testapi = OpenQA::Test::Loader::TestAPI->new;
  isa_ok $testapi, 'OpenQA::Test::Loader::TestAPI';
};

subtest 'Holds functions' => sub {
  my $testapi = OpenQA::Test::Loader::TestAPI->new;
  my @test;

  $testapi->proxy(pushtest=>sub { push @test, @_ });

  $testapi->call( pushtest => 'test','test1' );

  is_deeply (\@test, [qw(test test1)], 'Can proxy functions') or die diag explain \@test;

  $testapi->unproxy('pushtest');

  $testapi->call( pushtest => 'test2','test3' );

  is_deeply( \@test, [qw(test test1)], 'Can unproxy functions') or die diag explain \@test;
};

done_testing;
