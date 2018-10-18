# nmcli_openconnect_up.sh

Up Network Manager openconnect connection with `nmcli`

## Usage

    nmcli_openconnect_up.sh 'VPN_HOST' 'VPN_USER' 'VPN_PASSWORD' [NM_VPN_NAME]

`NM_VPN_NAME` - Network Manager connection name. By default is `VPN_HOST`.

When `VPN_PASSWORD` is 'kwallet', password will be received from the KDE wallet.
