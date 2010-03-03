#!/usr/bin/perl
use lib './lib';
use warnings;
use strict;
use Config::File;
use Bot::BasicBot::Pluggable;

package main;

my $bot = Bot::BasicBot::Pluggable->new(
  channels      => ["#ilbot-test"],
  server        => "irc.freenode.net",
  nick          => "RenewedLordTaco",
  alt_nicks     => [ "DemocraticLordTaco", "logbot" ],
  username      => "LordTaco",
  name          => "LordTaco",
);

my $auth_module = $bot->load('Auth');
my $join_module = $bot->load('Join');
my $dblog_module = $bot->load('DBLog');
my $dbseen_module = $bot->load('DBSeen'); 
my $meeting_module = $bot->load('Meeting');
my $infobot_module = $bot->load('Infobot');


#$bot->load('Loader'); # could be used for ease of configuration
$bot->run();

# vim: set ts=2 sw=2 et:
