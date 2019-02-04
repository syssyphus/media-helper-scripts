#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;
use Fatal;
use Digest::MD5;
use File::Basename;

sub verify_file {
    my $old;
    $old = shift;
    die "not a file"           unless -f $old;    # skip if not a file
    #die "not a writeable file" unless -w $old;    # skip if not writeable
}

sub fix_filename {
    my $old;
    $old = shift;

    #next if $old =~ /^\./;                        # skip dotfiles
    my $new = $old;
    $new =~ s/md5//g;
    $new =~ y/A-Z/a-z/;                           # lowercase
    $new =~ s/\%20/_/g
      ;    # remove url encoded characters, need to use the funcion i found...
    $new =~ tr/a-z0-9/./c; # translate all non-alphanumeric characters into dots
    $new =~ s/^\.+//;      # remove any leading dots...
    $new =~ s/\.$//g;      # remove any trailing dots
    $new =~ tr/\.//s;      # squeeze any duplicate dots
    return $new;
}

sub get_md5 {
    my $file;
    $file = shift;
    #readlink( $file );
    open( FILE, $file ) or die "Can't open '$file': $!";
    binmode(FILE);
    my $md5 = Digest::MD5->new->addfile(*FILE)->hexdigest;
    return $md5;
}

foreach my $oldpath (@ARGV) {
    #print "$oldpath\n";
    &verify_file($oldpath);
    my ( $oldbasename, $directory, $ext ) =
      fileparse( $oldpath, qr/\.[^.]*/ );    # read in filename and path.
    my $newbasename = $oldbasename;
    $newbasename = &fix_filename($newbasename);    # fix filename
    my $md5 = &get_md5($oldpath);                  # calculate md5sum
    $ext = lc $ext;
    $ext =~ s/\.jpeg$/.jpg/g;
    $ext =~ s/\.divx$/.divx.avi/g;
    $ext =~ s/\.ts$/.ts.mpg/g;
    $ext =~ s/\.mpeg$/.mpg/g;

    $newbasename =~ s/$md5//g;
    $newbasename =~ s/[a-f0-9]{32}//g;
    $newbasename =~ s/\.*$//g;
    my $newfilename = "${newbasename}.md5_${md5}${ext}";    # create new name.
    $newfilename =~ tr/\.//s;
    my $oldfilename = $oldbasename . $ext;
    my $newpath     = $directory . $newfilename;        # create new path.
    next if ( $oldfilename eq $newfilename );
    -e $newpath
      and warn
      "oops, file already exists.\n";    # check if new name already exists
    print "$oldpath\t===>\n$newpath\n\n";
    rename( $oldpath, $newpath ) or die "rename did not work, $!\n";
}

