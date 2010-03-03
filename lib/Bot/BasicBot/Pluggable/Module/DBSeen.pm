package Bot::BasicBot::Pluggable::Module::DBSeen;

use strict;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);
use Log::Log4perl qw(:easy);
use DBI;
use utf8;
use Carp;

sub help() {
  return "<seen>";
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
    my $sqlQuery = sprintf "SELECT  TO_CHAR(tz_gmt, 'DDth Mon YYYY') AS tz_date, TO_CHAR(tz_gmt, 'HH24:MI:SS tz') AS tz_time
                              FROM	irclog_search
                             WHERE  channel = '%s'
                               AND	(nick = '%s' OR (nick = '' AND LOWER(line) ~ '^%s '))
                          ORDER BY tz_gmt DESC LIMIT 1;", $message->{channel}, $who, $who;

    # Execute the query and fetch the results to a handle
    my $dbq = &dbquery($self, $sqlQuery);
    my ( $qday, $qtz );
    $dbq->bind_columns( undef, \$qday, \$qtz );

    # Return through results
    $dbq->fetch();
    
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

sub dbquery {
  my $self = shift;
  my $q = shift;

  my $dbh = $self->_get_dbh();

  my $db = $dbh->prepare($q);
  $db->execute();

  return $db;
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

1;

# vim: set ts=2 sw=2 et:
