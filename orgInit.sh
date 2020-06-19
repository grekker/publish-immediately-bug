sfdx force:org:create -f config/project-scratch-def.json -d 5 -s
sfdx force:source:push
sfdx force:user:password:generate
sfdx force:package:install -w 20 -p 04t1t000003DKoiAAG
sfdx force:org:open -p lightning/n/smon__Streaming_Monitor