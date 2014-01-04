#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

use Art::Web;
use Art::Plugin::DisplayImages;
use Log::Log4perl;

my $help;

GetOptions(
    'help|h'             => \$help,
) or die "Incorrect usage : try 'art_web.pl -h' !\n";


if ($help)
{
    die <<END;
usage : art_web.pl URL [ URL ] ...
		    -d activate graphic application
		    -h this help.

Web Management : -w options

 -w url [ url ... ]
    Select one or multiple websites to begin browsing.
END
}

# on crée et on configure le log4perl
Log::Log4perl->init('log/.configuration');
my $log = Log::Log4perl->get_logger('Art::Web');
$log->info('starting log4perl...');

my $art_web = Art::Web->new();

my $plugin = Art::Plugin::DisplayImages::->new(
    application => $art_web);

$plugin->display;
$art_web->launch('http://www.allocine.fr', $plugin);
