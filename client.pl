#!/usr/bin/perl;

use warnings;
use IO::Socket::INET;
use Tk::BrowseEntry;
use Tk;
use threads;

my $of; my $port; my $obs; my $oflag; my $seek;;
my $thr;

my $mw = MainWindow->new( -width => '480', -relief => 'flat', -height => '300', );
   $mw -> title("Imaging Server");
#Text boxes
my $var1 = $mw->Entry( -width => '55', -relief => 'groove', -state => 'normal', -justify =>'left' )->place( -x => 60, -y => 30);
my $var2 = $mw->Entry( -width => '12', -relief => 'groove', -state => 'normal', -justify =>'left' )->place( -x => 60, -y => 60);

my $var6= $mw->Entry( -width => '20', -relief => 'groove', -state => 'normal', -justify => 'left' )->place( -x => 60, -y => 120);
my $var7= $mw->Entry( -width => '20', -relief => 'groove', -state => 'normal', -justify => 'left' )->place( -x => 280, -y => 120);
my $var9= $mw->BrowseEntry( -width => '20', -relief => 'groove', -state => 'readonly', -justify => 'left', -variable => \$oflag)->place( -x => 280, -y => 150);

#populate dropdowns
$var9->insert( "end","append" );$var9->insert( "end","direct" );$var9->insert( "end","directory" );$var9->insert( "end","dsync" );$var9->insert( "end","sync" );
$var9->insert( "end","fullblock" );$var9->insert( "end","nonblock" );$var9->insert( "end","noatime" );$var9->insert( "end","noctty" );$var9->insert( "end","nofollow" );

####Box labels
my $var21 = $mw->Label( -pady => '1', -relief => 'flat', -padx => '1', -state => 'normal', -justify => 'center', -text => 'OF:' )->place( -x => 20, -y => 30);
my $var30 = $mw->Label( -pady => '1', -relief => 'flat', -padx => '1', -state => 'normal', -justify => 'center', -text => 'Port:' )->place( -x => 20, -y => 60);

my $var25 = $mw->Label( -pady => '1', -relief => 'flat', -padx => '1', -state => 'normal', -justify => 'center', -text => 'seek:' )->place( -x => 20, -y => 120);
my $var27 = $mw->Label( -pady => '1', -relief => 'flat', -padx => '1', -state => 'normal', -justify => 'center', -text => 'obs:' )->place( -x => 240, -y => 120);
my $var29 = $mw->Label( -pady => '1', -relief => 'flat', -padx => '1', -state => 'normal', -justify => 'center', -text => 'olag:' )->place( -x => 240, -y => 150);

#Buttons
my $var41 = $mw->Button( -pady => '1', -relief => 'raised', -padx => '1', -state => 'normal', -justify => 'center', -text => 'Connect', -command => \&run )->place( -x => 140, -y => 220) ;
my $var42 = $mw->Button( -pady => '1', -relief => 'raised', -padx => '1', -state => 'normal', -justify => 'center', -text => 'Exit', -command => \&exit )->place( -x => 220, -y => 220);

$mw->MainLoop();
sub run {
	my $command;
	$of = $var1->get();$port = $var2->get();$obs = $var7->get();$oflag = $var9->get('active');$seek = $var6->get();
	
	if( $of ne '' && $port ne '' ){
		$command = "nc -l $port | dd of=$of";
		if( $obs ne '' ){ $command=$command." obs=$obs";}
		#if( $oflag ne '' ){ $command=$command." oflag=$oflag";}
		if( $seek ne '' ){ $command=$command." seek=$seek";}
		
		my $client = new IO::Socket::INET( PeerHost => '127.0.0.1', PeerPort => 4441, Proto => 'tcp' ) or die "Failed to Connect\n";
		print "Connecting to server...\n";
		
		my $line;
		while( 1 ){
			$client -> recv( $line, 10 ); chomp $line;
			print "LINE: \"$line\"\n";
			if( $line eq "BEGIN_OK" ){
				$client -> send("OK_START") or die "CANT SEND\n";
				system($command);
				#system("nc -l $port | dd of=$of ");
				sleep(2);close $client;
				last;
			}else{ print "NO GOOD!\n";last; }
		}		
	}
}
sub exit {
	exit(0);
}
