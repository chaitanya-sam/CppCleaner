

#!/usr/local/bin/perl -w

use strict;
use warnings;
use strict;
use threads;
use threads::shared;
use Cwd;
use File::Basename;
use File::Spec;
use File::Find;
use File::Copy;

################################################################################################

my @hpp_files_list = ();
my @cpp_files_list = ();
my %hppGraph=();
my %graphRank=();
my %graphRankRev=();
my %hpp_files_to_compile = ();
my @independentHPP  :shared;
my $noOfThreads :shared;

Main();
exit(0);

################################################################################################

sub BuildHeaderFilesList
{
	find(\&AddToHeaderFilesList, cwd());
}

sub AddToHeaderFilesList
{
	my $file = $File::Find::name;	

	my $osname = $^O;
	if ($osname eq 'MSWin32'){
		$file =~ s,/,\\,g;
	}

	unless (-f $file) {
		return;
	}

	unless ($file =~ /\.(hpp)/) {
		return;
	}
	
	if (($file =~ /\_pch.hpp/) || ($file =~ /\_filter.hpp/) || ($file =~ /\.(bad)/)) {
		return;
	}

	push (@hpp_files_list, $file);
}

################################################################################################

sub BuildCPPFilesList
{
	find(\&AddToCPPFilesList, cwd());
}

sub AddToCPPFilesList
{
	my $file = $File::Find::name;	

	my $osname = $^O;
	if ($osname eq 'MSWin32'){
		$file =~ s,/,\\,g;
	}clccls
	c

	unless (-f $file) {
		return;
	}

	unless ($file =~ /\.(cpp)/) {
		return;
	}
	
	if (($file =~ /\_pch.cpp/) || ($file =~ /\.(bad)/)) {
		return;
	}
	
	push (@cpp_files_list, $file);
}

################################################################################################



sub ProcessAllCompilationUnits
{
print("\nEnetred ProcessAllCompilationUnits");
	# Process all the headers first
	#my $count = 0;
	#@hpp_files_to_compile{@hpp_files_list} = undef;
	my @thrList=();
	my $v;
  buildHPPGraph();
  setGraphRank();
  graphHPPCluster();
  processHPPClusters();
=for comment
	while ((%hpp_files_to_compile) && ($count < 3)) {
		++$count;
		while ((my $key) = each(%hpp_files_to_compile)) {
			delete($hpp_files_to_compile{$key});
			
			print "Processing file: ".$key."\n";
			ProcessHPPUnit($key);
		}
	}
=cut	
	foreach (@cpp_files_list) {
		print "Processing file: ".$_."\n";
    my $v= threads->create(\&ProcessCPPUnit,$_);
    push(@thrList,$v);
		# ProcessCPPUnit($_);
    
###update
#push(@globalQ,$_); 


	}
while(@thrList)
{
	
	
	$_->join();
}
		
}



sub buildHPPGraph
{

     my $file;
print("\nEnetred buildHPPGraph");

for $file(@hpp_files_list)
{
print("\ndde $file");

	my @var=GetAllDependentHPPFiles($file);
	
$hppGraph{$file}=\@var;

my @a=GetAllIncludeFiles($file);
#print("@hppGraph{$file}\n");

if (@a)
{  #if @a is not empty do nothing
}
else
{
	push(@independentHPP,$file);

}

}

}






sub setGraphRank
{
	print("\nEnetred setGraphRank");
my  @q=();
my @dep=();
my $ele;
my @k=keys %hppGraph;
#print("$k[1]\n");
foreach(@k)
{
print( "aaa $_\n");
}
#print("hi $independentHPP\n");
#my $e=findIndexOfIndependentVertex();
foreach(@independentHPP)
{
$graphRank{$_}=0;
push(@q,$_);
}


while(@q)
{  print("\nentered");
	my $key=shift(@q);
	print("\ncom $key");
	@dep=();


=for comment
my @t=@{$hppGraph{$key}};
while(@t)
{
	my $t1=shift(@t);
print("cc  $t1\n");
}
=cut

#	if(@{$hppGraph{$key}})
	{
	@dep=@{$hppGraph{$key}};
    }
for $ele(@dep)
{
	if( exists($graphRank{$ele} ) )
	{
	my $oldRank=$graphRank{$ele};
	$graphRank{$ele}=$graphRank{$key}+1;
   		 if($oldRank < $graphRank{$ele})
    		{
    			push(@q,$ele);
   			 }

    }

	else
	{
		
       $graphRank{$ele}=$graphRank{$key}+1;
        push(@q,$ele);

	} 


}
}
}


