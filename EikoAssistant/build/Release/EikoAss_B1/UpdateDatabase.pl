open my $xmlFile, 'JB_Database.xml' or die "missing xml file: $!";
open my $newXmlFile, '>', 'JB_DatabaseUpdated.xml' or die "Error creating file: $!";

my $line;

while ( $line = <$xmlFile> )
{
	print $newXmlFile $line;

	if( ( substr($line, 0, 30) eq            '    <object type="BILLINGRATE"') ||
 	    ( substr($line, 0, 27) eq            '    <object type="HOURSLOG"') )
	{
		$line = <$xmlFile>;
		while( substr($line, 0, 30) ne '        <attribute name="name"')
		{
			
			print $newXmlFile $line;
			$line = <$xmlFile>;
		}
		#print the line minus the '1.{space}'
		print $newXmlFile substr( $line, 0, 45) . substr( $line, 48, 999);		
		my $addedLine = '        <attribute name="order" type="string">' . substr( $line, 45, 1) . '</attribute>' . "\n";
		print $newXmlFile $addedLine;
	}

}

