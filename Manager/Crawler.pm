#!/usr/bin/perl

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

use warnings;
use strict;

package Manager::Crawler;

use LWP::Simple;

sub new {
	my $class = shift;
	my $project = shift;

	my $self = {
		domain => shift,
		urls => [$project],
		gits => [],
	};
	bless $self, $class;
	return $self;
}

sub init {
	my $self = shift;

	while(my $base_url = pop @{$self->{urls}}) {
		my $html = get($base_url);

		while ($html =~ m/\/(.*?)\/\"\sclass=\"ui\-icon\-admin/g) {
			my $new_url = $self->{domain} . "/" .$1;
			push (@{$self->{urls}}, $new_url);
		}

		while($html =~ m/\/(.*?)\/\"\sclass=\"ui\-icon\-tool\-git/g) {
			my $git_repo = "git/" . $1;
			my $git_get_url = $self->{domain} . "/$1/";
			my $git_url = get($git_get_url);
			my $empty = 0;

			if ($git_url =~ m/No\s\(more\)\scommits/g) {
				$empty = 1;
			}

			if (!$empty) {
				push (@{$self->{gits}}, $git_repo);
			}
		}
	}

}
1;