package Bot::BasicBot::Pluggable::Module::BotBasics;

use strict;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);

sub help {
  return "Commands: #age, #version, #source, #logs";
};

sub init {
  my $self = shift;
  $self->config(
    { 
      user_version => "I am v0.0.99",
      user_source_url => "http://bugs.archserver.org/search/%s",
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

  if ($command eq '#age' or $command eq '#version') {
     return $self->get("user_version");
  } elsif ($command eq '#source') {
     return $self->get("user_source_url");
  }

  #### if there are keywords, attach them
  my $concat;
  if ($param) {
    my @wordArray = split( ' ', $param );
    foreach my $word (@wordArray) {
      if ($concat) {
        $concat = $concat . "+" . $word;
      } else {
        $concat = $word;
      }
    }
  }  
  
  my $return = "";
  if ( $command eq '#logs' ) {
    $return = $self->get("user_logs_url");
  } 
  
  return sprintf( $return, $text );
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
