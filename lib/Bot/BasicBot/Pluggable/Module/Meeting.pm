package Bot::BasicBot::Pluggable::Module::Meeting;

use strict;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);

sub init {
  my $self = shift;

  my $resetOnStartup = $self->get("reset_on_startup");
  
  if ($resetOnStartup == 1) {
    print $resetOnStartup." set to 1"; 
     
    my $store = $self->store();
    my $namespace = "Meeting";
  
    # cleaning all set variables on a reload, this is 
    # unfortunate during a meeting, but otherwise
    # it could not be handled correctly.
    for ($store->keys($namespace)) {
      my $value = $store->get($namespace, $_);
      $self->unset($_);
    }
  }
   
  return;   
}

sub help {
  return "Commands: #startmeeting, #endmeeting, #startvote, #endvote, #topic, #action";
};

## all variables are user_ variables, and can therefore be changed by admins
## via the Bot::BasicBot::Pluggable::Module::Vars module
my $meetingFlagPrefix = "user_meeting_flag_";
my $meetingOperatorPrefix = "user_meeting_operator_";
my $voteFlagPrefix = "user_vote_flag_";
my $voteValuePrefix = "user_vote_value_";

sub admin {
  my ( $self, $message ) = @_;

  my $body = $message->{body};
  return 0 unless defined $body;
  
  my $channel = $message->{channel};
  
  return 0 unless $self->authed($message->{who}) eq '1';
  
  
  my $meetingFlag = $meetingFlagPrefix.$channel;
  my $meetingOperator = $meetingOperatorPrefix.$channel;
   
  my ( $command, $param ) = split (/\s+/, $body, 2);
  $command = lc($command);
 
  # turn the meeting for this channel on/off 
  if ( $command eq "#startmeeting" ) {
    if ( $self->get($meetingFlag) eq 'true' ) {
      $self->reply($message, "meeting is already running ;-)");   
    } 
    $self->set($meetingFlag, 'true');
    $self->set($meetingOperator, $message->{who});
    $self->reply($message, "meeting mode is turned on");
  } elsif ( $command eq "#endmeeting" ) {
    if ($self->get($meetingFlag) eq 'true') {
      if ($self->get($meetingOperator) eq $message->{who}) {
        $self->unset($meetingFlag);
        $self->reply($message, "meeting mode is turned off");
      }
    } else {
      $self->reply($message, "no meeting running currently");
    }
  }

  return 0 unless $self->get($meetingFlag) eq 'true';
  return 0 unless $message->{who} eq $self->get($meetingOperator);
  
  my $voteFlag = $voteFlagPrefix.$channel;
  my $voteValue = $voteValuePrefix.$channel;

  if ( $command eq "#startvote") {
    $self->set($voteFlag, 'true');
    $self->set($voteValue, 0);
    $self->reply($message, "vote is turned on");
  } elsif ( $command eq "#endvote" ) {
    my $voteEnabled = $self->get($voteFlag);
    
    if ($voteEnabled eq "true") {
      my $result = $self->get($voteValue);
      $self->unset($voteFlag);
      $self->unset($voteValue);
      $self->reply($message, "vote is turned off, result is: ".$result);            
    } else {   
      $self->reply($message, "no vote running in this channel");
    }
  } elsif ($body =~ /^#topic[ ](.+)$/) {
    $self->reply($message, "Current Topic: ".$1);     
  } elsif ($body =~ /^#action[ ](.+)$/) {
    $self->reply($message, "New Action: ".$1);     
  }
  
  return;
}

## This method is called for every seen message
sub seen { 
  my ( $self, $message ) = @_;

  my $body = $message->{body};
  return 0 unless defined $body;

  my $channel = $message->{channel};
  my $meetingFlag = $meetingFlagPrefix.$channel;
  my $voteValue = $voteValuePrefix.$channel;
  
  return 0 unless $self->get($meetingFlag) eq 'true';

  if ($self->get($voteFlagPrefix.$channel) eq 'true') {
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
