package OpenQA::Test::Loader;

# A default Mojolicious object
use Mojo::Base -base;

# We will use an internal object to represent the result
use OpenQA::Test::Loader::Result;
use OpenQA::Test::Loader::TestAPI;

# os-autoinst
use lib '/usr/lib/os-autoinst/';

use testapi qw(set_var);
use autotest qw(loadtest);

# External deps
use YAML;

# We will have a result object. Using OpenQA::Parser::Result as it supports
# serialization ootb.
has result => sub { OpenQA::Test::Loader::Result->new };
has testapi => sub { OpenQA::Test::Loader::TestAPI->new };

# Read the file format (YAML,XML, w/e..) and build an object that we can send to OpenQA
# +1: Build yaml inheritance with include keywords (?)
sub _from_yaml { $_[0]->result(OpenQA::Test::Loader::Result->new(%{(Load(Mojo::File->new(pop)->slurp))[0]})) }

sub _from_binary { $_[0]->result(shift->result->decode(pop)) }

sub _to_binary { shift->result->encode }

sub _set_vars {
  my $self = shift;
  foreach my $var( keys  % { $self->result->vars } ){
    $self->testapi->call( set_var => ($var,$self->result->vars->{$var}) );
  }
  return $self;
}

sub _load_tests {
  my $self = shift;
  foreach my $test( @{ $self->result->modules } ){
    $self->testapi->call( loadtest => $test );
  }
  return $self;
}

sub load {
  shift->_load_tests->_set_vars;
}

# TODO: Add variable expansion (?)
# TODO: Make it read from isos post in the WebAPI controller with the same object
#  and fill the test vars from there

1;
