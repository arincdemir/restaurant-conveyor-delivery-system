use strict; use warnings;
use POSIX qw(setpgid WNOHANG);
use Time::HiRes qw(time sleep);
my $limit=shift @ARGV; my $start=time();
my $pid=fork(); die $! unless defined $pid;
if (!$pid) { setpgid(0,0); exec @ARGV; die $!; }
setpgid($pid,$pid);
while (1) {
  my $w=waitpid($pid,WNOHANG);
  if ($w==$pid) { my $s=$?; printf STDERR "Supervisor elapsed %.3f s; child wait status %d\n",time()-$start,$s; exit($s & 127 ? 128+($s & 127) : $s>>8); }
  if (time()-$start >= $limit) {
    kill 'TERM',-$pid; sleep 0.2; kill 'KILL',-$pid; waitpid($pid,0);
    printf STDERR "TIMEOUT after %.3f s; no native Boolean established\n",time()-$start;
    exit 124;
  }
  sleep 0.1;
}
