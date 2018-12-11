
#!/bin/bash

SITESFILE=/bin/monitorscript/sites.txt #list the sites you want to monitor in this file
ACTIVEFAILURE=/bin/monitorscript/activefailure.txt #Used to list the current active failures to prevent unnecesary calls to pagerduty

#PagerDuty variables
PDSERVICE_KEY=6af562ae443f434e8f11bf5fad906b15
CONTENT_TYPE="application/json"
PDURL="https://events.pagerduty.com/generic/2010-04-15/create_event.json"

#for each site in sites.txt
while read site || [[ -n $site ]]; do

     if [ ! -z "${site}" ]; then
        
        CURL=$(curl -L -s --connect-timeout 5 --head "$site")
        DESC="$site is not returning 200"        
        if echo $CURL | grep "200 OK" > /dev/null
        
        then
            echo "${site} - 200 OK"
            if grep "$site" $ACTIVEFAILURE #Check if there is an active indicent and resolve
            then
                curl -H "${CONTENT_TYPE}" \
                -X POST \
                -d "{ \"service_key\": \"$PDSERVICE_KEY\", \"event_type\": \"resolve\", \"incident_key\": \"$site\" }" \
                "${PDURL}"
                sed -i'.bak' /"$site"/d $ACTIVEFAILURE
            fi

        else
            echo -e "${site} is not responding\n" >> $ACTIVEFAILURE
            #trigger PD event
            curl -H "${CONTENT_TYPE}" \
            -X POST \
            -d "{ \"service_key\": \"$PDSERVICE_KEY\", \"event_type\": \"trigger\", \"incident_key\": \"$site\", \"description\": \"$DESC\" }" \
            "${PDURL}"
        fi
    fi
done < $SITESFILE