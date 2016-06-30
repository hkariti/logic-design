

#------------------------------------------
# open the input log file
#------------------------------------------

#counts the number of arguments
	$noArg = @ARGV;
	
# holds the directory where all the zip files from students is kept 
	my $inFileName = $ARGV[0];
	
# if not enough arguments exit with a usage message	
	if ($noArg < 1){ 
		print "\n\n\ncreat_inst_mem gets a log file created by the PCSpim mips simulator and creats from it an instruction memory file\n";
		print "that can be used by vhdl simulations.\nThe instruction memory file is placed at the same directory as the input log file.\n";
		print "\n\nusage:perl creat_inst_mem.pl <file name> \n";
		exit;
	}
	
	if (!open(IN_FILE,$inFileName)) { # existance check
		print $inFileName." do not exist. Check command line\n";
		exit;
	}

	$inFileNameSplit = $inFileName;
#get the directory from the file name for determining the output file location

# split the input file name into nodes slitted by "\"	
 	@subDirsArray = split(/\\/, $inFileNameSplit);
		
# concatenate all spliited nodes appart from the last one, containing the file name	
# if the working directory is placed where the script lies
	if ($#subDirsArray==0){
		$outDir = "";
	}
	else{
		for ($i=0;$i<$#subDirsArray;$i++){
	# for the 1'st node add it to the empty $outDir
			if ($i==0){
				$outDir = $outDir.@subDirsArray[$i];
			}
	# for the nodes from 1 and on add also a "/" that was omitted during the splitting process
			else{
				$outDir = $outDir."\\".@subDirsArray[$i];
			}
			
		}
		
	$outDir = $outDir."\\";
	}
	
	$outFile = $outDir."instr_mem.txt";
	
#	print "is".$outFile ;

	open(OUT_FILE,">$outFile");
	
	print ("\n\nThe output file is:".$outFile."\n");
	
#-----------------	
# analyze file
#-----------------
# go until the actual code starts
	while (($line = <IN_FILE>) && ($line !~ /Text Segment/)){
	}
	
# process until the actual code ends
	
	while (($line = <IN_FILE>) && ($line !~ /KERNEL/)){

# skip the undeline line 				
		if ($line !~ "==="){
# split the line into nodes divided by spaces	
			@nodes = split(/ +/, $line);
		
# the data is the 2'nd node		
			$data = @nodes[1];
			
# eliminate the 0x prefax		
			$data =~ s/0x//;
			
			
#			print ($data."\n");
			
			print OUT_FILE $data."\n"; 
		}		

	}
	
	