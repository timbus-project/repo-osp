use warnings;
use strict;

#
# Copyright (c) 2014, Caixa Magica Software Lda (CMS).
# The work has been developed in the TIMBUS Project and the above-mentioned are Members of the TIMBUS Consortium.
# TIMBUS is supported by the European Union under the 7th Framework Programme for research and technological
# development and demonstration activities (FP7/2007-2013) under grant agreement no. 269940.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at:   http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied, including without
# limitation, any warranties or conditions of TITLE, NON-INFRINGEMENT, MERCHANTIBITLY, or FITNESS FOR A PARTICULAR
# PURPOSE. In no event and under no legal theory, whether in tort (including negligence), contract, or otherwise,
# unless required by applicable law or agreed to in writing, shall any Contributor be liable for damages, including
# any direct, indirect, special, incidental, or consequential damages of any character arising as a result of this
# License or out of the use or inability to use the Work.
# See the License for the specific language governing permissions and limitation under the License.
#

package Manager::Manager;

use XML::Simple;

#use base qw(Class::Accessor);

#__PACKAGE__->mk_accessors(qw(name info manifes));

sub new {
	my $class = shift;
	my $self = {
		projects => [],
		remotes => [],
		manifest => {
			remote => [],
			default => {
				'remote' => 'opensourceprojects',
				'sync-j' => '4',
			},
		},
		folders => {},
		filename => undef,
	};
	bless $self, $class;
	return $self;
}

sub add_repository {
	my $self = shift;
	my ($name, $path, $revision) = @_;
	my $hash = {
		name => $name,
		path =>, $path,
		revision => $revision,
	};
	push(@{$self->{projects}}, $hash);
}

sub add_repositories {
	my $self = shift;
	my $common_path = shift;
	my $repos_ref = shift;
	my @repos = @$repos_ref;
	my $len = length($common_path);

	for (@repos) {
		my $path = substr($_, $len);
		$self->add_repository($_, $path, "master");
	}
}

sub save_to_xml {
	my $self = shift;
	$$self{manifest}->{project} = $self->{projects};
	my $xml = XMLout(
		$self->{manifest},
		OutputFile => 'default.xml',
		XMLDecl => '<?xml version="1.0" encoding="UTF-8"?>',
		KeepRoot => 1,
		RootName => 'manifest'
	);

	for my $folder (keys $self->{folders}) {
		$$self{manifest}->{project} = $self->{folders}->{$folder};
		my $xml = XMLout(
			$self->{manifest},
			OutputFile => "$folder.xml",
			XMLDecl => '<?xml version="1.0" encoding="UTF-8"?>',
			KeepRoot => 1,
			RootName => 'manifest'
		);
	}
}

sub scan_repositories {
	my $self = shift;
	my $common_path = shift;

	for my $repo (@{$self->{projects}}) {
		my $path = substr($repo->{name}, length($common_path) - 1);
		while (my ($first) = $path =~ m/\/(.*?)\//g) {
			$self->add_folder($first, $repo);
			$path = substr($path, length($first));
		}
	}
}

sub add_folder {
	my $self = shift;
	my $path = shift;
	my $repo = shift;
	push(@{$self->{folders}->{$path}}, $repo);
}

sub addremote {
	my $self = shift;
	my ($name, $fetch) = @_;
	my $hash = {
		name => $name,
		fetch => $fetch,
	};
	push(@{$self->{manifest}->{remote}}, $hash);
}
1;