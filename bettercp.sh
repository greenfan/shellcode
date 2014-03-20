 #!/bin/bash
# Bettercp v.1 Russell Dwyer

if [ $# -eq 0 ]

then echo "What files do you want copied?"

read filetocopy

echo "Please specify the absolute path of where you would like to copy $filetocopy"

read locationtocopy

        if [ -f ./$locationtocopy/$filetocopy ]

           then 
		echo "file exists already, should I copy . .i yes/no ? "
                read answer1
                if [ $answer1 =  yes ]
			then
				cp $filetocopy ./$locationtocopy &&  echo "File $filetocopy successfully copied to ./$locationtocopy"
			else
				echo "Exiting program" exit 1
                fi
           else  cp $filetocopy ./$locationtocopy &&  echo "File $filetocopy successfully copied to ./$locationtocopy"

        fi
fi

