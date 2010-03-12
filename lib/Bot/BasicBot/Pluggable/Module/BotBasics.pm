package Bot::BasicBot::Pluggable::Module::BotBasics;

use strict;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);

sub help {
  return "Commands: #age, #version, #source, #logs";
};

sub connected {
  my $self = shift;
  $self->set("bot_start_time", time);     
}

sub init {
  my $self = shift;
  $self->config(
    { 
      version => "I am v0.0.99",
      source_url => "http://git.archserver.org/?p=ilbot.git;a=summary",
      user_logs_url => "http://irclogs.archserver.org/%s",
    }
  );
}

## This method is called for every seen message
sub seen { 
  my ( $self, $message ) = @_;

  my $body = $message->{body};
  return 0 unless defined $body;

  my $channel = $message->{channel};
  
  my ( $command, $param ) = split (/\s+/, $body, 2);
  $command = lc($command);  

  my $return = "";
  if ($command eq '#age') {
    my $startTime = $self->get("bot_start_time");
    my $age = parseInterval( seconds => ( time - $startTime ), String => 1 );
    $return = "I've been alive for $age";
  } elsif ($command eq '#version') {
    $return = $self->get("version");
  } elsif ($command eq '#source') {
    $return = $self->get("source_url");
  } elsif ( $command eq '#logs' ) {
    $return = $self->get("user_logs_url").$message->{channel};
  } 
  
  return $return;
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