#HPP graphs are partitioned based on dependency
sub graphHPPCluster
{
	print("\nEnetred graphHPPCluster");
	my $k;
	my @a=();
for $k(keys %graphRank)
{
	if( exists($graphRankRev{$graphRank{$k}}))
	{
		@a=@{$graphRankRev{$graphRank{$k}}};
           # push(@a,);
	}
	else
	{    @a=();
		
     
	}

	push(@a,$k);
    $graphRankRev{$graphRank{$k}}=\@a;

}
}


sub processHPPClusters
{
	print("\nEnetred processHPPClusters");
	my @hppThrList=();
	foreach my $rank (sort keys %graphRankRev)
	 {
   # printf "%-8s %s\n", $name, $planets{$name};
     my @hpptoProcess=@{$graphRankRev{$rank}};
       @hppThrList=();
     foreach(@hpptoProcess)
     	{
     		while($noOfThreads>1000)
     		{
     			sleep(2);
     		}
     		 my $v= threads->create(\&ProcessHPPUnit,$_);
             
             push(@hppThrList,$v);
     		 
     	}
    
      foreach(@hppThrList)
		{
		   $_->join();
        }

     }


}


sub ProcessHPPUnit
 
{   #incrmenting thread counter

           {
     		 lock($noOfThreads);
     		 $noOfThreads+=1;
     		}


	print("\nEnetred ProcessHPPUnit");
	my $file = $_[0];
	#my @finalIncludeHPPListToComment;
   # share( @finalIncludeHPPListToComment);
	my @hppIncludesToComment=();
	my @dependent_hpp_files = GetAllDependentHPPFiles($file);
	my @dependent_cpp_files = GetAllDependentCPPFiles($file);
	my @include_files = GetAllIncludeFiles($file);
	my @thrHPPList=();
	CheckOutFile($file);
	
	foreach (@include_files) 
	{
		my $include_file = $_;


       while($noOfThreads>1000)
       {
       	
       	sleep(2);
       }

         my $v= threads->create(\&ProcessHPPGranular,$file,$include_file);
        push(@thrHPPList,$v);			
=for comment		
		CommentIncludeInFile($file, $include_file);
		
		my $status = CompileFile($file);		
		if (0 != $status) { # If the compilation fails 
			UncommentIncludeInFile($file, $include_file);
		}
		else {
			# Push this commented headers to other dependent files
			foreach (@dependent_cpp_files) {
				PushCommentedHeaderToDependentFile($_, $file, $include_file);
			}
			
			foreach (@dependent_hpp_files) {
				PushCommentedHeaderToDependentFile($_, $file, $include_file);
				$hpp_files_to_compile{$_} = undef;
			}
		}		
=cut
	}
	foreach(@thrHPPList)
	{
	#my $v=shift(@thrHPPList);
	my $result=$_->join();
	print("\nresult $result");
	if($result eq "pass")
	{
	#donothing
	}
	else{
	push(@hppIncludesToComment,$result);
	}
	}
	while(@hppIncludesToComment)
	{
	my $toInclude=$_;#shift(@hppIncludesToComment);
	CommentIncludeInFile($file, $toInclude);
	
			foreach (@dependent_cpp_files) {
				PushCommentedHeaderToDependentFile($_, $file, $toInclude);
			}
			
			foreach (@dependent_hpp_files) {
				PushCommentedHeaderToDependentFile($_, $file, $toInclude);
				$hpp_files_to_compile{$_} = undef;
			}
	
	
	
	}


	{
     		 lock($noOfThreads);
     		 $noOfThreads-=1;
     		}
	
	
}

sub ProcessHPPGranular
{


  
             {
     		 lock($noOfThreads);
     		 $noOfThreads+=1;
     		}





print("\nEnetred ProcessHPPGranular");
my $file=$_[0];
my $include_file=$_[1];
##copying the file to avoid same file to avoid multiple thread ##write to the same file at once.
  my	$tid=threads->tid();
  print("\ncheck $file \n");
  print("\ninclude file $include_file");

  my @filePart=split('\.', $file);
  my $fName=$filePart[0];
  my $format=$filePart[1];

 my $test_file=$fName."temp".$tid."\.".$format ; 
  print("\nproposed $test_file \n");


=for comment
 unless(open MYFILE, '>'.$test_file) {
    # Die with error message 
    # if we can't open it.
    die "\nUnable to create $test_file\n";
}
=cut
=for comment
open(my $MYFILE, "$test_file") || die "\nUnable to create $test_file\n";
{
	#flock($file);
	flock($file, 1);
copy($file,$test_file) or die "Copy failed: $!";
  close($file);
}
=cut
{
	#	flock($file, 1);
copy($file,$test_file) or die "Copy failed: $!";

}
close( $test_file);
close($file);
CommentIncludeInFile($test_file, $include_file);
		
	#	my $status = CompileFile($test_file);

	my $status=0;
#cls
close(test_file);

  unlink $test_file or warn "Could not unlink $test_file: $!";
		# If the compilation fails 
		if (0 != $status) {
			#UncommentIncludeInFile($file, $include_file);
    # lock(@finalIncludeHPPListToComment);
   #  push(@finalIncludeListToComment,$include_file);
    #unlock(@finalIncludeHPPListToComment);       
      return $include_file;
	}
	else{
	return "pass";
	}
           {
     		 lock($noOfThreads);
     		 $noOfThreads-=1;
     		}

}













