package OpenQA::Test::Loader::TestAPI;
# TestAPI Proxy Object

use Mojo::Base -base;

# os-autoinst
use lib '/usr/lib/os-autoinst/';
use autotest 'loadtest';
use testapi 'set_var';

has functions => sub {
  {
    loadtest => sub { loadtest shift },
    set_var => sub { set_var @_ },
  }
};

sub proxy { shift->functions->{+shift} = pop }
sub unproxy { shift->functions->{+shift} = sub {} }

sub call {
  my $self = shift;
  my $fn = shift;
  return $self->functions->{$fn}->(@_);
}

1;
