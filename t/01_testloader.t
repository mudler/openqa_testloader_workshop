use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;

use OpenQA::Test::Loader;
use OpenQA::Test::Loader::Result;

use Mojo::File 'tempfile';

sub validate_test {
  my $res = shift;
  is $res->{vars}->{TEST_VAR}, 1, 'TEST_VAR is 1';
  is $res->{vars}->{TEST2_VAR},2, 'TEST2_VAR is 2';
  is_deeply $res->{modules}, [qw(category/boot category/shutdown)];
}

subtest 'Default functionalities' => sub {
  my $loader = OpenQA::Test::Loader->new;
  isa_ok $loader->result, 'OpenQA::Test::Loader::Result';

  my $yaml = tempfile;
  $yaml->spurt('
---
test: install
vars:
    TEST_VAR: 1
    TEST2_VAR: 2
modules:
  - category/boot
  - category/shutdown
');

  $loader->_from_yaml($yaml);
  my $res = $loader->result;
  validate_test($res);

  # Should be an object from _from_yaml()
  is $res->vars->{TEST_VAR}, 1;
  is $res->vars->{TEST2_VAR},2;
  is_deeply $res->modules, [qw(category/boot category/shutdown)];

  my $testdefinition = $loader->_to_binary;

  my $newtest = OpenQA::Test::Loader->new()->_from_binary($testdefinition);
  validate_test($newtest->result);
};

subtest 'b64 encode/decode' => sub {
  my $res = OpenQA::Test::Loader::Result->new(vars=> { test => 1 }, modules => [qw(category/boot category/boot2)]);
  is $res->vars->{test},1;

  my $decoded_result = OpenQA::Test::Loader::Result->new->decode($res->encode);
  is $decoded_result->vars->{test},1;
  diag explain $res->encode;
};

subtest 'proxy' => sub {
  my $loader = OpenQA::Test::Loader->new;
  my $yaml = tempfile;
  $yaml->spurt('
---
test: install
vars:
    TEST_VAR: 1
    TEST2_VAR: 2
modules:
  - category/boot
  - category/shutdown
');

  my @loaded;
  $loader->_from_yaml($yaml);
  $loader->testapi->proxy(loadtest => sub { push @loaded,shift });
  $loader->load;
  is_deeply(\@loaded, [qw(category/boot category/shutdown)],'Modules loaded correctly');

  my %vars;
  $loader->_from_yaml($yaml);
  $loader->testapi->proxy(set_var => sub { $vars{+pop} = pop } );
  $loader->load;
  is_deeply(\%vars, {TEST_VAR =>1, TEST2_VAR => 2},'Modules loaded correctly') or die diag explain \%vars;
};
# https://openqa.opensuse.org/tests/797432
# https://openqa.suse.de/tests/1783031#step/oci_install/10
# https://openqa.suse.de/tests/1783040
# https://openqa.suse.de/tests/1783035
done_testing;
