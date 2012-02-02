#!/usr/bin/perl -w

# Copyright 2010 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# 
# Licensed under the Apache License, Version 2.0 (the "License"). You may not 
# use this file except in compliance with the License. A copy of the License is 
# located at
#
# http://aws.amazon.com/apache2.0/
# 
# or in the "license" file accompanying this file. This file is distributed on 
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either 
# express or implied. See the License for the specific language governing 
# permissions and limitations under the License.

use strict;

# begin customizing here

my $CURL = "curl";

# stop customizing here

# you might need to use CPAN to get these modules.
# run perl -MCPAN -e "install <module>" to get them.
use Digest::HMAC_SHA1;
use FindBin;
use MIME::Base64 qw(encode_base64);
use Getopt::Long qw(GetOptions);
use File::Temp qw(tempfile);
use File::Basename qw(basename);
use Fcntl qw/F_SETFD F_GETFD/;
use IO::Handle;

use constant STAT_MODE => 2;
use constant STAT_UID => 4;

my $PROGNAME = basename($0);

my %awsSecretAccessKeys = (); # this gets filled in by evaling the user's secrets file

my $SECRETSFILENAME=".aws-secrets";
my $EXECFILE=$FindBin::Bin;
my $LOCALSECRETSFILE = $EXECFILE . "/" . $SECRETSFILENAME;
my $HOMESECRETSFILE = $ENV{HOME} . "/" . $SECRETSFILENAME;
my $DEFAULTSECRETSFILE = -f $LOCALSECRETSFILE? $LOCALSECRETSFILE : $HOMESECRETSFILE;
my $secretsFile = $DEFAULTSECRETSFILE;
my $keyFile;
my $keyFriendlyName;
my $debug = 0;
GetOptions(
    'keyfile:s' => \$keyFile,
    'keyname=s' => \$keyFriendlyName,
    'debug' => \$debug,
);

$secretsFile = $keyFile if defined $keyFile;

if (!defined $keyFriendlyName) {
    print STDERR "Usage: $PROGNAME --keyname <friendly key name> -- [curl-options]\n\n";
    print_example_usage();
    exit 1;
}

if (-f $secretsFile) {
    open(my $CONFIG, $secretsFile) || die "can't open $secretsFile: $!"; 

    my @stats = stat($CONFIG);

    if (($stats[STAT_UID] != $<) || $stats[STAT_MODE] & 066) {
        die "I refuse to read your credentials from $secretsFile as this file is " .
            "readable by, writable by or owned by someone else. Try " .
            "chmod 600 $secretsFile";
    }

    my @lines = <$CONFIG>;
    close $CONFIG;
    eval("@lines");
    die "Failed to eval() file $secretsFile:\n$@\n" if ($@);
} else {
    print_secrets_file_usage();
    exit 2;
}

# look up the key by friendly name
my $keyentry = $awsSecretAccessKeys{$keyFriendlyName};
if (!defined $keyentry) {
    print STDERR "I can't find a key with friendly name $keyFriendlyName.\n";
    print STDERR "Do you need to add it to $secretsFile?\n";
    print STDERR "\n";
    if (scalar(%awsSecretAccessKeys)) {
        print STDERR "Or maybe try one of these keys that I already know about:\n";
        print STDERR "\t" . join(", ", keys(%awsSecretAccessKeys)) . "\n";
    }
    exit 3;
}

my $aws_key_id = $keyentry->{id};
my $aws_secret_key = $keyentry->{key};

# don't assume the local clock is correct -- fetch the Date according to the server
my $base_url = find_base_url_from_args(@ARGV); 
if (!defined $base_url) {
    print STDERR "I couldn't find anything that looks like a URL in your curl arguments.\n\n";
    print_example_usage();
    exit 4;
}
my $server_date = fetch_server_date($base_url);

# construct the request signature
my $string_to_sign = "$server_date";
my $hmac = Digest::HMAC_SHA1->new($aws_secret_key);
$hmac->add($string_to_sign);
my $signature = encode_base64($hmac->digest, "");

