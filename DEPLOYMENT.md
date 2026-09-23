# Website access from other computers and browsers

## Option 1 — Same Wi-Fi or local network

### Windows

Double-click:

```text
start-network.bat
```

Share the `Network access` address printed by the terminal, for example:

```text
http://192.168.1.20:3000
```

The host computer and terminal must remain running. If another device cannot
connect, allow Node.js through Windows Firewall on private networks.

### Linux or macOS

```bash
chmod +x start-network.sh
./start-network.sh
```

## Option 2 — Public HTTPS link from anywhere

This method uses Cloudflare Tunnel. The URL works on different networks and
modern browsers without opening a router port.

### Windows

Double-click:

```text
start-public.bat
```

The script installs `cloudflared` with Windows Package Manager if necessary.
Copy the generated `https://...trycloudflare.com` address from the terminal.

### Linux or macOS

Install `cloudflared`, then run:

```bash
chmod +x start-public.sh
./start-public.sh
```

### Important limitations of a Quick Tunnel

- The generated address changes when the tunnel restarts.
- The host computer and both processes must remain running.
- Anyone with the URL can reach the platform.
- Data continues to be stored in the host computer's `storage` directory.

For a fixed domain, create a named Cloudflare Tunnel and set its token before
starting:

### Windows Command Prompt

```bat
set CLOUDFLARE_TUNNEL_TOKEN=YOUR_TUNNEL_TOKEN
start-public.bat
```

### PowerShell

```powershell
$env:CLOUDFLARE_TUNNEL_TOKEN="YOUR_TUNNEL_TOKEN"
.\start-public.bat
```

### Linux or macOS

```bash
export CLOUDFLARE_TUNNEL_TOKEN="YOUR_TUNNEL_TOKEN"
./start-public.sh
```

Configure the named tunnel's public hostname to forward to:

```text
http://localhost:3000
```

## Option 3 — VPS or Docker host

For a server that stays online independently of a personal computer:

```bash
docker compose up -d --build
docker compose logs -f
```

The `storage` directory is mounted as a persistent volume. Put the service
behind an HTTPS reverse proxy or a named Cloudflare Tunnel before publishing
it on the internet.

Stop or update it with:

```bash
docker compose down
docker compose up -d --build
```

## Verification

After starting the platform, verify:

```bash
curl http://127.0.0.1:3000/api/health
```

Then test the refresh-safe routes in a private/incognito browser window:

```text
app/index.html?view=timetable
app/index.html?view=hours
app/index.html?view=studentRepresentatives
app/index.html?view=studentAbsences
app/index.html?view=teachers
app/index.html?view=coordination
app/index.html?view=scientific
app/index.html?view=competition
```

These query-based routes work with the Node server, VS Code Live Server, and
basic static hosting. Refreshing the page does not produce a 404.

## Security notice

The current platform does not implement user accounts or access control.
Use temporary public links only with trusted people. Before permanent public
deployment, add authentication, authorization, regular backups, HTTPS, and
server monitoring.