#!/usr/bin/env perl
use warnings;
use strict;

sub error { die "chess error: @_"};
sub mkmat { return map { [(0) x 8] } 1..8; };
sub pmat {
    for my $row (@_) {
	print join(" ",@$row), "\n";
    }
};
sub pboard {
    print "a b c d e f g h\n";
    my $i = 1;
    for my $row(@_) {
	my $line = join(" ",@$row);
	$line =~ s/0/ /g;
	print $line," $i\n";
	$i+=1;
    }
};
sub inside {
    my ($row, $col) = @_;

    if ($row >= 0 && $row < 8 && $col >= 0 && $col < 8)
    {
        return 1;
    } else {
        return 0;
    }
}
sub eqvec {
    my ($x1,$y1,$x2,$y2) = @_;

    if($x1 eq $x2 && $y1 eq $y2){
	return 1;
    } else {
	return 0;
    }
}
error "no script to play!" unless @ARGV;
error "incorrect argument number!" unless scalar(@ARGV) == 1;

open my $sc, "<", $ARGV[0] or error "can't open '$ARGV[0]'";


our @memory = mkmat;
our @board  = mkmat;
our %figure_counter  =
    (
     "K" => 0, #king
     "Q" => 0, #queen
     "R" => 0, #rook
     "B" => 0, #bishop
     "k" => 0, #knight
     "P" => 0  #pawn
    );
our %figure_maxes  =
    (
     "K" => 1, #king
     "Q" => 1, #queen
     "R" => 2, #rook
     "B" => 2, #bishop
     "k" => 2, #knight
     "P" => 8  #pawn
    );
our %coordmap =
    (
     "a" => 0,
     "b" => 1,
     "c" => 2,
     "d" => 3,
     "e" => 4,
     "f" => 5,
     "g" => 6,
     "h" => 7
    );
our %mapcoord =
    (
     0 => "a",
     1 => "b",
     2 => "c",
     3 => "d",
     4 => "e",
     5 => "f",
     6 => "g",
     7 => "h"
    );


sub can_add {
    my ($figure) = @_;
    return $figure_counter{$figure} + 1 le $figure_maxes{$figure};
}
sub is_free_cell
{
    my ($x, $y) = @_;
    return $board[$y][$x] eq 0;
}
sub setmem {
    my ($x, $y) = @_;
    if($memory[$y][$x] == 0) {$memory[$y][$x] = 1;}
    else {$memory[$y][$x] = 0;}
};

sub print_output {
    print "BYTES:";

    my @bytes;
    for my $y (0 .. $#memory)
    {
	my $byte = 0;
	for my $x (0 .. $#{$memory[$y]})
	{      
	    my $bit = $memory[$y][$x];
	    $byte += $bit * (2 ** (7 - $x));

	}
	print "$byte ";
	push @bytes, $byte;
    }
    print "\n";

    print "TEXT:";
    for (@bytes)
    {
	print chr $_, " ";
    }
    print "\n";
};


sub can_pawn_move {
    my ($x1,$y1,$x2,$y2) = @_;
    my $x = $x1 eq $x2;
    my $yd = ($y2-$y1);
    my $y = $yd == 1 || $yd == 2;
    return $x && $y;
};
sub can_king_move {
    my ($x1,$y1,$x2,$y2) = @_;
    my $xd = abs($x1 - $x2);
    my $yd = abs($y1 - $y2);

    return ($xd eq 0 && $yd eq 1) ||
	   ($xd eq 1 && $yd eq 0) ||
	   $xd eq $yd;
};
sub can_knight_move {
    my ($x1, $y1, $x2, $y2) = @_;

    my @knight_moves = (
        [2, 1], [2, -1], [-2, 1], [-2, -1],
        [1, 2], [1, -2], [-1, 2], [-1, -2]
    );

    foreach my $move (@knight_moves) {
        my ($dx, $dy) = @$move;
        if ($x2 == $x1 + $dx && $y2 == $y1 + $dy) {
            return 1;
        }
    }

    return 0;
}
sub can_bishop_move {
    my ($x1, $y1, $x2, $y2) = @_;


    if (abs($x2 - $x1) == abs($y2 - $y1)) {
        return 1;
    }

    return 0;
}
sub can_rook_move {
    my ($x1, $y1, $x2, $y2) = @_;

    if ($x1 == $x2 || $y1 == $y2) {
        return 1; 
    }

    return 0;
}
sub can_queen_move {
    my ($x1, $y1, $x2, $y2) = @_;

 
    if ($x1 == $x2 || $y1 == $y2 || abs($x2 - $x1) == abs($y2 - $y1)) {
        return 1;
    }

    return 0; 
}
while(<$sc>)
{
    chomp;
    
    #set figure
    if($_ =~ /^[a-h]\d[KQRBkP]$/)
    {
	my $figure = chop $_;
	
	my $y = chop $_; --$y;
	my $x = $coordmap{chop $_};

	error "'$_' leads to figure amount overflow!" unless can_add $figure;
	error "'$_' leads to non-empty spot!" unless is_free_cell $x, $y;

	$board[$y][$x] = $figure;
	setmem $x, $y;
	$figure_counter{$figure}++;
    }
    #move figure
    elsif($_ =~ /^[a-h]\d[a-h]\d$/)
    {	
	my $y2 = chop $_; --$y2;
	my $x2 = $coordmap{chop $_};

	my $y1 = chop $_;--$y1;
	my $x1 = $coordmap{chop $_};


	my $figure = $board[$y1][$x1];
	if($figure eq "P")
	{
	    error "unable to move 'P'awn!" unless can_pawn_move $x1, $y1, $x2, $y2;
	}
	elsif($figure eq "K")
	{
	    error "unable to move 'K'ing!" unless can_king_move $x1, $y1, $x2, $y2;
	}
	elsif($figure eq "k")
	{	    
	    error "unable to move 'k'night!" unless can_knight_move $x1, $y1, $x2, $y2;
	}
	elsif($figure eq "B")
	{
	    error "unable to move 'B'ishop!" unless can_bishop_move $x1, $y1, $x2, $y2;
	}
	elsif($figure eq "R")
	{
	    error "unable to move 'R'ook!" unless can_rook_move $x1, $y1, $x2, $y2;
	}
	elsif($figure eq "Q")
	{
	    error "unable to move 'Q'een!" unless can_rook_move $x1, $y1, $x2, $y2;
	}
	else
	{
	    error "wtf?";
	}

	$board[$y1][$x1] = 0;
	$board[$y2][$x2] = $figure;
	setmem $x1, $y1;
	setmem $x2, $y2;
    }
    else { error "wrong syntax: '$_'";}

    print "\e[H\e[2J";
    print "MEMORY:\n";
    pmat @memory; print "\n";
    
    print "BOARD:\n";
    pboard @board; print "\n";

    print_output; print "\n";
    
    sleep 1;
};
close $sc;
