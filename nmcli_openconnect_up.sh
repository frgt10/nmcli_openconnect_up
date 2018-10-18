USAGE="Usage:

    $(basename "$0") 'VPN_HOST' 'VPN_USER' 'VPN_PASSWORD' [NM_VPN_NAME]

NM_VPN_NAME - Network Manager connection name. By default is VPN_HOST

When VPN_PASSWORD is 'kwallet', password will be received from the kde wallet
"

# Required arguments
VPN_HOST=$1
VPN_USER=$2
VPN_PASSWD=$3

if [ -z "$VPN_HOST" ] || [ -z "$VPN_USER" ] || [ -z "$VPN_PASSWD" ]; then
    echo "$USAGE"
    exit 1
fi

NM_VPN_NAME=${4:-$VPN_HOST}
KWALLET_WALLET='kdewallet'
KWALLET_FOLDER='Network Management'
KWALLET_ENTRY=`nmcli connection | grep $NM_VPN_NAME | awk '{ print "{"$2"};vpn" }'`

if [ "$VPN_PASSWD" = "kwallet" ]; then
    VPN_PASSWD=`kwallet-query $KWALLET_WALLET --folder "$KWALLET_FOLDER" --read-password "$KWALLET_ENTRY" \
                | grep --only-matching --perl-regexp '(?<="VpnSecrets": "form:main:password%SEP%).+?(?="$)'`
fi

[ -z "$VPN_PASSWD" ] && echo "Error! Empty password" && exit 2

# On success should set two variables:
#   $COOKIE
#   $FINGERPRINT
eval `echo $VPN_PASSWD | openconnect --quiet --csd-wrapper ~/bin/csd_wrapper --user $VPN_USER --authgroup foo $VPN_HOST --authenticate --passwd-on-stdin`

[ -z "$FINGERPRINT" ] && echo "Error! Can not authenticate" && exit 3

nmcli con up $NM_VPN_NAME passwd-file /proc/self/fd/5 5<<EOF
vpn.secrets.gateway:$VPN_HOST
vpn.secrets.cookie:$COOKIE
vpn.secrets.gwcert:$FINGERPRINT
EOF
