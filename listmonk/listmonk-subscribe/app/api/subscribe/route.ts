import { NextResponse } from 'next/server';

// Prefer LISTMONK_URL_BASE to match the user's existing env setup, with a sane default.
const baseUrl =
  process.env.LISTMONK_URL_BASE || process.env.LISTMONK_BASE_URL || 'http://localhost:9000';

// For the public subscription API, lists are identified by UUIDs (see /api/public/lists).
// Read a UUID from LISTMONK_LIST_UUID, falling back to LISTMONK_LIST_ID if needed.
const listUuid =
  process.env.LISTMONK_LIST_UUID || process.env.LISTMONK_LIST_ID || '';

export async function POST(request: Request) {
  try {
    const { email } = await request.json();

    if (!email || typeof email !== 'string') {
      return NextResponse.json({ error: 'Email is required' }, { status: 400 });
    }

    const body = {
      email,
      // For public subscription, listmonk accepts list_uuids (as confirmed via curl).
      list_uuids: listUuid ? [listUuid] : [],
      status: 'enabled',
    };

    const resp = await fetch(`${baseUrl}/api/public/subscription`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    const data = await resp.json().catch(() => null);

    if (!resp.ok) {
      const detail = data || resp.statusText;
      console.error('Subscribe HTTP error:', detail);
      return NextResponse.json(
        { error: 'Subscription failed', detail },
        { status: resp.status },
      );
    }

    return NextResponse.json({ success: true, data }, { status: 200 });
  } catch (error: any) {
    const detail = error?.response?.data || error?.message || error;
    console.error('Subscribe error:', detail);
    return NextResponse.json(
      { error: 'Subscription failed', detail },
      { status: 500 },
    );
  }
}
