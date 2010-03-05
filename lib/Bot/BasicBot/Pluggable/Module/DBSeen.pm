package Bot::BasicBot::Pluggable::Module::DBSeen;

use strict;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);
use Bot::BasicBot::Pluggable::Module::DBAccess;

my $dbh = Bot::BasicBot::Pluggable::Module::DBAccess->get_dbh();

sub help() {
  return "Commands: 'seen <nick>'";
};

sub told {
  my ( $self, $message ) = @_;
  my $body = $message->{body};
  return unless defined $body;

  my ( $command, $param ) = split( /\s+/, $body, 2 );
  $command = lc($command);

  if ( $command eq "seen" and $param =~ /^(.+?)\??$/ ) {
    my $who  = lc($1);

    if ($who eq $self->{who}) {
      $self->tell($self->{channel}, "You can't find yourself? I don't think I can help with that...");
    }

    # Find the user in the dbms

    # Execute the query and fetch the results to a handle
    my @sql_args = ($message->{channel}, $who);
    
    my $q = $self->_prepare($self);
     
    $q->execute(@sql_args);
    my ( $qday, $qtz );
    $q->bind_columns( undef, \$qday, \$qtz );

    # Return through results
    $q->fetch();
    
    my $text = "";
    if ($qday) {
      # Found a match
      $text = sprintf "I last saw %s on %s at %s (GMT/UTC)", $who, $qday, $qtz;
    } else {
      # Nothing found
      $text = sprintf "Sorry, I don't remember seeing %s :(", $who;
    }

    $self->tell($message->{channel}, $text);

    return;
  }
}

sub _prepare {
  my $self = shift;

  my $sqlQuery = "SELECT TO_CHAR(seen_date, 'DDth Mon YYYY') AS tz_date, TO_CHAR(seen_date, 'HH24:MI:SS tz') AS tz_time
                    FROM irclog
                   WHERE channel = ?
                     AND (nick = ?)
                ORDER BY seen_date DESC 
                 LIMIT 1;";

  my $q = $dbh->prepare($sqlQuery);

  return $q;
}

1;

__END__

=head1 NAME

Bot::BasicBot::Pluggable::Module::DBSeen - determines when a given nick
was seen the last time.

=head1 SYNOPSIS


=head1 IRC USAGE

!seen <nick>

=head1 AUTHOR

Markus M. May, <triplem@tu.archserver.org>

Based on the work done in Bot::BasicBot::Pluggable::Module::Seen.

=head1 COPYRIGHT

Copyright 2010, Markus M. May

Distributed under the same terms as Perl itself.

=head1 SEE ALSO

L<Math::Units>
L<Bot::BasicBot::Pluggable::Module::Seen>

=cut 

# vim: set ts=2 sw=2 et:
