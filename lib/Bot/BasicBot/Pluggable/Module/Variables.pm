package Bot::BasicBot::Pluggable::Module::Variables;

use strict;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);
use Log::Log4perl qw(:easy);

Log::Log4perl->easy_init($DEBUG);
my $logger = get_logger();

sub init {
  my $self = shift;

  my $store = $self->store();

  for ($store->namespaces()) {
    my $namespace = $_;
    for ($store->keys($namespace)) {
      my $value = $store->get($namespace, $_);
      $logger->debug("$_ : $value");
    }
  }
   
  return;   
}

1;

__END__

=head1 NAME


=head1 SYNOPSIS


=head1 IRC USAGE


=head1 AUTHOR

Markus M. May, <triplem@tu.archserver.org>

=head1 COPYRIGHT

Copyright 2010, Markus M. May

Distributed under the same terms as Perl itself.

=head1 SEE ALSO


=cut 

# vim: set ts=2 sw=2 et:
