// Volcengine HMAC-SHA256 API Signer
// Reference: https://www.volcengine.com/docs/6369/67269

const ACCESS_KEY_ID = Deno.env.get("VOLCENGINE_ACCESS_KEY_ID") ?? "";
const SECRET_ACCESS_KEY = Deno.env.get("VOLCENGINE_SECRET_ACCESS_KEY") ?? "";
const REGION = "cn-north-1";
const SERVICE = "cv";

function toHex(buffer: ArrayBuffer): string {
  return Array.from(new Uint8Array(buffer))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

async function hmacSHA256(
  key: ArrayBuffer | Uint8Array,
  message: string
): Promise<ArrayBuffer> {
  const cryptoKey = await crypto.subtle.importKey(
    "raw",
    key instanceof ArrayBuffer ? key : key.buffer,
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );
  return crypto.subtle.sign("HMAC", cryptoKey, new TextEncoder().encode(message));
}

async function sha256(message: string): Promise<string> {
  const hash = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(message)
  );
  return toHex(hash);
}

function getFormattedDate(date: Date): { dateStamp: string; amzDate: string } {
  const iso = date.toISOString().replace(/[-:]/g, "").replace(/\.\d{3}/, "");
  return {
    dateStamp: iso.substring(0, 8),
    amzDate: iso,
  };
}

export async function signVolcengineRequest(
  action: string,
  version: string,
  body: string,
  date?: Date
): Promise<{ url: string; headers: Record<string, string> }> {
  const now = date ?? new Date();
  const { dateStamp, amzDate } = getFormattedDate(now);

  const host = "visual.volcengineapi.com";
  const method = "POST";
  const canonicalUri = "/";
  const canonicalQuerystring = `Action=${action}&Version=${version}`;

  const payloadHash = await sha256(body);

  const canonicalHeaders =
    `content-type:application/json\n` +
    `host:${host}\n` +
    `x-content-sha256:${payloadHash}\n` +
    `x-date:${amzDate}\n`;

  const signedHeaders = "content-type;host;x-content-sha256;x-date";

  const canonicalRequest = [
    method,
    canonicalUri,
    canonicalQuerystring,
    canonicalHeaders,
    signedHeaders,
    payloadHash,
  ].join("\n");

  const credentialScope = `${dateStamp}/${REGION}/${SERVICE}/request`;
  const stringToSign = [
    "HMAC-SHA256",
    amzDate,
    credentialScope,
    await sha256(canonicalRequest),
  ].join("\n");

  // Derive signing key
  const kDate = await hmacSHA256(
    new TextEncoder().encode(SECRET_ACCESS_KEY),
    dateStamp
  );
  const kRegion = await hmacSHA256(kDate, REGION);
  const kService = await hmacSHA256(kRegion, SERVICE);
  const kSigning = await hmacSHA256(kService, "request");

  const signature = toHex(await hmacSHA256(kSigning, stringToSign));

  const authorization =
    `HMAC-SHA256 Credential=${ACCESS_KEY_ID}/${credentialScope}, ` +
    `SignedHeaders=${signedHeaders}, ` +
    `Signature=${signature}`;

  return {
    url: `https://${host}/?${canonicalQuerystring}`,
    headers: {
      "Content-Type": "application/json",
      Host: host,
      "X-Date": amzDate,
      "X-Content-Sha256": payloadHash,
      Authorization: authorization,
    },
  };
}
