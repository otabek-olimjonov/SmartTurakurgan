import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";

serve(async (_req) => {
  const dbUrl = Deno.env.get("SUPABASE_DB_URL");
  if (!dbUrl) {
    return new Response(JSON.stringify({ error: "SUPABASE_DB_URL not set" }), {
      status: 500,
      headers: { "content-type": "application/json" },
    });
  }

  const client = new Client(dbUrl);
  try {
    await client.connect();
    await client.queryObject(
      "ALTER TABLE users ADD COLUMN IF NOT EXISTS photo_url text;"
    );
    await client.end();
    return new Response(JSON.stringify({ status: "ok", message: "photo_url column added" }), {
      headers: { "content-type": "application/json" },
    });
  } catch (e) {
    await client.end().catch(() => null);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { "content-type": "application/json" },
    });
  }
});
