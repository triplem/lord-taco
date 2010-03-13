package Bot::BasicBot::Pluggable::Module::DBLog;

use strict;
use Bot::BasicBot::Pluggable::Module;
use Bot::BasicBot::Pluggable::Module::DBAccess;
use base qw(Bot::BasicBot::Pluggable::Module);

my $dbh = Bot::BasicBot::Pluggable::Module::DBAccess->get_dbh("database.conf");

sub help() {
   return "None, you can turn off logging for one line by applying [off] ";
};

## This method is called for every seen message
sub seen { 
  my ( $self, $message ) = @_;

  return if $self->_filter_message($message);

  my $address = $message->{address} ? $message->{address} . ': ' : '';
  my $channel = $message->{channel};
  my $who = $message->{who};
  my $body = $address . $message->{body};

  return 0 unless defined $body;

  $self->_log($channel, $who, $body);

  return; 
}

sub replied {
  my ( $self, $message, $reply ) = @_;
  
  return if $self->_filter_message($message);

  if ( $message->{address} and $message->{who} ) {
      $message->{address} = $message->{who};
  }

  $message->{who}  = $self->bot->nick();
  $message->{body} = $reply;
  $self->seen($message);
}

sub chanjoin {
  my ( $self, $message ) = @_;
  
  
  $self->_log( $message, 'JOIN: ' . $message->{who} );

  return;
}

sub chanpart {
  my ( $self, $message ) = @_;
  $self->_log( $message, 'PART: ' . $message->{who} );

  return;
}


sub userquit {
   
}

sub topic {
   
}

sub kicked {
   
}

sub nick_change {
   
}

sub emoted {
  my ($self, $message, $prio) = @_;
    
  return if $self->_filter_message($message);
  return if $prio != 0;
  
  my $body = $message->{body};
  my $who = "* ".$message->{who};
  my $channel = $message->{channel};
  
  $self->_log( $channel, $who, $body );
  
  return;
}

sub _filter_message {
  my ( $self, $message ) = @_;
  
  my $body = $message->{body};

  if (($body =~ m/^[off]/) or ($message->{channel} eq 'msg')) {
    return 1;
  } 
  
  return;
}

sub _log {
  my ( $self, $channel, $who, $body ) = @_;

  my @sql_args = ($channel, $self->_gmt_today(), $who, $body );

  #$self->tell($channel, "Logging to DB ".$body);
  #$self->tell($channel, "Logging to DB with channel".$channel);

  my $q = $self->_prepare();

  if ( $dbh->ping ) {
    $q->execute(@sql_args);
  } else {
    $q = $self->_prepare();
    $q->execute(@sql_args);
  }

  return;  
}

sub _prepare {
  my $q = $dbh->prepare("INSERT INTO irclog (channel, day, nick, line) VALUES (?, ?, ?, ?)");

  return $q;
}

sub _gmt_today {
  my @d = gmtime(time);
  return sprintf("%04d-%02d-%02d", $d[5]+1900, $d[4] + 1, $d[3]);
}

1;


__END__

=head1 NAME

Bot::BasicBot::Pluggable::Module::DBLog - logs statements ot the DB

=head1 SYNOPSIS


=head1 IRC USAGE

    none

=head1 AUTHOR

Markus M. May, <triplem@tu.archserver.org>

Based on the work done in Bot::BasicBot::Pluggable::Module::Log.

=head1 COPYRIGHT

Copyright 2010, Markus M. May

Distributed under the same terms as Perl itself.

=head1 SEE ALSO

L<Math::Units>
L<Bot::BasicBot::Pluggable::Module::Log>

=cut 

# vim: set ts=2 sw=2 et:
