#!/usr/bin/perl
use lib './lib';
use warnings;
use strict;
use Config::File;
use Bot::BasicBot::Pluggable;

package main;

my $conf = Config::File::read_config_file( shift @ARGV || "bot.conf" );
my $nick   = shift @ARGV     || $conf->{NICK} || "DemoLordTaco";
my $server = $conf->{SERVER} || "irc.freenode.net";
my $port   = $conf->{PORT}   || 6667;
my $channels = [ split m/\s+/, $conf->{CHANNEL} ];
my $password      = $conf->{PASSWORD}       || "";

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
);

# load needed modules
my $auth_module = $bot->load('Auth');
my $join_module = $bot->load('Join');
my $meeting_module = $bot->load('Meeting');
my $infobot_module = $bot->load('Infobot');
my $insult_module = $bot->load('ASInsult');
my $title_module = $bot->load('Title');
my $dbseen_module = $bot->load('DBSeen'); 
my $dblog_module = $bot->load('DBLog');
my $var_module = $bot->load('Vars');

#$bot->load('Loader'); # could be used for ease of configuration
$bot->run();

# vim: set ts=2 sw=2 et:
