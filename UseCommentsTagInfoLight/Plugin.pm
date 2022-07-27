#
# Use Comments Tag Info Light
#
# (c) 2022 AF-1
#
# GPLv3 license
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#

package Plugins::UseCommentsTagInfoLight::Plugin;

use strict;
use warnings;
use utf8;

use base qw(Slim::Plugin::Base);

use Scalar::Util qw(blessed);
use Slim::Utils::Log;
use Slim::Utils::Strings qw(string);
use Slim::Utils::Prefs;
use Slim::Utils::Text;
use Slim::Schema;
use Time::HiRes qw(time);
use Data::Dumper;
use Plugins::UseCommentsTagInfoLight::Settings;

my $log = Slim::Utils::Log->addLogCategory({
	'category' => 'plugin.usecommentstaginfolight',
	'defaultLevel' => 'WARN',
	'description' => 'PLUGIN_USECOMMENTSTAGINFOLIGHT',
});
my $serverPrefs = preferences('server');
my $prefs = preferences('plugin.usecommentstaginfolight');

sub initPlugin {
	my $class = shift;
	$class->SUPER::initPlugin(@_);

	initPrefs();
	initMatrix();

	if (main::WEBUI) {
		Plugins::UseCommentsTagInfoLight::Settings->new($class);
	}
}

sub initPrefs {
	$prefs->setChange(sub {
			$log->debug('Change in config matrix detected. Reinitializing trackinfohandler & titleformats.');
			initMatrix();
			Slim::Music::Info::clearFormatDisplayCache();
		}, 'configmatrix');
}

sub initMatrix {
	$log->debug('Start initializing trackinfohandler & titleformats.');
	my $configmatrix = $prefs->get('configmatrix');
	if (keys %{$configmatrix} > 0) {
		foreach my $thisconfig (keys %{$configmatrix}) {
			my $enabled = $configmatrix->{$thisconfig}->{'enabled'};
			next if (!defined $enabled);
			my $thisconfigID = $thisconfig;
			$log->debug('thisconfigID = '.$thisconfigID);
			my $searchstring = $configmatrix->{$thisconfig}->{'searchstring'};
			my $contextmenucategoryname = $configmatrix->{$thisconfig}->{'contextmenucategoryname'};
			my $contextmenucategorycontent = $configmatrix->{$thisconfig}->{'contextmenucategorycontent'};
			if (defined $searchstring && defined $contextmenucategoryname && defined $contextmenucategorycontent) {
				my $contextmenuposition = $configmatrix->{$thisconfig}->{'contextmenuposition'};
				my $regID = 'UCTIL_TIHregID_'.$thisconfigID;
				$log->debug('trackinfohandler ID = '.$regID);
				my $possiblecontextmenupositions = [
					"after => 'artwork'", # 0
					"after => 'bottom'", # 1
					"parent => 'moreinfo', isa => 'top'", # 2
					"parent => 'moreinfo', isa => 'bottom'" # 3
				];
				my $thisPos = @{$possiblecontextmenupositions}[$contextmenuposition];
				Slim::Menu::TrackInfo->deregisterInfoProvider($regID);
				Slim::Menu::TrackInfo->registerInfoProvider($regID => (
					eval($thisPos),
					func => sub {
						return getTrackInfo(@_,$thisconfigID);
					}
				));
			}
			my $titleformatname = $configmatrix->{$thisconfig}->{'titleformatname'};
			my $titleformatdisplaystring = $configmatrix->{$thisconfig}->{'titleformatdisplaystring'};
			if (defined $searchstring && defined $titleformatname && defined $titleformatdisplaystring) {
				my $TF_name = 'UCTIL_'.uc(trim_all($titleformatname));
				$log->debug('titleformat name = '.$TF_name);
				addTitleFormat($TF_name);
				Slim::Music::TitleFormatter::addFormat($TF_name, sub {
					return getTitleFormat(@_,$thisconfigID);
				});
			}
		}
	}
	$log->debug('Finished initializing trackinfohandler & titleformats.');
}