################################################################################################
## 1st level threads to be run in cores
sub ProcessCPPUnit
{
	print("\nEnetred ProcessCPPUnit");
	my $file = $_[0];
	my @finalIncludeListToComment;
    share( @finalIncludeListToComment);
	CheckOutFile($file);
	
	my @include_files = GetAllIncludeFiles($file);
	foreach (@include_files) 
     {
		my $include_file = $_;
		CommentIncludeInFile($file, $include_file);
		
		my $status = CompileFile($file);
		
		# If the compilation fails 
		if (0 != $status) 
		{
			UncommentIncludeInFile($file, $include_file);

    
#	  $result=	 threads->create(\&ProcessCPPGranular,$file,$include_file);
        }	
=for comment
## wait until all child thread completes.code to be written
 #$result->join();
size=@finalIncludeListToComment;
$i=0;
while(i<size)
{
$toComment= shift(@finalIncludeListToComment);
CommentIncludeInFile($file, $toComment);

}

=cut
}
}

## 2nd level threads to be run in cores of a multicore cluster
=for comment
sub ProcessCPPGranular
{
$file=$_[0];

##copying the file to avoid same file to avoid multiple thread ##write to the same file at once.

 my $test_file= $file . threads->tid(); 
copy($file,$test_file) or die "Copy failed: $!";
$include_file=$_[1];

CommentIncludeInFile($test_file, $include_file);
		
		my $status = CompileFile($test_file);
		
		# If the compilation fails 
		if (0 != $status) {
			#UncommentIncludeInFile($file, $include_file);
     lock(@finalIncludeListToComment);

      push(@finalIncludeListToComment,$include_file);
     unlock(@finalIncludeListToComment);       

		}
     

	}	

unlink $test_file;
}

=cut


################################################################################################
















################################################################################################

sub PushCommentedHeaderToDependentFile
{
	my $file = $_[0];
	my $header_to_search = '^\#\s*include.*'.basename($_[1]).'.*';
	my $header_to_push = $_[2];

	if (($_[2] =~ m/\.hpp|\.h/)) {
		foreach (@hpp_files_list) {
			if (basename($_) eq $header_to_push) {
				if (dirname($_) ne dirname($file)) {
					my $relative_path = File::Spec->abs2rel($_, cwd());
					$relative_path =~ s,\\,/,g;					
					if ($relative_path ne '') {
						$header_to_push = $relative_path;
					}
				}
				
				last;
			}
		}
		$header_to_push = '#include "'.$header_to_push.'"';
	}
	else {
		$header_to_push = '#include <'.$_[2].'>';
	}
	
	# Check if the header is already included in the file
	open (my $FH, "<", $file);
	
	while (my $line = <$FH>) {
		if ($line eq $header_to_push) {
			close ($FH);
			return;
		}
	}
	
	close ($FH);
	
	CheckOutFile($file);

	my @file_content = ();	
	open ($FH, "<", $file);
	
	while (my $line = <$FH>) {
		if (($line =~ m/$header_to_search/)) {
			push (@file_content, $header_to_push);
			push (@file_content, "\n");
		}
		
		push (@file_content, $line);
	}
	
	close ($FH);
	
	open ($FH, ">", $file);
	foreach (@file_content) {
		print ($FH $_);
	}
	
	close ($FH);
}

################################################################################################
sub CommentIncludeInFile
{
	print("\nhey");

}
=for comment
sub CommentIncludeInFile
{
	print("\n Entered CommentIncludeInFile with $_[0] and $_[1]\n");
	my $file = $_[0];	
	my $include_file_to_comment = '^\#\s*include.*'.$_[1].'.*';

	my @file_content = ();	
	print("\nhi1 $include_file_to_comment");
	open (my $FH, "<", $file);
	
	while (my $line = <$FH>) {
		if (($line =~ m/$include_file_to_comment/)) {
			push (@file_content, "//".$line);
		}
		else {
			push (@file_content, $line);
		}
	}
	print("\nhi2 $include_file_to_comment");
	close ($FH);
	
	open ($FH, ">", $file);
	print("\nhi3 $include_file_to_comment");
	foreach (@file_content) {
		print ($FH $_);
	}
	print("\nhi4 $include_file_to_comment");
	close ($FH);
	close($file);
	print("\nhi5 $include_file_to_comment");
}
=cut
################################################################################################

