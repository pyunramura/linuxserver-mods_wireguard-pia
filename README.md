# [pyunramura/linuxserver-mods_wireguard-pia](https://github.com/pyunramura/linuxserver-mods_wireguard-pia)
***A linuxserver.io container-mod that installs wireguard VPN within the container; complete with strong firewall rules, automatic port-forwarding through PIA, and automatic torrent-client port updates.***

[![Release Ship](https://github.com/pyunramura/linuxserver-mods_wireguard-pia/actions/workflows/semver-build-push-release.yaml/badge.svg)](https://github.com/pyunramura/linuxserver-mods_wireguard-pia/actions/workflows/semver-build-push-release.yaml) [![Validate Dockerfile](https://github.com/pyunramura/linuxserver-mods_wireguard-pia/actions/workflows/validate-dockerfile.yaml/badge.svg)](https://github.com/pyunramura/linuxserver-mods_wireguard-pia/actions/workflows/validate-dockerfile.yaml)

This project's home is located at https://github.com/pyunramura/linuxserver-mods_wireguard-pia

Find this image on the Github container registry at [ghcr.io/pyunramura/wireguard-pia](https://github.com/pyunramura/linuxserver-mods_wireguard-pia/pkgs/container/wireguard-pia)

or in the Dockerhub registry at [pyunramura/wireguard-pia](https://hub.docker.com/r/pyunramura/wireguard-pia).

---

## Usage

This container-mod is packaged for installation within linuxserver containers by defining:

`-e DOCKER_MODS=pyunramura/wireguard-pia`  or

`-e DOCKER_MODS=ghcr.io/pyunramura/wireguard-pia`

in the container's configuration.

## Constraints

This mod was built for the [**linuxserver/transmission**](https://fleet.linuxserver.io/image?name=linuxserver/transmission) image, but should be usable with any linuxserver image that would benefit from a wireguard VPN tunnel.

## Mod Info

The mod was cribbed almost entirely from [**thrnz/docker-wireguard-pia**](https://github.com/thrnz/docker-wireguard-pia), with minor repackaging to allow integration into an existing linuxserver container.

A default port updating script is provided at `/config/wireguard/scripts/port-update.sh` that updates the transmission service with a forwarded port from PIA with `PORT_FORWARDING=true`. To enable this script, set `PORT_SCRIPT=true`.

Feel free to modify the port script for your preferred torrent client, or open a new issue / PR if you would like to see new torrent clients integrated into the update script.

## Requirements
* Ideally the host must already support WireGuard. Pre 5.6 kernels may need to have the module manually installed. If this is not possible, then a userspace implementation can be enabled using the WG_USERSPACE environment variable.
* An active [PIA](https://www.privateinternetaccess.com) subscription.

## Config
**The following ENV vars are required:**

| ENV Var | Function |
|-------|------|
|`LOC=swiss`|Location id to connect to. Available 'next-gen' server location ids are listed [**here**](https://serverlist.piaservers.net/vpninfo/servers/new). Example values include `us_california`, `ca_ontario`, and `swiss`. If left empty, or an invalid id is specified, the container will print out all available location ids and exit.
|`WG_USER=p0000000`|PIA username (required unless a valid WG_USER_FILE is set)
|`WG_PASS=xxxxxxxx`|PIA password (required unless a valid WG_PASS_FILE is set)

**The rest are optional:**

| ENV Var | Function |
|-------|------|
|`WG_USER_FILE=/run/secrets/pia-username` `WG_PASS_FILE=/run/secrets/pia-password`|PIA credentials can also be read in from existing files (eg for use with Docker secrets), and will overwrite existing WG_USER and WG_PASS variables
|`LOCAL_NETWORK=192.168.1.0/24,192.168.2.0/24`|Whether to route and allow input/output traffic to the LAN. LAN access is blocked by default if not specified. Multiple ranges can be specified, separated by a comma or space.
|`KEEPALIVE=25`|If defined, PersistentKeepalive will be set to this in the WireGuard config. Defaults to `0` if unset.
|`VPNDNS=8.8.8.8,8.8.4.4`|Use these DNS servers in the WireGuard config. Defaults to PIA's DNS servers if not specified.
|`PORT_FORWARDING=false`|Whether to enable port forwarding. Requires a supported server. Defaults to `false` if not specified.
|`PORT_FILE_CLEANUP=false`|Remove the file containing the forwarded port number on exit. Defaults to `false` if not specified.
|`PORT_PERSIST=false`|Set to `true` to attempt to keep the same port forwarded when the container is restarted. The port number may persist for up to two months. Defaults to `false` (always acquire a new port number) if not specified.
|`PORT_SCRIPT=true`|Run a custom script once a port is successfully forwarded. The forwarded port number is passed as the first command line argument. Defaults to `false` if not specified.
|`FIREWALL=true`|Whether to block non-WireGuard traffic. Defaults to `true` if not specified.
|`EXIT_ON_FATAL=false`|There is no error recovery logic at this stage. If something goes wrong we simply go to sleep. By default the container will continue running until manually stopped. Set this to `true` to force the container to exit when an error occurs. Exiting on an error may not be desirable behavior if other containers are sharing the connection. Defaults to `false` if not specified.
|`WG_USERSPACE=false`|If the host OS or host Linux kernel does not support WireGuard (certain NAS systems), a userspace implementation ([wireguard-go](https://git.zx2c4.com/wireguard-go/about/)) can be enabled. Defaults to `false` if not specified.
|`PIA_IP=x.x.x.x` `PIA_CN=hostname401` `PIA_PORT=1337`|Connect to a specific server by manually setting all three of these. This will override whatever `LOC` is set to.
|`FWD_IFACE` `PF_DEST_IP`|If needed, the container can be used as a gateway for other containers or devices by setting these. See [issue #20](https://github.com/thrnz/docker-wireguard-pia/issues/20) for more info. Note that these are for a specific use case, and in many cases using Docker's `--net=container:xyz` or docker-compose's `network_mode: service:xyz` instead, and leaving these vars unset, would be an easier way of accessing the VPN and forwarded port from other containers.
|`NFTABLES=false`|Alpine uses `iptables-legacy` by default. If needed, `iptables-nft` can be used instead by setting this to `true`. Defaults to `false` if not specified. See [issue #37](https://github.com/thrnz/docker-wireguard-pia/issues/37).

## Notes
* Based on what was found in the source code to the PIA desktop app.
* As of Sep 2020, PIA have released [scripts](https://github.com/pia-foss/manual-connections) for using WireGuard outside of their app.
* PIA username/password is only used on the first run. A persistent auth token is generated and will be re-used for future runs.
* Persistent data is stored in `/config/wireguard`.
* IPv4 only. IPv6 traffic is blocked unless using `FIREWALL=0` but you may want to disable IPv6 on the container anyway to avoid IPv6 specific DNS leakage issues.
* Other containers can share the VPN connection using Docker's [`--net=container:xyz`](https://docs.docker.com/engine/reference/run/#network-settings) or docker-compose's [`network_mode: service:xyz`](https://github.com/compose-spec/compose-spec/blob/master/spec.md#network_mode).
* The userspace implementation through wireguard-go is very stable but lacks in performance. Looking into supporting ([boringtun](https://github.com/cloudflare/boringtun)) might be beneficial.
* Custom scripts can be run at various stages of the container's lifecycle if needed. See [issue #33](https://github.com/thrnz/docker-wireguard-pia/issues/33) for more info.

## Credits
The bulk of the credit for this image is due to work by user **thrnz** for their image at [**thrnz/docker-wireguard-pia**](https://github.com/thrnz/docker-wireguard-pia).
