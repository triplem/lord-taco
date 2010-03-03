package Bot::BasicBot::Pluggable::Module::Meeting;

use strict;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);
use Log::Log4perl qw(:easy);

#enable logging
  Log::Log4perl->easy_init($DEBUG);
  my $logger = get_logger();

sub init {
  my $self = shift;

  my $store = $self->store();
  my $namespace = "Meeting";
  
  # cleaning all set variables on a reload, this is 
  # unfortunate during a meeting, but otherwise
  # it could not be handled correctly.
  for ($store->keys($namespace)) {
    my $value = $store->get($namespace, $_);
    $self->unset($_);
  }
   
  return;   
}

sub help {
  return "Commands: !voteon, !voteoff ";
};

sub admin {
  my ( $self, $message ) = @_;

  my $body = $message->{body};
  return 0 unless defined $body;
  
  my $channel = $message->{channel};
  
  my $meetingFlag = "meeting_flag_".$channel;
  my $meetingOperator = "meeting_operator_".$channel;
   
  my ( $command, $param ) = split (/\s+/, $body, 2);
  $command = lc($command);
  $logger->debug("command: ".$command);
 
  # turn the meeting for this channel on/off 
  if ( $command eq "startmeeting" ) {
    $self->set($meetingFlag, 'true');
    $self->set($meetingOperator, $message->{who});
    $self->tell($channel, "meeting mode is turned on");
  } elsif ( $command eq "endmeeting" ) {
    if ($self->get($meetingOperator) eq $message->{who}) {
      if ($self->get($meetingFlag) eq 'true') {
        $self->unset($meetingFlag);
        $self->tell($channel, "meeting mode is turned off");
      } else {
        $self->tell($channel, "no meeting running currently");
      }
    }
  }

  $self->tell($channel, $meetingOperator);

  return 0 unless $self->get($meetingFlag) eq 'true';
  return 0 unless $message->{who} eq $meetingOperator;
  
  my $voteFlag = "meeting_vote_".$channel;
  my $voteValue = "meeting_vote_value_".$channel;
  
  $self->tell($channel, $command);
  
  if ( $command eq "startvote") {
    $self->set($voteFlag, 'true');
    $self->set($voteValue, 0);
    $self->tell($channel, "vote is turned on");
  } elsif ( $command eq "endvote" ) {
    my $voteEnabled = $self->get($voteFlag);
    
    if ($voteEnabled eq "true") {
      my $result = $self->get($voteValue);
      $self->unset($voteFlag);
      $self->unset($voteValue);
      $logger->debug("voteoff succeded with result $result");
      $self->tell($channel, "vote is turned off, result is: ".$result);            
    } else {   
      $self->tell($channel, "no vote running in this channel");
    }
  } elsif ($body =~ /^!topic[ ](.+)$/) {
    $self->tell($channel, "Current Topic: ".$1);     
  }
}

## This method is called for every seen message
sub seen { 
  my ( $self, $message ) = @_;

  my $body = $message->{body};
  return 0 unless defined $body;

  my $channel = $message->{channel};
  my $meetingFlag = "meeting_flag_".$channel;
  my $voteValue = "meeting_vote_value_".$channel;
  
  return 0 unless $self->get($meetingFlag) eq 'true';

  if ($self->get("vote_".$channel) eq 'true') {
    if ( $body eq '+1' ) {
      my $counter = $self->get($voteValue);       
      $counter++;
      $self->set($voteValue, $counter);
    } elsif ( $body eq '-1' ) {
      my $counter = $self->get($voteValue);       
      $counter--;       
      $self->set($voteValue, $counter);        
    }
  } 
}

1;

# vim: set ts=2 sw=2 et:
