---
source_code: https://github.com/rajnandan1/kener
tags: ["web","Status Pages","monitoring"]
---

See other [Awsome status Pages](https://github.com/ivbeg/awesome-status-pages) Tools.


Add `https://fossengineer.com/favicon.ico` or `https://www.jalcocertech.com/favicon.ico` and the domain `www.fossengineer.com` to monitor.

You can tweak all the **kener public page settings**, via: `http://192.168.1.11:5173/manage/app/home`

Example:

```html
<div
   class="container relative mt-4 max-w-[655px]"
   >
   <div class="flex flex-col items-center gap-4 px-8 md:flex-row md:gap-2 md:px-0">
      <p class="text-center text-sm leading-loose text-muted-foreground ">
         
         </a>
         <br/>
         Powered with ❤️ by <a href="https://www.jalcocertech.com/" target="_blank"  class="font-medium underline underline-offset-4"> JAlcocerTech</a>.
      </p>
   </div>
</div>
```

---



[Kener](https://github.com/rajnandan1/kener) is an open-source, self-hosted link in bio tool that allows you to create a beautiful, customizable landing page for your social media profiles.

>  Stunning status pages, batteries included! 

## Features
- Create a personalized link in bio page
- Add multiple links with custom icons
- Track clicks and analytics
- Custom domain support
- Light/dark mode
- Responsive design

## Prerequisites
- Docker
- Docker Compose
- Port 5173 available

## Quick Start

1. **Edit the configuration**:
   ```bash
   cd /home/jalcocert/Desktop/IT/Home-Lab/kener
   nano docker-compose.yml
   ```
   - Update the `ORIGIN` environment variable to match your public URL
   - Generate a secure random string for `KENER_SECRET_KEY`

2. **Start Kener**:
   ```bash
   docker-compose up -d
   ```

3. **Access the Web UI**:
   - Open your browser and go to: `http://your-server-ip:5173`
   - Access the admin panel at: `http://your-server-ip:5173/manage/app/home`

## Configuration

### Environment Variables
- `KENER_SECRET_KEY`: A secure random string for session encryption
- `ORIGIN`: The public URL where Kener will be accessed (e.g., `http://your-domain.com` or `http://192.168.1.11:5173`)
- `NODE_ENV`: Set to `production` for production use

### Ports
- `5173:3000` - Web interface (change the first number if needed)

### Volumes
- `kener_data` - Database storage
- `./uploads` - Directory for uploaded files (like profile pictures)

## Customization

### Adding Favicon
To add a favicon, you can use the following HTML in your page settings:

```html
<link rel="icon" type="image/x-icon" href="https://www.yourdomain.com/favicon.ico">
```

### Example Custom HTML
```html
<div class="container relative mt-4 max-w-[655px]">
   <div class="flex flex-col items-center gap-4 px-8 md:flex-row md:gap-2 md:px-0">
      <p class="text-center text-sm leading-loose text-muted-foreground">
         Your custom content here
      </p>
   </div>
</div>
```

## Updating

To update to the latest version:

```bash
cd /home/jalcocert/Desktop/IT/Home-Lab/kener
docker-compose pull
docker-compose up -d --force-recreate
```

## Backup and Restore

### Backup
```bash
# Backup database
docker run --rm -v kener_kener_data:/source -v $(pwd):/backup alpine tar czf /backup/kener_db_backup_$(date +%Y%m%d).tar.gz -C /source .

# Backup uploads
tar -czvf kener_uploads_backup_$(date +%Y%m%d).tar.gz ./uploads
```

### Restore
```bash
# Stop Kener
docker-compose down

# Restore database
docker run --rm -v kener_kener_data:/target -v $(pwd):/backup alpine sh -c "cd /target && tar xzf /backup/kener_db_backup_YYYYMMDD.tar.gz"

# Restore uploads (if needed)
tar -xzvf kener_uploads_backup_YYYYMMDD.tar.gz

# Start Kener again
docker-compose up -d
```

## Security

### Important Security Notes
- Always use a strong `KENER_SECRET_KEY`
- If exposing to the internet, consider using a reverse proxy with HTTPS
- Keep the software updated
- Restrict access to the admin panel if needed

### Recommended Security Practices
1. Set up a reverse proxy (Nginx, Caddy, Traefik) with HTTPS
2. Use a firewall to restrict access to the service
3. Regularly back up your data

## Troubleshooting

### Common Issues

#### Can't access Web UI
- Verify the container is running: `docker ps`
- Check logs: `docker-compose logs -f`
- Ensure port 5173 is open in your firewall

#### Permission Issues
If you encounter permission issues with the uploads directory:
```bash
sudo chown -R 1000:1000 /home/jalcocert/Desktop/IT/Home-Lab/kener/uploads
```

## Integration

Kener can be integrated with:
- Custom domains
- Analytics services
- Social media platforms

## License
Kener is open source and licensed under the [MIT License](https://github.com/rajnandan1/kener/blob/main/LICENSE).

## References
- [GitHub Repository](https://github.com/rajnandan1/kener)
- [Docker Hub](https://hub.docker.com/r/rajnandan1/kener)
