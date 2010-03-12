package Bot::BasicBot::Pluggable::Module::DBAccess;

use strict;
use DBI;
use utf8;
use Carp;

sub get_dbh {
  my $self = shift;
  
  my $conf = Config::File::read_config_file("database.conf");
  my $dbs = $conf->{DSN} || "Pg";
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
