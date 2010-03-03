package Bot::BasicBot::Pluggable::Module::DBLog;

use strict;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);
use Log::Log4perl qw(:easy);
use DBI;
use utf8;
use Carp;

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
  
#  $self->tell($message->{channel}, $message->{address});

  if ( $message->{address} and $message->{who} ) {
      $message->{address} = $message->{who};
  }

  $message->{who}  = $self->bot->nick();
  $message->{body} = $reply;
  $self->seen($message);
  
  return;
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

  my @sql_args = ($channel, $self->_gmt_today(), $who, time, $body );

#  $self->tell($channel, "Logging to DB ".$body);

  my $dbh = $self->_get_dbh();
  my $q = $dbh->prepare("INSERT INTO irclog (channel, day, nick, timestamp, line) VALUES (?, ?, ?, ?, ?)");

  if ( $dbh->ping ) {
    $q->execute(@sql_args);
  } else {
    $q = $dbh->prepare ("INSERT INTO irclog (channel, day, nick, timestamp, line) VALUES (?, ?, ?, ?, ?)");
    $q->execute(@sql_args);
  }

  return;  
}

sub _get_dbh {
    my $conf = Config::File::read_config_file("database.conf");
    my $dbs = $conf->{DSN} || "mysql";
    my $db_name = $conf->{DATABASE} || "ilbot";
    my $host = $conf->{HOST} || "localhost";
    my $user = $conf->{USER} || "ilbot";
    my $passwd = $conf->{PASSWORD} || "ilbot";

    my $db_dsn = "DBI:$dbs:database=$db_name;host=$host";
    my $dbh = DBI->connect($db_dsn, $user, $passwd,
            {RaiseError=>1, AutoCommit => 1});

    return $dbh;
}

sub _gmt_today {
  my @d = gmtime(time);
  return sprintf("%04d-%02d-%02d", $d[5]+1900, $d[4] + 1, $d[3]);
}

1;

# vim: set ts=2 sw=2 et:
