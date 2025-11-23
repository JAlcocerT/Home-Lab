
import pathlib
import listmonk
from typing import Optional

from dotenv import load_dotenv
import os


load_dotenv()  # loads from .env by default

from dotenv import load_dotenv
import os
import listmonk

load_dotenv()

# base_url = os.getenv("LISTMONK_URL_BASE", "http://localhost:9077")
# admin_user = os.getenv("LISTMONK_ADMIN_USER", "admin")        # fallback only for local
# admin_pass = os.getenv("LISTMONK_ADMIN_PASSWORD", "admin")    # fallback only for local

# listmonk.set_url_base(base_url)

# print("Health:", listmonk.is_healthy())

# listmonk.login(admin_user, admin_pass)
# print("verify_login:", listmonk.verify_login())


listmonk.set_url_base(os.getenv('LISTMONK_URL_BASE','http://localhost:9077'))

listmonk.login(os.getenv('LISTMONK_ADMIN_USER'), os.getenv('LISTMONK_ADMIN_PASSWORD'))
valid: bool = listmonk.verify_login()

# Is it alive and working?
up: bool = listmonk.is_healthy()
print(up)

# Create a new list
#new_list = listmonk.create_list(list_name="my_new_list")

# Read data about your lists
#lists: list[] = listmonk.lists()
#the_list: MailingList = listmonk.list_by_id(list_id=7)

# Various ways to access existing subscribers
#subscribers: list[] = listmonk.subscribers(list_id=9)

#subscriber: Subscriber = listmonk.subscriber_by_email('testuser@some.domain')
#subscriber: Subscriber = listmonk.subscriber_by_id(2001)
#subscriber: Subscriber = listmonk.subscriber_by_uuid('f6668cf0-1c...')

# Create a new subscriber
new_subscriber = listmonk.create_subscriber(
    'yosua@some.domain', 'Jane Doe',
    {1, 7, 9}, pre_confirm=True, attribs={...})

# Change the email, custom rating, and add to lists 4 & 6, remove from 5.
#subscriber.email = 'newemail@some.domain'
#subscriber.attribs['rating'] = 7
#subscriber = listmonk.update_subscriber(subscriber, {4, 6}, {5})

# Confirm single-opt-ins via the API (e.g. for when you manage that on your platform)
#listmonk.confirm_optin(subscriber.uuid, the_list.uuid)

# Disable then re-enable a subscriber
#subscriber = listmonk.disable_subscriber(subscriber)
#subscriber = listmonk.enable_subscriber(subscriber)

# Block (unsubscribe) them
#listmonk.block_subscriber(subscriber)

# Fully delete them from your system
#listmonk.delete_subscriber(subscriber.email)

#### Send an individual, transactional email (e.g. password reset)
#http://localhost:9077/admin/campaigns/templates

to_email = os.getenv('to_email', 'testuser@some.domain')
from_email = os.getenv('from_email', 'app@your.domain')
template_id = int(os.getenv('template_id', 3))
template_data = {'full_name': 'Test User', 'reset_code': 'abc123'}

status: bool = listmonk.send_transactional_email(
    to_email, template_id, from_email=from_email,
    template_data=template_data, content_type='html')

# You can also add one or multiple attachments with transactional mails
# attachments = [
#     pathlib.Path("/path/to/your/file1.pdf"),
#     pathlib.Path("/path/to/your/file2.png")
# ]
attachments = [
    pathlib.Path("/Ebook-cover-SSGs.pdf")
]

status: bool = listmonk.send_transactional_email(
    to_email,
    template_id,
    from_email=from_email,
    template_data=template_data,
    attachments=attachments,
    content_type='html'
)

# Access existing campaigns
# from listmonk.models import Campaign
# from datetime import datetime, timedelta

# campaigns: list[Campaign] = listmonk.campaigns()
# campaign: Campaign = listmonk.campaign_by_id(15)

# # Create a new Campaign
# listmonk.create_campaign(name='This is my Great Campaign!',
#                          subject="You won't believe this!",
#                          body='<p>Some Insane HTML!</p>',  # Optional
#                          alt_body='Some Insane TXT!',  # Optional
#                          send_at=datetime.now() + timedelta(hours=1),  # Optional
#                          template_id=5,  # Optional Defaults to 1
#                          list_ids={1, 2},  # Optional Defaults to 1
#                          tags=['good', 'better', 'best']  # Optional
#                          )

# Update A Campaign
# campaign_to_update: Optional[Campaign] = listmonk.campaign_by_id(15)
# campaign_to_update.name = "More Elegant Name"
# campaign_to_update.subject = "Even More Clickbait!!"
# campaign_to_update.body = "<p>There's a lot more we need to say so we're updating this programmatically!"
# campaign_to_update.altbody = "There's a lot more we need to say so we're updating this programmatically!"
# campaign_to_update.lists = [3, 4]

# listmonk.update_campaign(campaign_to_update)

# Delete a Campaign
#campaign_to_delete: Optional[Campaign] = listmonk.campaign_by_id(15)
#listmonk.delete_campaign(campaign_to_delete)

# Preview Campaign
#preview_html = listmonk.campaign_preview_by_id(15)
#print(preview_html)

# Access existing Templates
# from listmonk.models import Template
# templates: list[Template] = listmonk.templates()
# template: Template = listmonk.template_by_id(2)

# # Create a new Template for Campaigns
# new_template = listmonk.create_template(
#     name='NEW TEMPLATE',
#     body='<p>Some Insane HTML! {{ template "content" . }} </p>',
#     type='campaign',
# )

# # Update A Template
# new_template.name = "Bob's Great Template"
# listmonk.update_template(new_template)

# # Delete a Template
# listmonk.delete_template(3)

# # Preview Template
# preview_html = listmonk.template_preview_by_id(3)
# print(preview_html)

# # Create a new template for Transactional Emails
# new_tx_template = listmonk.create_template(
#     name='NEW TX TEMPLATE',
#     subject='Your Transactional Email Subject',
#     body='<p>Some Insane HTML! {{ .Subscriber.FirstName }}</p>',
#     type='tx',
# )