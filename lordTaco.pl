#!/usr/bin/perl
use lib './lib';
use warnings;
use strict;
use Config::File;
use Bot::BasicBot::Pluggable;
#use Bot::BasicBot::Pluggable::WithConfig;
use Bot::BasicBot::Pluggable::Store::DBI;
use Bot::BasicBot::Pluggable::Store::Deep;
use Log::Log4perl qw(:easy);

package main;

#Log::Log4perl->easy_init($DEBUG);
#my $logger = get_logger();

# configuration for the datastore
my $dbconf = Config::File::read_config_file( shift @ARGV || "database.conf" );
my $dbs = $dbconf->{DSN} || "Pg";
my $db_name = $dbconf->{DATABASE} || "ilbot";
my $dbhost = $dbconf->{HOST} || "localhost";
my $dbuser = $dbconf->{USER} || "ilbot";
my $dbpasswd = $dbconf->{PASSWORD} || "ilbot";

my $store = Bot::BasicBot::Pluggable::Store::DBI->new(
  dsn      => "DBI:$dbs:database=$db_name;host=$dbhost",
  user     => $dbuser,
  password => $dbpasswd,
  table    => "bot_store",
);

# configuration for IRC
my $conf = Config::File::read_config_file( shift @ARGV || "bot.conf" );
my $nick   = shift @ARGV     || $conf->{NICK} || "DemoLordTaco";
my $server = $conf->{SERVER} || "irc.freenode.net";
my $port   = $conf->{PORT}   || 6667;
my $channels = [ split m/\s+/, $conf->{CHANNEL} ];
my $password      = $conf->{PASSWORD}       || "";

#$logger->debug($conf->{CHANNEL});

my $bot = Bot::BasicBot::Pluggable->new(
  server        => $server,
  port          => $port,
  password      => $password,
  channels      => $channels,
  nick          => $nick,
  alt_nicks     => [ "DemoLordTaco", "RenewedLordTacoI" ],
  username      => "LogBot",
  name          => "AS IRC Bot, based on Bot::BasicBot::Pluggable",
  charset       => "utf-8",
  store         => $store,
);

# load needed modules
my $auth_module = $bot->load('Auth');
my $botbasic_module = $bot->load('BotBasics');
my $asbasic_module = $bot->load('ASBasics');
my $asinfobot_module = $bot->load('ASInfobot');
my $join_module = $bot->load('Join');
my $meeting_module = $bot->load('Meeting');
my $insult_module = $bot->load('ASInsult');
my $title_module = $bot->load('ASTitle');
my $dbseen_module = $bot->load('DBSeen'); 
my $dblog_module = $bot->load('DBLog');
my $var_module = $bot->load('Vars');
# This is just for debugging purposes
#my $variable_module = $bot->load('Variables');

#my $bot = Bot::BasicBot::Pluggable->new_with_config(
#  config => 'lord-taco.yaml'
#);


$bot->run();

# vim: set ts=2 sw=2 et:
