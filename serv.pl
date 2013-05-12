#!/usr/bin/perl;

use warnings;
use IO::Socket::INET;
use Tk::BrowseEntry;
use Tk;
use threads;

my $if; my $port; my $bs; my $cbs; my $conv; my $count; my $ibs; my $iflag; my $skip; my $ip;
my $thr;

my $mw = MainWindow->new( -width => '480', -relief => 'flat', -height => '300', );
   $mw -> title("Imaging Server");
#Text boxes
my $var1 = $mw->Entry( -width => '55', -relief => 'groove', -state => 'normal', -justify =>'left' )->place( -x => 60, -y => 30);
my $var2 = $mw->Entry( -width => '12', -relief => 'groove', -state => 'normal', -justify =>'left' )->place( -x => 320, -y => 60);
my $var10= $mw->Entry( -width => '25', -relief => 'groove', -state => 'normal', -justify => 'left' )->place( -x => 60, -y => 60);

my $var5= $mw->BrowseEntry( -width => '20', -relief => 'groove', -state => 'readonly', -justify => 'left', -variable => \$conv)->place( -x => 60, -y => 120);
my $var6= $mw->Entry( -width => '20', -relief => 'groove', -state => 'normal', -justify => 'left' )->place( -x => 60, -y => 150);
my $var7= $mw->Entry( -width => '20', -relief => 'groove', -state => 'normal', -justify => 'left' )->place( -x => 280, -y => 120);
my $var9= $mw->BrowseEntry( -width => '20', -relief => 'groove', -state => 'readonly', -justify => 'left', -variable => \$iflag)->place( -x => 280, -y => 150);
my $var14= $mw->Entry( -width => '20', -relief => 'groove', -state => 'normal', -justify => 'left' )->place( -x => 185, -y => 180);

#populate dropdowns
$var5->insert( "end","ascii" );$var5->insert( "end","ebcdic" );$var5->insert( "end","ibm" );$var5->insert( "end","block" );$var5->insert( "end","unblock");
$var5->insert( "end","lcase" );$var5->insert( "end","nocreat" );$var5->insert( "end","excl" );$var5->insert( "end","notrunc" );$var5->insert( "end","ucase" );
$var5->insert( "end","swab" );$var5->insert( "end","noerror" );$var5->insert( "end","sync" );$var5->insert( "end","fdatasync" );$var5->insert( "end","fsync" );

$var9->insert( "end","append" );$var9->insert( "end","direct" );$var9->insert( "end","directory" );$var9->insert( "end","dsync" );$var9->insert( "end","sync" );
$var9->insert( "end","fullblock" );$var9->insert( "end","nonblock" );$var9->insert( "end","noatime" );$var9->insert( "end","noctty" );$var9->insert( "end","nofollow" );

####Box labels
my $var21 = $mw->Label( -pady => '1', -relief => 'flat', -padx => '1', -state => 'normal', -justify => 'center', -text => 'IF:' )->place( -x => 20, -y => 30);
my $var30 = $mw->Label( -pady => '1', -relief => 'flat', -padx => '1', -state => 'normal', -justify => 'center', -text => 'IP:' )->place( -x => 20, -y => 60);
my $var22 = $mw->Label( -pady => '1', -relief => 'flat', -padx => '1', -state => 'normal', -justify => 'center', -text => 'Port:' )->place( -x => 280, -y => 60);

my $var25 = $mw->Label( -pady => '1', -relief => 'flat', -padx => '1', -state => 'normal', -justify => 'center', -text => 'conv:' )->place( -x => 20, -y => 120);
my $var26 = $mw->Label( -pady => '1', -relief => 'flat', -padx => '1', -state => 'normal', -justify => 'center', -text => 'count:' )->place( -x => 20, -y => 150);
my $var27 = $mw->Label( -pady => '1', -relief => 'flat', -padx => '1', -state => 'normal', -justify => 'center', -text => 'ibs:' )->place( -x => 240, -y => 120);
my $var29 = $mw->Label( -pady => '1', -relief => 'flat', -padx => '1', -state => 'normal', -justify => 'center', -text => 'iflag:' )->place( -x => 240, -y => 150);
my $var34 = $mw->Label( -pady => '1', -relief => 'flat', -padx => '1', -state => 'normal', -justify => 'center', -text => 'skip:', )->place( -x => 150, -y => 180);

#Buttons
my $var41 = $mw->Button( -pady => '1', -relief => 'raised', -padx => '1', -state => 'normal', -justify => 'center', -text => 'Start Server', -command => \&run )->place( -x => 140, -y => 220) ;
my $var42 = $mw->Button( -pady => '1', -relief => 'raised', -padx => '1', -state => 'normal', -justify => 'center', -text => 'Stop Server', -command => \&stop)->place( -x => 220, -y => 220);

$mw->MainLoop();
sub run {
	$thr1 = threads->create(\&copy);
}

sub stop {
	$thr1->kill('KILL');
}

sub copy {
	$if = $var1->get();$port = $var2->get();$conv=$var5->get('active');$count=$var6->get();$ibs=$var7->get();$iflag=$var9->get('active');$skip=$var14->get();$ip=$var10->get();
while( 1 ){

print "CONV: $conv\n";

my $command;
if( $if ne '' && $port ne '' ){
		$command = "dd if=$if";
		#if( $conv ne '' ){ $command=$command." conv=$conv";}
		if( $ibs ne '' ){ $command=$command." ibs=$ibs";}
		#if( $iflag ne '' ){ $command=$command." iflag=$iflag";}
		if( $skip ne '' ){ $command=$command." skip=$skip";}
		$command = $command."| nc $ip $port";

		my $serv = IO::Socket::INET->new(Proto => 'tcp', LocalPort => 4441, Listen => SOMAXCONN, Reuse => 1) or die "Failed to create socket\n";
		print "Server Running\n";
		
		while( $cl = $serv->accept() ){
			$cl -> send("BEGIN_OK");
			$cl -> recv($recv_data, 10 );chomp($recv_data);
			while( $recv_data ne "OK_START" ){
			$cl -> autoflush(1);
			$cl -> send("BEGIN_OK");
			$cl -> recv($recv_data, 10 );chomp($recv_data);
			print "RECV: \"$recv_data\"\n";
			}
			sleep(1);
			print $command."\n";
			system($command);
			#ystem("dd if=$if | nc 127.0.0.1 $port");
			last;
		}
		close $cl;
		}
	}
}