sub getTrackInfo {
	my ($client, $url, $track, $remoteMeta, $tags, $filter, $thisconfigID) = @_;
	$log->debug('thisconfigID = '.$thisconfigID);

	if (Slim::Music::Import->stillScanning) {
		$log->warn('Warning: not available until library scan is completed');
		return;
	}

	# check if remote track is part of online library
	if ((Slim::Music::Info::isRemoteURL($url) == 1)) {
		$log->debug('ignoring remote track without comment tag: '.$url);
		return;
	}

	# check for dead/moved local tracks
	if ((Slim::Music::Info::isRemoteURL($url) != 1) && (!defined($track->filesize))) {
		$log->debug('track dead or moved??? Track URL: '.$url);
		return;
	}

	my $configmatrix = $prefs->get('configmatrix');
	my $thisconfig = $configmatrix->{$thisconfigID};
		if (($thisconfig->{'searchstring'}) && ($thisconfig->{'contextmenucategoryname'}) && ($thisconfig->{'contextmenucategorycontent'})) {
			my $itemname = $thisconfig->{'contextmenucategoryname'};
			my $itemvalue = $thisconfig->{'contextmenucategorycontent'};
			my $thiscomment = $track->comment;

			if (defined $thiscomment && $thiscomment ne '') {
				if (index(lc($thiscomment), lc($thisconfig->{'searchstring'})) != -1) {

					$log->debug('text = '.$itemname.': '.$itemvalue);
					return {
						type => 'text',
						name => $itemname.': '.$itemvalue,
						itemvalue => $itemvalue,
						itemid => $track->id,
					};
				}
			}
		}
	return;
}

sub getTitleFormat {
	my $track = shift;
	my $thisconfigID = shift;
	my $TF_string = HTML::Entities::decode_entities('&#xa0;'); # "NO-BREAK SPACE" - HTML Entity (hex): &#xa0;

	if (Slim::Music::Import->stillScanning) {
		$log->warn('Warning: not available until library scan is completed');
		return $TF_string;
	}
	$log->debug('thisconfigID = '.$thisconfigID);

	if ($track && !blessed($track)) {
		$log->debug('track is not blessed');
		$track = Slim::Schema->find('Track', $track->{id});
		if (!blessed($track)) {
			$log->debug('No track object found');
			return $TF_string;
		}
	}
	my $trackURL = $track->url;

	# check if remote track is part of online library
	if ((Slim::Music::Info::isRemoteURL($trackURL) == 1)) {
		$log->info('ignoring remote track without comment tag: '.$trackURL);
		return $TF_string;
	}

	# check for dead/moved local tracks
	if ((Slim::Music::Info::isRemoteURL($trackURL) != 1) && (!defined($track->filesize))) {
		$log->info('track dead or moved??? Track URL: '.$trackURL);
		return $TF_string;
	}

	my $configmatrix = $prefs->get('configmatrix');
	my $thisconfig = $configmatrix->{$thisconfigID};
	my $titleformatname = $thisconfig->{'titleformatname'};
	my $titleformatdisplaystring = $thisconfig->{'titleformatdisplaystring'};
	if (($titleformatname ne '') && ($titleformatdisplaystring ne '')) {
		my $thiscomment = $track->comment;
		if (defined $thiscomment && $thiscomment ne '') {
			if (index(lc($thiscomment), lc($thisconfig->{'searchstring'})) != -1) {
				$TF_string = $titleformatdisplaystring;
			}
		}
	}
	$log->debug('returned title format display string for track = '.Dumper($TF_string));
	return $TF_string;
}

sub addTitleFormat {
	my $titleformat = shift;
	my $titleFormats = $serverPrefs->get('titleFormat');
	foreach my $format (@{$titleFormats}) {
		if($titleformat eq $format) {
			return;
		}
	}
	push @{$titleFormats},$titleformat;
	$serverPrefs->set('titleFormat',$titleFormats);
}

sub trim_leadtail {
	my ($str) = @_;
	$str =~ s{^\s+}{};
	$str =~ s{\s+$}{};
	return $str;
}

sub trim_all {
	my ($str) = @_;
	$str =~ s/ //g;
	return $str;
}

1;
