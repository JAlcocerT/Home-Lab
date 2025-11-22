---
source_code: https://github.com/poste/poste
---


You will have to go to:

* For managing the server (MailServer Dashboard): https://mail.youramazingdomain.com/admin/
* To access the email: https://mail.youramazingdomain.com/webmail/

**To [configure DNS](https://poste.io/doc/configuring-dns)**
1. Go to the **virtual domains** list
* select your domain (it will be there) and create a new DKIM key
    * add the TXT: 
        * `somestring._domainkey.youramazingdomain.com.`
        * `"k=rsa; p=string/crazy+really+long+string"`
        * TTL `3600s`
    * Check if DKIM is properly configured with: <https://poste.io/dkim>
        * You will need to input your domain `youramazingdomain.com` and also the `somestring` generated
* Add the MX: `youramazingdomain.com MX mail.youramazingdomain.com` (DNS only, dont proxy them in cloudflare)
* Add SPF: `your-domain.com. IN TXT "v=spf1 mx ~all"`
    * also as TXT:
        * `@`
        * `v=spf1 mx ~all`
        * TTL 3600s
    * check if SPF works: <https://poste.io/spf>
* Add DMARC: `_dmarc.our-domain.com. IN TXT "v=DMARC1; p=none; rua=mailto:dmarc-reports@our-domain.com"`
    * Also as TXT:
        * `_dmarc.youramazingdomain.com`
        * `"v=DMARC1; p=none; rua=mailto:dmarc-reports@our-domain.com"`
    * Check if DMARK works: <https://poste.io/dmarc>


```sh
docker run -d \
  --name mailserver \
  --restart unless-stopped \
  --network host \
  -e TZ=Europe/Madrid \
  -e h=mail.bachatameet.com \
  -e HTTP_PORT=7080 \
  -e HTTPS_PORT=7443 \
  -e DISABLE_CLAMAV=FALSE \
  -e DISABLE_RSPAMD=FALSE \
  -e DISABLE_ROUNDCUBE=FALSE \
  -v ./mail:/data \
  analogic/poste.io
```

<!-- 
https://mariushosting.com/synology-activate-gmail-smtp-for-docker-containers/
https://itsfoss.com/open-source-email-servers/

https://poste.io/
https://poste.io/doc/getting-started
https://hub.docker.com/r/analogic/poste.io/
https://github.com/dirtsimple/poste.io

https://github.com/mjl-/mox - MIT Licensed

https://github.com/muety/mailwhale - MIT Licensed, but archived

Think of MailWhale like Mailgun, SendGrid or SMTPeter, but open source and self-hosted. Or like Postal or Cuttlefish, but less bloated and without running its own, internal SMTP server.

https://github.com/postalserver/postal - MIT Licensed
https://docs.postalserver.io/getting-started -->




https://www.youtube.com/watch?v=nNGcvz1Sc_8

https://github.com/docker-mailserver/docker-mailserver?ref=fossengineer.com
https://i12bretro.github.io/tutorials/0779.html
https://www.youtube.com/watch?v=r9vG7P-RRp8


https://github.com/pablokbs/peladonerd/tree/master?ref=fossengineer.com
https://www.youtube.com/watch?v=K4-uD1VHCz0
https://www.youtube.com/watch?v=hhF9JExJFDc