sub UncommentIncludeInFile
{
	my $file = $_[0];
	my $include_file_to_uncomment = '^//\#\s*include.*'.$_[1].'.*';
	
	my @file_content = ();	
	open (my $FH, "<", $file);
	
	while (my $line = <$FH>) {
		if (($line =~ m/$include_file_to_uncomment/)) {
			push (@file_content, substr($line, 2)); # Remove '//' from the line 
		}
		else {
			push (@file_content, $line);
		}
	}
	
	close ($FH);
	
	open ($FH, ">", $file);
	foreach (@file_content) {
		print ($FH $_);
	}
	
	close ($FH);	
}

################################################################################################

sub CompileAllDependentCPPFiles
{
	my $dependent_cpp_files = $_[0];
	my $compile_status = 0;
	
	foreach (@$dependent_cpp_files) {
		$compile_status = CompileFile($_);
		if (0 != $compile_status) {
			last;
		}
	}
	
	return $compile_status;

}

################################################################################################

sub CompileFile
{  my $compile_cmd;
	my $file = $_[0];	
	{
	#flock($file,2);
	 $compile_cmd = "sbcc -mc ".$file." >nul 2>1"; # On windows	
    }
	return system($compile_cmd);	
}

################################################################################################

sub IsHeaderIncluded
{
	my $file = $_[0];
	my $header_file = '^\#\s*include.*'.$_[1].'.*';

	my $is_header_included = 0;
	open (my $FH, "<", $file);
	
	while (my $line = <$FH>) {
		if (($line =~ m/$header_file/)) {
			$is_header_included = 1;
			last;
		}
	}
	
	close ($FH);
	
	return $is_header_included;
}

################################################################################################

sub GetAllDependentCPPFiles
{
	my $header_file_key = $_[0];
	my $header_file = basename($header_file_key);

	my @cpp_list = ();
	foreach my $cpp_file (@cpp_files_list) {
		if (1 == IsHeaderIncluded($cpp_file, $header_file)) {
			push(@cpp_list, $cpp_file);
		}
	}
	
	return @cpp_list;
}

################################################################################################

sub GetAllDependentHPPFiles
{
	my $header_file_key = $_[0];
	my $header_file = basename($header_file_key);
	
	my @hpp_list = ();
	foreach my $hpp_file (@hpp_files_list) {
		if ($hpp_file ne $header_file_key) {
			if (1 == IsHeaderIncluded($hpp_file, $header_file)) {
				push(@hpp_list, $hpp_file);
			}
		}
	}
	
	return @hpp_list;
}

################################################################################################

sub CheckOutFile
{
	my $file = $_[0];
	my $checkout_cmd = "chmod 0755 ".$file;
	#my $checkout_cmd = "p4 edit ".$file." >nul 2>1"; # On windows
	system($checkout_cmd);
}

################################################################################################

sub GetAllIncludeFiles
{
	my $file = $_[0];
	
    my $regexp_quote_include = '^\#\s*include\s+"(\S+)"';
	my $regexp_angle_include = '^\#\s*include\s+<(\S+)>';
	
	my $regexp_start_ifdef = '^\#\s*if\s*def';
	my $regexp_start_ifzero = '^\#\s*if\s*0';
	my $regexp_end_ifdef = '^\#\s*endif';
		
	unless (-f $file) {
		return;
	}

	my $inside_ifdef = 0;	
	my @include_files = ();

	open (my $FH, "<", $file);
	
	while (my $line = <$FH>) {
		if (($line =~ m/$regexp_start_ifdef/) || ($line =~ m/$regexp_start_ifzero/)) {
			$inside_ifdef = 1;
			next;
		}

		if ((1 == $inside_ifdef) && ($line =~ m/$regexp_end_ifdef/)) {
			$inside_ifdef = 0;
			next;
		}
		
		next if (1 == $inside_ifdef);
		
		if (($line =~ m/$regexp_quote_include/) || ($line =~ m/$regexp_angle_include/)) {
			push (@include_files, $1);
		}
	}
	
	close ($FH);
	
	return @include_files;
}

################################################################################################

sub Main 
{
	$noOfThreads=0;
	BuildHeaderFilesList();
	
	BuildCPPFilesList();
	ProcessAllCompilationUnits();
}

################################################################################################