# Pass our (secret) arguments to curl using a temporary file, to avoid exposing them on the command line.
# Can't use STDIN for this purpose because that would prevent the caller from using that stream
# This is secure because tempfile() guarantees the new file is chmod 600
my ($curl_args_file, $curl_args_file_name) = tempfile(UNLINK => 1);
print $curl_args_file "--silent --show-error\n";
print $curl_args_file "header = \"Date: $server_date\"\n";
print $curl_args_file "header = \"X-Amzn-Authorization: AWS3-HTTPS AWSAccessKeyId=$aws_key_id,Algorithm=HmacSHA1,Signature=$signature\"\n";

close $curl_args_file or die "Couldn't close curl config file: $!";

# fork/exec curl, forwarding the user's command line arguments
system($CURL, @ARGV, "--config", $curl_args_file_name);
my $curl_result = $?;

if ($curl_result == -1) {
    die "failed to execute $CURL: $!";
} elsif ($curl_result & 127) {
    printf "$CURL died with signal %d, %s coredump\n",
           ($curl_result & 127), ($curl_result & 128) ? "with" : "without";
    exit 4;
}

# forward curl's exit code
exit $? >> 8;

sub print_secrets_file_usage {
    print STDERR <<END_WARNING;
Welcome to AWS DNS curl! You'll need to install your AWS credentials to get started.

For security reasons, this tool will not accept your AWS secret access key on the
command line. Instead, you need to store them in a file named $secretsFile.
This file must be owned by you, and must be readable by only you.

For example:

\$ cat $secretsFile
\%awsSecretAccessKeys = (
    # my personal account
    'fred-personal' => {
        id => '1ME55KNV6SBTR7EXG0R2',
        key => 'zyMrlZUKeG9UcYpwzlPko/+Ciu0K2co0duRM3fhi',
    },

    # my corporate account
    'fred-work' => {
        id => '1ATXQ3HHA59CYF1CVS02',
        key => 'WQY4SrSS95pJUT95V6zWea01gBKBCL6PI0cdxeH8',
    },
);

\$ chmod 600 $secretsFile
END_WARNING
    return;
}

sub print_example_usage {
    my ($prog) = @_;
    print STDERR "Examples:\n";
    print STDERR "\t\$ $PROGNAME --keyname fred-personal -- -X POST -H \"Content-Type: text/xml; charset=UTF-8\" --upload-file create_request.xml https://route53.amazonaws.com/2010-10-01/hostedzone\t# create new hosted zone\n";
    print STDERR "\t\$ $PROGNAME --keyname fred-personal -- https://route53.amazonaws.com/2010-10-01/hostedzone/Z123456\t# get hosted zone";
    print STDERR "\t\$ $PROGNAME --keyname fred-personal -- https://route53.amazonaws.com/2010-10-01/hostedzone\t# list hosted zones";
    return;
}

# search command line arguments for the first thing that looks like an URL, and return just the http://server:port part of it
sub find_base_url_from_args {
    my (@args) = @_;
    for my $arg (@args) {
        return $1 if ($arg =~ m|^(https?://[^:]+(:\d+)?)\S+|);
    }
    return;
}

sub fetch_server_date {
    my ($url) = @_;
    my $curl_output_lines = run_cmd_read($CURL, "--progress-bar", "-I", "--max-time", "5", "--url", $url, "--insecure");
    for my $line (@$curl_output_lines) {
        if ($line =~ /^Date:\s+([[:print:]]+)/) {
            return $1;
        }
    }
    die "Could not find a Date header in server HEAD response: " . join(";", @$curl_output_lines);
}

sub run_cmd_read {
    my ($cmd, @args) = @_;

    my $cmd_str = $cmd . " " . join(" ", @args);

    my $pid = open(my $README, "-|");
    die "cannot fork: $!" unless defined $pid;
    if ($pid == 0) {
        exec($cmd, @args) or die "Can't exec $cmd : $!";
    } 

    # slurp the output
    my @output = (<$README>);
    my $result = close($README);
    unless ($result) {
        die "Error closing $cmd pipe: $!" if $!;
    }
    
   my $exit_code = ($? >> 8);
   die "Ouch, $cmd_str failed with exit status $exit_code\n" if ($exit_code != 0);
   
   return \@output;
}
