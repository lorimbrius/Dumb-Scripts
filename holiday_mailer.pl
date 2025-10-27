#!/usr/local/bin/perl
use strict;
use warnings;

use POSIX qw/strftime/;

sub mail;

my $groupname      = "holidays";
my $holidays_file  = "/usr/local/etc/acct/holidays";
my $email_template = "/usr/local/etc/holiday.email";
my $sendmail       = "/usr/sbin/sendmail";
my $gpent;

# open holidays file
open (HOLIDAYS, $holidays_file) or die ($!);
my $today   = strftime('%#m/%#d', localtime);
my @hfile   = grep(!/^#/, <HOLIDAYS>);
  @hfile   = grep(/$today\s(\w)/, @hfile);
my $holiday = $1;
exit (0) unless $#hfile > 1;

for (my $i = 0; $i < $#ARGV; $i++) {
   # shortarg
   if ($ARGV[$i] =~ m/^-(\w)$/) {
       if ($1 eq 'g') {
           if (length($ARGV[++$i]) > 1) {
               $groupname = $ARGV[$i];
           }

           else {
               die ("No group name specified.\n");
           }
       }

       elsif ($1 eq 't') {
           if (length($ARGV[++$i]) > 1) {
               $email_template = $ARGV[$i];
           }

           else {
               die ("No template file specified.\n");
           }
       }

       elsif ($1 eq 'm') {
           if (length($ARGV[++$i]) > 1) {
               $sendmail = $ARGV[$i];
           }

           else {
               die ("No sendmail command specified.\n");
           }
       }

       else {
           die ("Unrecognized argument: " . $ARGV[$i] . ".\n");
       }
   }

   # longarg
   if ($ARGV[$i] =~ m/^--(\w*)=(\w*)$/) {
       if ($1 eq "groupname") {
           if (length($2) > 1) {
               $groupname = $2;
           }

           else {
               die ("No group name specified.\n");
           }
       }

       elsif ($1 eq "email-template") {
           if (length($2) > 1) {
               $email_template = $2;
           }

           else {
               die ("No template file specified.\n");
           }
       }

       elsif ($1 eq "sendmailcmd") {
           if (length($2) > 1) {
               $sendmail = $2;
           }

           else {
               die ("No sendmail command specified.\n");
           }
       }

       else {
           die ("Unrecognized argument: $1.\n");
       }
   }
}

# Sends e-mail to users in group
open (GROUP, "/etc/group") or die ($!);

# find "holidays" group
while (<GROUP>) {
   if ($_ =~ m/^$groupname:(.*)/) {
       $gpent = chomp($1);
       last;
   }
}

close GROUP;

die ("Group $groupname not found.\n") if (length($gpent) < 1);

# parse gpent
my @users = split(',', $gpent);
open (HOLIDAY, $holidays_file) or die ($!);

foreach (@users) {
   mail($_, $holiday);
}

close HOLIDAY;

sub mail {
   my ($to, $holiday) = @_;
   my $from = 'darthferrett\@gmail.com';

   open (MAIL, "|$sendmail -oi -t -f$from");
   print MAIL 'From: Charlie root <darthferrett@gmail.com>' . "\n";
   print MAIL "To: $to\n";
   print MAIL "Subject: Happy $holiday\n\n";

   foreach (<HOLIDAY>) {
       print MAIL $_;
   }
}
